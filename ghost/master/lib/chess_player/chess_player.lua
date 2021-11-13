local Class     = require("class")
local StringBuffer  = require("string_buffer")
local Clone     = require("clone")
local Color     = require("chess_player.color")
local InitialPreset = require("chess_player.initial_preset")
local Misc      = require("chess_player.misc")
local NL        = require("chess_player.nl")
local Parser    = require("chess_player.parser")
local Position  = require("chess_player.position")
local Relative  = require("chess_player.relative")
local UCI       = require("chess_player.parser.uci")

local M = Class()
M.__index = M
M.__add   = function(self, value)
  local t = type(value)
  if t == "string" or t == "table" then
    self:appendMove(value)
  elseif t == "number" then
    self:go(self:getTesuu() + value)
  end
  return self
end
M.__sub   = function(self, value)
  local t = type(value)
  if t == "number" then
    self:go(self:getTesuu() - value)
  end
  return self
end

function M:_init()
  self.tesuu  = 0
  self.jkf    = {
    header  = {},
    moves   = {[0] = {}},
  }
  self.branch_info  = {}
  self.currentTime  = 0
  self.init_color = Color.WHITE
  self.position = Position()
  self.castling = {
    [Color.WHITE] = 1000,
    [Color.BLACK] = 1000,
  }
  self.enpassant  = {}
end

--- 局面を指定する
-- @tparam string str
function M:setPosition(str)
  str = str or InitialPreset.HIRATE
  self:_init()
  local sfen = InitialPreset.toSfen(str)
  if sfen then
    self.jkf.initial = {
      preset  = str,
    }
  else
    self.jkf.initial = {
      preset  = "OTHER",
      data  = UCI.parseInit(str),
    }
  end
  self:normalize_all()
end

--- 棋譜ファイルを読み込む
-- @tparam string file_name 棋譜ファイル名
-- @treturn boolean true if success to load file
function M:load(file_name)
  local fh  = io.open(file_name, "r")
  if fh then
    local data  = fh:read("a")
    fh:close()
    return self:parse(data)
  end
  return false
end

--- UTF-8/LFなKIF/KI2/CSA/JKFをJKF形式の連想配列へパースする
-- @tparam string str
function M:parse(str)
  local err = "Parse Error"
  --self.jkf = Parser.parse(str)
  str = NL.toLF(str)
  local ret = Parser.parse(self, str)
  assert(self.jkf, err)
  --self:normalize_all()
  self:head()
  self.branch_info  = {}

  return true
end

--- 読み込んだ棋譜の足りない情報を追加する
function M:normalize_all()
  self.tesuu  = 0
  local initial = self.jkf.initial
  local data
  if initial then
    if initial.preset == InitialPreset.OTHER then
      data  = initial.data
    else
      data  = UCI.parseInit(InitialPreset.toSfen(initial.preset))
    end
  else
    data  = UCI.parseInit(InitialPreset.toSfen(InitialPreset.HIRATE))
  end
  self.init_color = data.color
  self.position:setInitPosition(data)

  -- TODO fork
  for i = 1, #self.jkf.moves do
    --[[
    prev_move_format  = self:normalize(
      self.jkf.moves[i], self.jkf.moves[i - 1])
    --]]
    self:normalize(self.jkf.moves[i])
    self:forward()
  end
  self:go(0)  -- 初手へ移動
end

function M:normalize(move_format)
  assert(move_format.move or move_format.special)
  local current_move_format  = self:getMoveFormat()
  local move  = move_format.move
  if move then
    if move.from and move.relative then
      --  normalizeの必要なし
    else
      -- move.color
      if move.color == nil then
        -- TODO 獅子などの特殊駒への対応
        if current_move_format and current_move_format.move then
          move.color  = Color.reverse(current_move_format.move.color)
        else
          move.color  = self:getInitColor()
        end
      end
      -- move.to
      if move.to == nil then
        assert(move.same)
        local current_move = current_move_format.move
        assert(current_move)
        move.to = {
          x = current_move.to.x,
          y = current_move.to.y,
        }
        assert(move.to.x)
        assert(move.to.y)
      end
      -- move.same
      if move.same ~= true then
        if current_move_format then
          local current_move = current_move_format.move
          if current_move then
            if  current_move.to.x == move.to.x and
                current_move.to.y == move.to.y then
              move.same = true
            end
          end
        end
      end
      -- move.capture
      if move.capture == nil then
        local piece = self.position:getPiece(move.to.x, move.to.y)
        assert(piece)
        if piece.color and piece.kind then
          move.capture = piece.kind
        end
      end
      -- move.piece
      if move.piece == nil then
        assert(move.from)
        local piece = self.position:getPiece(move.from.x, move.from.y)
        assert(piece)
        move.piece  = piece.kind
      end
      -- move.from / move.relative
      if move.from == nil or move.relative == nil then
        assert(move.piece)
        local choice  = {}
        -- TODO stub
        local list  = Relative.getRelativeList(move.color, move.piece)
        for _, v in pairs(list) do
          for _, v in ipairs(v) do
            local x = move.to.x + v.x
            local y = move.to.y + v.y
            if  x < 1 or x > 8 or
                y < 1 or y > 8 then
              break
            end
            local piece = self.position:getPiece(x, y)
            assert(piece)
            if piece.color and piece.kind then
              if  piece.color == move.color and
                  piece.kind  == move.piece then
                table.insert(choice, v)
              end
              break
            end
          end -- for ipairs(v)
        end -- for ipairs(list)

        -- 盤上に該当する駒が無い => 持ち駒を使った
        if #choice == 0 then
          -- 打
          move.relative = nil -- 相対情報は必要なし。
        elseif #choice == 1 then
          if move.relative == nil then
            move.from = {
              x = move.to.x + choice[1].x,
              y = move.to.y + choice[1].y,
            }
          else
            move.relative = Relative.H
          end
        elseif #choice > 1 then
          -- 相対情報があれば対応するものをfromに選ぶ
          if move.relative then
            if move.relative ~= Relative.H then
              local relative = Relative.parse(move.relative)
              for _, v in ipairs(choice) do
                if relative.sub == nil or relative.sub == v.sub then
                  if relative.main == v.main then
                    move.from = {
                      x = move.to.x + v.x,
                      y = move.to.y + v.y,
                    }
                  end
                elseif relative.main == nil or relative.main == v.main then
                  if relative.sub == v.sub then
                    move.from = {
                      x = move.to.x + v.x,
                      y = move.to.y + v.y,
                    }
                  end
                end
                if move.from then
                  break
                end
              end -- for ipairs(choice)
            else
              -- Relative.Hの場合はnormalizeの必要がない。
            end -- if relative ~= Relative.H
          else
            assert(move.from)
            -- move.fromに対応するrelativeを取得
            local main  = {
              D = 0,
              M = 0,
              U = 0,
            }
            local sub   = {
              L = 0,
              C = 0,
              R = 0,
            }
            local from
            local other
            for _, v in ipairs(choice) do
              main[v.main]  = main[v.main] + 1
              sub[v.sub]    = sub[v.sub] + 1
              if  move.to.x + v.x == move.from.x and
                  move.to.y + v.y == move.from.y then
                from  = v
              else
                other = v
              end
            end
            assert(from)
            if main[from.main] == 1 then
              move.relative = from.main
            elseif sub[from.sub] == 1 then
              move.relative = from.sub
            else
              move.relative = from.main .. from.sub
            end
          end -- if move.relative
        end -- if #choice
      end
      --  move.promote
      if move.from and move.promote == nil then
        local promote = Misc.canPromote(move.color, move.from.y, move.to.y, move.piece)
        if promote then
          move.promote  = false
        end
      end
      -- move.castling
      if move.castling == nil and move.from then
        if move.piece == Misc.K and math.abs(move.from.x - move.to.x) == 2 then
          move.castling = true
        end
      end
      -- en passant
      local enpassant = false
      if move.piece == Misc.P and move.from then
        local piece = self:getPiece(move.to.x, move.from.y)
        if piece.color == Color.reverse(move.color)
            and piece.kind == Misc.P
            and move.to.x == self.enpassant.x
            and move.to.y == self.enpassant.y
            then
          move.enpassant = true
        end
      end
    end -- if move.from and move.relative
  end -- if move
  return move_format
end

--- 現在の手数を返す
-- @treturn int
function M:getTesuu()
  return self.tesuu
end

--- 現在の手番を返す
-- @treturn color
function M:getTeban()
  if self:getTesuu() % 2 == 1 then
    return Color.reverse(self:getInitColor())
  end
  return self:getInitColor()
end

function M:getInitColor()
  local initial = self.jkf.initial
  if initial then
    if initial.preset == InitialPreset.HIRATE then
      return Color.WHITE
    elseif initial.preset == InitialPreset.OTHER then
      return initial.data.color
    else
      -- 駒落ち
      return Color.WHITE
    end
  else
    return Color.WHITE
  end
end

--- 現在の分岐のnum手目における分岐と残り手数を返す
-- @tparam[opt] num
-- @treturn MoveFormat[], int
function M:getBranch(num)
  num = num or self:getTesuu()
  local branch  = self.jkf.moves
  local prev_info  = nil
  --print("#branch_info: " .. #self.branch_info)
  for i = 1, #self.branch_info do
    local info  = self.branch_info[i]
    --print("info: num  : " .. info.num)
    --print("      fork : " .. info.fork)
    if num - info.num >= 0 then
      num     = num - info.num + 1
      branch  = branch[info.num].forks[info.fork]
      prev_info = info
    else
      break
    end
  end
  --print("branch: " .. tostring(branch))
  --print("remain: " .. num)
  return branch, num, prev_info
end

--- 現在の分岐を返す
-- @tparam[opt] num
-- @treturn MoveFormat[]
function M:getCurrentBranch()
  local branch, num = self:getBranch(self:getTesuu())
  return branch
end

--- 現在の分岐に於けるnum手目のMoveFormatを返す
-- @tparam[opt] num
-- @treturn MoveFormat
function M:getMoveFormat(num)
  num = num or self:getTesuu()
  local branch, num = self:getBranch(num)
  return branch[num]
end

--- num手目の指し手をhuman readableな形式で返す
-- @tparam[opt] num
-- @treturn string
function M:getSashite(num)
  local move_format = nil
  num = num or self:getTesuu()
  --local move_format = self.jkf.moves[num]
  if type(num) == "number" then
    move_format = self:getMoveFormat(num)
  elseif type(num) == "table" then
    move_format = num
  end
  local move  = move_format.move
  if move then
    local str = StringBuffer()
    str:append(move.piece)
    if move.relative then
      str:append(Relative.getRelativeString(move.relative))
    end
    if move.promote then
      str:append("成")
    elseif move.promote == false then
      str:append("不成")
    end
    return str:tostring()
  else
    local str = StringBuffer()
    str:append(move_format.special)
    if str:strlen() > 0 then
      str:prepend(Color.tostring(Color.reverse(self:getTeban())))
    end
    return str:tostring()
  end
end

--- 現局面から指し手strを指す
function M:appendMove(str)
  local move  = nil
  if type(str) == "string" then
    move  = Parser.parseMove(str)
  elseif type(str) == "table" then
    move  = str
  end
  assert(move)
  local tesuu = self:getTesuu()
  local move_format = {}
  if type(move) == "table" then
    move_format.move  = move
  elseif type(move) == "string" then
    move_format.special = move
  end
  --move_format = self:normalize(move_format, self.jkf.moves[tesuu])
  move_format = self:normalize(move_format)
  local branch, num, info = self:getBranch()
  -- TODO fork
  local next_move_format  = branch[num + 1]
  if next_move_format == nil then
    table.insert(branch, move_format)
  elseif self:equal(move_format, self:getMoveFormat(self:getTesuu() + 1)) then
    -- do nothing
  elseif next_move_format.forks then
    local append  = true
    --print("search forks")
    -- TODO comment
    while self.branch_info[#self.branch_info] ~= info do
      table.remove(self.branch_info)
    end
    for i = 1, #next_move_format.forks do
      --print("do equal")
      if self:equal(next_move_format.forks[i][1], move_format) then
        append  = false
        --print("exist fork")
        table.insert(self.branch_info, {
          num   = num + 1,
          fork  = i,
        })
        break
      end
    end
    if append then
      --print("append fork")
      -- moves.forks[i] => MoveFormat[]であることに注意
      table.insert(next_move_format.forks,{
        move_format
      })
      table.insert(self.branch_info, {
        num   = num + 1,
        fork  = #next_move_format.forks,
      })
    end
  else
    --print("new fork")
    -- TODO comment
    while self.branch_info[#self.branch_info] ~= info do
      table.remove(self.branch_info)
    end
    next_move_format.forks  = {}
    -- moves.forks[i] => MoveFormat[]であることに注意
    table.insert(next_move_format.forks, {
      move_format,
    })
    table.insert(self.branch_info, {
      num   = num + 1,
      fork  = #next_move_format.forks,
    })
  end
  --[[
  self.jkf.moves[tesuu + 1] = {
    move = move,
  }
  --]]
  --self:go(tesuu + 1)
  self:forward()
  return self
end

--- 現局面以降の手を削除する
function M:removeMove()
  -- TODO stub
  local branch, num, info = self:getBranch()
  while self.branch_info[#self.branch_info] ~= info do
    table.remove(self.branch_info)
  end
  while #branch > num do
    table.remove(branch)
  end
  self:backward()
  if num == 1 and branch ~= self.jkf.moves then
    local branch, num = self:getBranch(self:getTesuu())
    local move_format = branch[num + 1]
    table.remove(move_format.forks, info.fork)
    table.remove(self.branch_info)
  else
    table.remove(branch)
  end
end

function M:equal(move_format1, move_format2)
  assert(move_format1)
  assert(move_format2)
  if  move_format1.special and move_format2 and
      move_format1.special == move_format2.special then
    return true
  end
  local move1 = move_format1.move
  local move2 = move_format2.move
  if move1 == nil or move2 == nil then
    return false
  end
  -- move
  if move1.from then
    if move2.from == nil then
      return false
    end
    --print("move1.from.x: " .. move1.from.x)
    --print("move2.from.x: " .. move2.from.x)
    if move1.from.x ~= move2.from.x or move1.from.y ~= move2.from.y then
      return false
    end
    if move1.to.x ~= move2.to.x or move1.to.y ~= move2.to.y then
      return false
    end
    if move1.promote ~= move2.promote then
      return false
    end
  -- hit
  else
    if move1.piece ~= move2.piece then
      return false
    end
    if move1.to.x ~= move2.to.x or move1.to.y ~= move2.to.y then
      return false
    end
  end
  return true
end

--- 現局面のコメントを返す
-- @treturn {string, ...}
function M:getComments()
  --local move_format = assert(self.jkf.moves[self:getTesuu()])
  local move_format = assert(self:getMoveFormat())
  return move_format.comments
end

function M:addComment(str)
  local move_format = assert(self:getMoveFormat())
  if move_format.comments == nil then
    move_format.comments  = {}
  end
  table.insert(move_format.comments, str)
end

--- 現局面の指し手の情報を返す
function M:getCurrentMoveFormat()
  -- TODO 分岐
  --return assert(self.jkf.moves[self:getTesuu()])
  return assert(self:getMoveFormat())
end

--- 一手進める
function M:forward()
  -- TODO 分岐
  --local tesuu = self.tesuu + 1
  --local move_format = self.jkf.moves[tesuu]
  local move_format = self:getMoveFormat(self:getTesuu() + 1)
  if move_format == nil then
    --print("nil move_format")
    return
  end

  self.tesuu  = self.tesuu + 1

  local move  = move_format.move
  if move then
    if move.from then
      self.position:move(
        move.from.x,  move.from.y,
        move.to.x,    move.to.y,
        move.piece,   move.color,
        move.capture, move.promote,
        move.castling, move.enpassant
      )
      -- castling
      if move.piece == Misc.K then
        if self:getTesuu() < self.castling[move.color] then
          self.castling[move.color] = self:getTesuu()
        end
      end
      -- en passant?
      if move.piece == Misc.P then
        if move.from.y - move.to.y == 2 then
          self.enpassant  = {
            x = move.from.x,
            y = move.from.y - 1,
          }
        elseif move.from.y - move.to.y == -2 then
          self.enpassant  = {
            x = move.from.x,
            y = move.from.y + 1,
          }
        else
          self.enpassant  = {}
        end
      else
        self.enpassant  = {}
      end
    else
      self.position:hit(
        move.to.x,  move.to.y,
        move.piece, move.color
      )
    end
  end
end

--- 分岐を1つ戻る
--
function M:gobackOrigin()
  local branch, remain  = self:getBranch()
  for i = remain, 1, -1 do
    --print("goback " .. i)
    self:backward()
  end
  --print("remove branch_info")
  table.remove(self.branch_info)
end

function M:goFork(num)
  local tesuu = self:getTesuu()
  local branch, remain  = self:getBranch(tesuu - 1)
  local current_branch  = branch
  self:tail()
  while true do
    branch  = self:getBranch()
    if current_branch ~= branch then
      self:gobackOrigin()
    else
      break
    end
  end
  self:go(tesuu)
  local move_format = self:getMoveFormat()
  self:backward()
  if num > 0 and move_format.forks and move_format.forks[num] then
    local branch, remain = self:getBranch()
    table.insert(self.branch_info, {
      num = remain + 1,
      fork  = num,
    })
  end
  self:forward()
end

--- 一手戻る
function M:backward()
  -- TODO 分岐
  if self:getTesuu() == 0 then
    return
  end
  --local tesuu = self.tesuu
  --local move_format = self.jkf.moves[tesuu]
  local branch, num = self:getBranch()
  local move_format = branch[num]
  if move_format == nil then
    -- TODO error?
    return
  end

  self.tesuu  = self.tesuu - 1
  local move  = move_format.move

  if move then
    if move.from then
      self.position:unmove(
        move.from.x,  move.from.y,
        move.to.x,    move.to.y,
        move.piece,   move.color,
        move.capture, move.promote,
        move.castling, move.enpassant
      )
      if move.piece == Misc.K or move.piece == Misc.R then
        if self:getTesuu() < self.castling[move.color] then
          self.castling[move.color] = 1000
        end
      end
    else
      self.position:unhit(
        move.to.x,  move.to.y,
        move.piece, move.color
      )
    end
  end
  -- en passant
  move_format = self:getMoveFormat()
  move  = move_format.move
  if move and move.piece == Misc.P then
    if move.from.y - move.to.y == 2 then
      self.enpassant  = {
        x = move.from.x,
        y = move.from.y - 1,
      }
    elseif move.from.y - move.to.y == -2 then
      self.enpassant  = {
        x = move.from.x,
        y = move.from.y + 1,
      }
    else
      self.enpassant  = {}
    end
  else
    self.enpassant  = {}
  end
end

--- tesuu手目に移動する
-- @tparam int[opt=0] tesuu
function M:go(tesuu)
  tesuu = tesuu or 0
  local diff = tesuu - self:getTesuu()
  if diff == 0 then
    return
  elseif diff > 0 then
    for _ = 1, diff do
      self:forward()
    end
  else
    for _ = 1, - diff do
      self:backward()
    end
  end
end

--- 初手に移動する
function M:head()
  self:go(0)
end

--- 最終手に移動する
function M:tail()
  local current = self:getCurrentMoveFormat()
  local prev
  repeat
    prev  = current
    self:forward()
    current = self:getCurrentMoveFormat()
  until prev == current
end

function M:getForksNum()
  local branch, remain = self:getBranch()
  local move_format = branch[remain + 1]
  if move_format then
    if move_format.forks then
      return #move_format.forks + 1
    else
      return 1
    end
  end
  return 0
end

function M:getForks()
  local tbl = {}
  local branch, remain = self:getBranch()
  local move_format = branch[remain + 1]
  if move_format then
    table.insert(tbl, move_format)
    if move_format.forks then
      for _, v in ipairs(move_format.forks) do
        table.insert(tbl, v[1])
      end
    end
  end
  return tbl
end

function M:getPosition()
  return {
    color = self:getTeban(),
    board = self.position:getBoard(),
    hands = {
      [Color.BLACK] = self.position:getHands(Color.BLACK),
      [Color.WHITE] = self.position:getHands(Color.WHITE),
    },
  }
end

function M:generateMoves()
  local moves = {}
  local move_moves  = self.position:moveGenerateMove(self:getTeban(), self.enpassant)
  local hit_moves   = self.position:moveGenerateHit(self:getTeban())
  local king_moves  = self.position:moveGenerateKing(self:getTeban(), self.castling[self:getTeban()] > self:getTesuu())
  --local king_moves  = self.position:moveGenerateKing(self:getTeban(), true)
  local clone = Clone(self)
  for _, v in ipairs({move_moves, hit_moves, king_moves}) do
    for _, v in ipairs(v) do
      -- 連続王手の千日手になる手を除外する
      --print(v.piece, v.from.x, v.from.y, "->", v.to.x, v.to.y)
      clone:appendMove(v)
      if clone:isPerpetualCheck() == false then
        table.insert(moves, v)
      end
      clone:removeMove()
    end
  end
  return moves
end

-- 現局面が4回繰り返されたか
function M:isRepetition(check)
  local current_tesuu = self:getTesuu()
  local repetition_id = nil
  local has_checked = true
  local tesuu = 0
  repeat
    tesuu = self:getTesuu()
    local _, sfen = self:toSfen()
    local id  = sfen.position .. " " .. sfen.turn .. " " .. sfen.hands
    if self._sfen_map[id] then
      self._sfen_map[id] = self._sfen_map[id] + 1
    else
      self._sfen_map[id] = 1
    end
    if self._sfen_map[id] == 3 then
      repetition_id = id
      break
    end
    if check then
      has_checked = has_checked and self.position:isCheck(self:getTeban())
    end
    if has_checked == false then
      break
    end
    -- 調べるのは手番側だけ
    for i=1, 2 do
      self:backward()
    end
  until tesuu == self:getTesuu()

  self:go(current_tesuu)

  if repetition_id then
    if has_checked then
      return true
    else
      return true
    end
  end
  return false
end

function M:isCheck(color)
  local color = color or self:getTeban()
  return self.position:isCheck(color)
end

-- 現局面が千日手か
function M:isSennichite()
  self._sfen_map  = {}
  return self:isRepetition(false)
end

-- 現局面が連続王手の千日手か
function M:isPerpetualCheck()
  self._sfen_map  = {}
  return self:isRepetition(true)
end

function M:getPiece(x, y)
  return self.position:getPiece(x, y)
end

function M:setHeader(key, value)
  --print("setHeader: " .. key)
  if key then
    self.jkf.header[key]  = value
  end
end

function M:getHeader(key)
  --print("getHeader: " .. key)
  return self.jkf.header[key]
end

function M:toUCI()
  local str       = StringBuffer()
  local init, sep = Parser.UCI.toUCIinit(self.jkf.initial)
  local moves     = {}
  str:append(table.concat(init, sep))
  local current = self:getTesuu()
  if current > 0 then
    self:head()
    str:append(sep):append("moves")
    while self:getTesuu() < current do
      self:forward()
      local move  = Parser.UCI.toUCImove(self:getMoveFormat(), self:getTesuu())
      if move then
        str:append(sep):append(move)
        table.insert(moves, move)
      else
        -- TODO stub
        break
      end
    end
  end
  return str:tostring(), init, moves
end

function M:toSfen(reverse)
  local reverse = reverse or false
  local str = StringBuffer()
  local position  = StringBuffer()
  local hands = StringBuffer()
  local turn  = StringBuffer()
  local tesuu = StringBuffer()
  local array = {}
  for y = 8, 1, -1 do
    local cnt = 0
    for x = 1, 8 do
      local x, y  = x, y
      if reverse then
        x = 9 - x
        y = 9 - y
      end
      local piece = self.position:getPiece(x, y)
      if piece.kind and piece.color then
        if cnt > 0 then
          position:append(cnt)
          cnt = 0
        end
        local p = piece.kind
        local color = piece.color
        if reverse then
          color = Color.reverse(color)
        end
        if color == Color.WHITE then
          p = string.upper(p)
        else
          p = string.lower(p)
        end
        position:append(p)
      else
        cnt = cnt + 1
      end
    end
    if cnt > 0 then
      position:append(cnt)
      cnt = 0
    end
    if y > 1 then
      position:append("/")
    end
  end

  str:append(position):append(" ")

  if self:getTeban() == Color.BLACK then
    turn:append("b")
  elseif self:getTeban() == Color.WHITE then
    turn:append("w")
  else
    -- TODO error
  end

  str:append(turn):append(" ")

  --[[
  for _, color in ipairs(Color.LIST) do
    for _, kind in ipairs(Misc.HAND) do
      local color = color
      if reverse then
        color = Color.reverse(color)
      end
      if kind ~= Misc.K then
        local num = self.position:getHandPiece(color, kind)
        if num > 0 then
          local p = kind
          if color == Color.WHITE then
            p = string.upper(p)
          end
          if num > 1 then
            hands:append(num)
          end
          hands:append(p)
        end
      end
    end
  end

  if hands:strlen() == 0 then
    hands:append("-")
  end
  str:append(hands)

  str:append(" ")
  --]]

  tesuu:append(self:getTesuu())
  str:append(tesuu)

  return str:tostring(), {
    position  = position:tostring(),
    turn  = turn:tostring(),
    hands = hands:tostring(),
    tesuu = tesuu:tostring(),
  }
end

return M
