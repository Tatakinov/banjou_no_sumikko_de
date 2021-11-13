local Class   = require("class")
local Color   = require("kifu_player.color")
local CSA     = require("kifu_player.csa")
local InitialPreset = require("kifu_player.initial_preset")
local Misc    = require("kifu_player.misc")
local Parser  = require("kifu_player.parser.usi")
local Relative  = require("kifu_player.relative")

-- @module Position

local M = Class()
M.__index = M

function M:_init()
  --
  self.board  = {}
  for i = 1, 9 do
    self.board[i] = {}
    for j = 1, 9 do
      self.board[i][j]  = {}
    end
  end
  --
  self.hands  = {}
  for _, color in ipairs(Color.LIST) do
    self.hands[color] = {}
    for _, kind in ipairs(CSA.HAND) do
      self.hands[color][kind] = 0
    end
  end
end

--- 初期局面を設定する
-- @tparam string sfen
function M:setInitPosition(initial)
  initial = initial or InitialPreset.HIRATE
  if type(initial) == "string" then
    local sfen  = InitialPreset.toSfen(initial)
    if sfen then
      return self:setInitPosition(Parser.parseInit(sfen))
    else
      return self:setInitPosition(Parser.parseInit(initial))
    end
  elseif type(initial) == "table" then
    self:_init()
    for i = 1, 9 do
      self.board[i] = {}
      for j = 1, 9 do
        self.board[i][j]  = initial.board[i][j]
      end
    end
    for _, color in ipairs({Color.BLACK, Color.WHITE}) do
      self.hands[color] = {}
      for _, v in ipairs(CSA.HAND) do
        self.hands[color][v]  = initial.hands[color][v]
      end
    end
  end
end

--- x, yの駒情報を設定する
-- @tparam int x
-- @tparam int y
-- @tparam string piece
-- @tparam color color
function M:setPiece(x, y, piece, color)
  self.board[x][y].kind   = piece
  self.board[x][y].color  = color
end

--- x, yの駒情報を取得する
-- @tparam int x
-- @tparam int y
-- @treturn {kind=string,color=color}
function M:getPiece(x, y)
  return assert(self.board[x][y])
end

--- colorの持ち駒pieceの数を設定する
-- @tparam color color
-- @tparam string piece
-- @tparam int num
function M:setHandPiece(color, piece, num)
  assert(type(num) == "number")
  assert(num >= 0)
  self.hands[color][piece]      = num
end

--- colorの持ち駒pieceの数を取得する
-- @tparam color color
-- @tparam string piece
-- @treturn int
function M:getHandPiece(color, piece)
  return assert(self.hands[color][piece])
end


--
--capture: {x=x, y=y, piece=kind, color=color}
--[[
function M:move(from, to, piece, color, capture[], promote)
end
function M:unmove(from, to, piece, color, capture[], promote)
end
--]]

--- 駒を一手動かす
-- @tparam int from_x
-- @tparam int from_y
-- @tparam int to_x
-- @tparam int to_y
-- @tparam string piece
-- @tparam color color
-- @tparam[opt=nil] string capture
-- @tparam[opt=nil] boolean promote
function M:move(from_x, from_y,  to_x, to_y, piece, color, capture, promote)
  assert(tonumber(from_x))
  assert(tonumber(from_y))
  assert(tonumber(to_x))
  assert(tonumber(to_y))
  assert(piece)
  assert(tonumber(color))
  self.board[from_x][from_y].kind   = nil
  self.board[from_x][from_y].color  = nil
  self.board[to_x][to_y].color  = color
  if promote then
    self.board[to_x][to_y].kind   = Misc.promote(piece)
  else
    self.board[to_x][to_y].kind   = piece
  end
  if capture then
    self.hands[color][Misc.unpromote(capture)] =
        self.hands[color][Misc.unpromote(capture)] + 1
  end
end

--- 駒を一手戻す
-- @tparam int from_x
-- @tparam int from_y
-- @tparam int to_x
-- @tparam int to_y
-- @tparam string piece
-- @tparam color color
-- @tparam[opt=nil] string capture
-- @tparam[opt=nil] boolean promote
function M:unmove(from_x, from_y, to_x, to_y, piece, color, capture, promote)
  self.board[from_x][from_y].color  = color
  if promote then
    self.board[from_x][from_y].kind   = Misc.unpromote(piece)
  else
    self.board[from_x][from_y].kind   = piece
  end
  if capture then
    self.hands[color][Misc.unpromote(capture)] =
        self.hands[color][Misc.unpromote(capture)] - 1
    self.board[to_x][to_y].kind   = capture
    self.board[to_x][to_y].color  = Color.reverse(color)
  else
    self.board[to_x][to_y].kind   = nil
    self.board[to_x][to_y].color  = nil
  end
end

--- 駒を打つ
-- @tparam int to_x
-- @tparam int to_y
-- @tparam string piece
-- @tparam color color
function M:hit(to_x, to_y, piece, color)
  self.board[to_x][to_y].kind   = piece
  self.board[to_x][to_y].color  = color
  self.hands[color][piece]      = self.hands[color][piece] - 1
end

--- 駒を戻す
-- @tparam int to_x
-- @tparam int to_y
-- @tparam string piece
-- @tparam color color
function M:unhit(to_x, to_y, piece, color)
  self.board[to_x][to_y].kind   = nil
  self.board[to_x][to_y].color  = nil
  self.hands[color][piece]      = self.hands[color][piece] + 1
end

--- x, yにある駒の移動出来る位置を取得
-- @tparam int x
-- @tparam int y
-- @treturn {{x=int,y=int},...}
function M:getRangeFrom(x, y)
  local movable_list  = {}
  local piece = self:getPiece(x, y)
  if piece.kind and piece.color then
    local list =
        Relative.getRelativeList(Color.reverse(piece.color), piece.kind)
    for _, v in pairs(list) do
      local upper_bound = v.running and 9 or 1
      for i = 1, upper_bound do
        local x = x + v.x * i
        local y = y + v.y * i
        if x < 1 or x > 9 or y < 1 or y > 9 then
          break
        end
        local to  = self.board[x][y]
        -- 味方の駒が居る場所には移動できない
        if to.color and to.color == piece.color then
          break
        end
        table.insert(movable_list, {x = x, y = y})
        -- 敵の駒より奥には移動できない
        if to.color and Color.reverse(to.color) == piece.color then
          break
        end
      end
    end
  end -- if piece is valid
  return movable_list
end

--- 位置(x, y)に移動出来るcolorの駒の位置を取得
-- @tparam int x
-- @tparam int y
-- @tparam[opt] color color
-- @treturn {{x=int,y=int},...}
function M:getRangeTo(x, y, color)
  local piece = self:getPiece(x, y)
  local movable_list  = {}
  if piece.color == color then
    return movable_list
  end
  for _, kind in ipairs(CSA.ALL) do
    local list =
        Relative.getRelativeList(color, kind)
        --Relative.getRelativeList(Color.reverse(color), kind)
    for _, v in pairs(list) do
      local upper_bound = v.running and 9 or 1
      for i = 1, upper_bound do
        local x = x + v.x * i
        local y = y + v.y * i
        if x < 1 or x > 9 or y < 1 or y > 9 then
          break
        end
        local piece = self:getPiece(x, y)
        if piece.kind and piece.color then
          if piece.color == color and piece.kind == kind then
            table.insert(movable_list, {x = x, y = y})
          end
          break
        end
      end
    end
  end -- if piece is valid
  return movable_list
end

--- colorの持ち駒pieceを打てる位置を取得
-- @tparam string piece
-- @tparam color color
function M:getRangeHit(piece, color)
  local movable_list  = {}
  local y_min = 1
  local y_max = 9
  if Color.BLACK == color then
    if CSA.FU == piece or CSA.KY == piece then
      y_min = 2
    elseif CSA.KE == piece then
      y_min = 3
    end
  elseif Color.WHITE == color then
    if CSA.FU == piece or CSA.KY == piece then
      y_max = 8
    elseif CSA.KE == piece then
      y_max = 7
    end
  end
  for i = 1, 9 do
    local nifu  = false
    if CSA.FU == piece then
      for j = 1, 9 do
        local piece = self:getPiece(i, j)
        if CSA.FU == piece.kind and color == piece.color then
          nifu  = true
          break
        end
      end
    end
    if nifu == false then
      for j = y_min, y_max do
        local piece = self:getPiece(i, j)
        if nil == piece.kind and nil == piece.color then
          table.insert(movable_list, {x = i, y = j})
        end
      end
    end
  end
  return movable_list
end

--- color玉に王手が掛かっているか
-- @tparam color color
-- @treturn boolean
function M:isCheck(color)
  local x, y
  for i = 1, 9 do
    for j = 1, 9 do
      local piece = self:getPiece(i, j)
      if piece.color == color and piece.kind == CSA.OU then
        x = i
        y = j
        break
      end
    end
    if x and y then
      break
    end
  end
  assert(x and y)
  local list  = self:getRangeTo(x, y, Color.reverse(color))
  assert(list)
  return #list > 0
end

--- color玉が詰んでいるか
-- @tparam color color
-- @treturn boolean
function M:isCheckmate(color)
  local move_moves  = self:moveGenerateMove(color)
  local hit_moves   = self:moveGenerateHit(color)
  local king_moves  = self:moveGenerateKing(color)
  assert(move_moves and hit_moves and king_moves)
  return (#move_moves + #hit_moves + #king_moves) == 0
end

--- pinされているcolorの駒の位置を返す
function M:pinned(color)
  local pinned_list = {}
  for x = 1, 9 do
    for y = 1, 9 do
      --print("board[" .. x .. "][" .. y .. "]")
      local piece = self:getPiece(x, y)
      if piece.color == Color.reverse(color) then
        local kind  = assert(piece.kind)
        if kind == CSA.KY
            or kind == CSA.KA or kind == CSA.UM
            or kind == CSA.HI or kind == CSA.RY
            then
          local list =
              Relative.getRelativeList(Color.reverse(piece.color), Misc.unpromote(piece.kind))
          for _, v in pairs(list) do
            local upper_bound = v.running and 8 or 1
            for i = 1, upper_bound do
              local x = x + v.x * i
              local y = y + v.y * i
              if x < 1 or x > 9 or y < 1 or y > 9 then
                break
              end
              local to  = self:getPiece(x, y)
              if to.color then
                if to.color == color then
                  table.insert(pinned_list, {x = x, y = y})
                  break
                end
              end -- to.color
            end -- for i, v
          end -- for _, v
        end -- if kind
      end -- if color
    end -- for y
  end -- for x
  return pinned_list
end -- func

--- colorの指し手(移動)を生成する
-- @tparam color color
-- @treturn table
function M:moveGenerateKing(color)
  local moves = {}
  for x = 1, 9 do
    for y = 1, 9 do
      --print("board[" .. x .. "][" .. y .. "]")
      local piece = self:getPiece(x, y)
      if piece.color == color then
        local kind  = assert(piece.kind)
        if kind == CSA.OU then
          local list  = self:getRangeFrom(x, y)
          for i = 1, #list do
            local to  = list[i]
            --print("x: " .. to.x .. " y: " .. to.y)
            local capture = self:getPiece(to.x, to.y).kind
            local check = false
            self:move(x, y, to.x, to.y, kind, color, capture, nil)
            check = self:isCheck(color)
            self:unmove(x, y, to.x, to.y, kind, color, capture, nil)
            if check == false then
              table.insert(moves, {
                color = color,
                from  = {
                  x = x,
                  y = y,
                },
                to    = {
                  x = to.x,
                  y = to.y,
                },
                piece = kind,
                capture = capture,
              })
            end
          end
        end
      end
    end
  end
  --print("moveKing:" .. #moves)
  return moves
end

--- colorの指し手(移動)を生成する
-- @tparam color color
-- @treturn table
function M:moveGenerateMove(color)
  local moves = {}
  local pinned_pieces = self:pinned(color)
  local checked = self:isCheck(color)
  if checked then
    local king  = {}
    for i = 1, 9 do
      for j = 1, 9 do
        local piece = self:getPiece(i, j)
        if piece.color == color and piece.kind == CSA.OU then
          king.x = i
          king.y = j
          break
        end
      end
      if king.x and king.y then
        break
      end
    end
    local checkers = self:getRangeTo(king.x, king.y, Color.reverse(color))
    --  両王手
    if #checkers > 1 then
      return moves
    end
    local checker = checkers[1]
    local list    = self:getRangeFrom(checker.x, checker.y, Color.reverse(color))
    --  自分の駒がある場所は外す
    local tmp = {}
    for _, v in ipairs(list) do
      local piece = self:getPiece(v.x, v.y)
      if piece.color ~= color then
        table.insert(tmp, v)
      end
    end
    list  = tmp
    --  王手をしている駒を取る手を考慮する
    table.insert(list, checker)
    for _, to in ipairs(list) do
      --print("x: " .. to.x .. " y: " .. to.y)
      for _, from in ipairs(self:getRangeTo(to.x, to.y, color)) do
        local piece = self:getPiece(from.x, from.y)
        local kind  = assert(piece.kind)
        local capture = self:getPiece(to.x, to.y)
        if capture.kind and capture.color then
          capture = capture.kind
        else
          capture = nil
        end
        if kind ~= CSA.OU then
          local check = false
          --print("x: " .. from.x .. " y:" .. from.y .. " x: " .. to.x .. " y: " .. to.y)
          self:move(from.x, from.y, to.x, to.y, kind, color, capture, nil)
          check = self:isCheck(color)
          --print("check: " .. tostring(check))
          self:unmove(from.x, from.y, to.x, to.y, kind, color, capture, nil)
          if check == false then
            local promote, force  = Misc.canPromote(color, from.y, to.y, kind)
            if promote and force == false then
              table.insert(moves, {
                color = color,
                from  = {
                  x = from.x,
                  y = from.y,
                },
                to    = {
                  x = to.x,
                  y = to.y,
                },
                piece = kind,
                promote = true,
                capture = capture,
              })
            end
            table.insert(moves, {
              color = color,
              from  = {
                x = from.x,
                y = from.y,
              },
              to    = {
                x = to.x,
                y = to.y,
              },
              piece = kind,
              capture = capture,
            })
          end
        end
      end
    end
  else
    for x = 1, 9 do
      for y = 1, 9 do
        --print("board[" .. x .. "][" .. y .. "]")
        local piece = self:getPiece(x, y)
        if piece.color == color then
          local kind  = assert(piece.kind)
          if kind ~= CSA.OU then
            local list  = self:getRangeFrom(x, y)
            for i = 1, #list do
              local to  = list[i]
              local capture = self:getPiece(to.x, to.y)
              if capture.kind and capture.color then
                capture = capture.kind
              else
                capture = nil
              end
              --
              local check = false
              local pinned  = false
              for _, v in ipairs(pinned_pieces) do
                if v.x == x and v.y == y then
                  pinned  = true
                end
              end
              if pinned then
                self:move(x, y, to.x, to.y, kind, color, capture, nil)
                check = self:isCheck(color)
                self:unmove(x, y, to.x, to.y, kind, color, capture, nil)
              end
              if check == false then
                local promote, force  = Misc.canPromote(color, y, to.y, kind)
                if promote then
                  table.insert(moves, {
                    color = color,
                    from  = {
                      x = x,
                      y = y,
                    },
                    to    = {
                      x = to.x,
                      y = to.y,
                    },
                    piece = kind,
                    promote = true,
                    capture = capture,
                  })
                end
                if force == false then
                  table.insert(moves, {
                    color = color,
                    from  = {
                      x = x,
                      y = y,
                    },
                    to    = {
                      x = to.x,
                      y = to.y,
                    },
                    piece = kind,
                    capture = capture,
                  })
                end
              end
            end
          end -- kind ~= OU
        end -- if piece.color == color
      end -- for y
    end -- for x
  end -- checked
  --print("moveMove: " .. #moves)
  return moves
end

--- colorの指し手(打)を生成する
-- @tparam color color
-- @treturn table
function M:moveGenerateHit(color)
  local moves = {}
  local checked = self:isCheck(color)
  if checked then
    local king  = {}
    for i = 1, 9 do
      for j = 1, 9 do
        local piece = self:getPiece(i, j)
        if piece.color == color and piece.kind == CSA.OU then
          king.x = i
          king.y = j
          break
        end
      end
      if king.x and king.y then
        break
      end
    end

    --  両王手/隣接王手は何も生成できない
    local checkers = self:getRangeTo(king.x, king.y, Color.reverse(color))
    if #checkers > 1 then
      return moves
    end
    local checker = checkers[1]
    if math.abs(king.x - checker.x) <= 1 and
        math.abs(king.y - checker.y) <= 1
        then
      return moves
    end

    local list    = self:getRangeFrom(checker.x, checker.y, Color.reverse(color))
    --  自分の駒がある場所は外す
    local tmp = {}
    for _, v in ipairs(list) do
      local piece = self:getPiece(v.x, v.y)
      if piece.color ~= color then
        table.insert(tmp, v)
      end
    end
    list  = tmp
    for _, to in ipairs(list) do
      for _, kind in ipairs(CSA.HAND) do
        local n = self:getHandPiece(color, kind)
        if n > 0 then
          local nifu  = false
          if not(nifu) then
            if kind == CSA.FU then
              for y = 1, 9 do
                local piece = self:getPiece(to.x, y)
                if color == piece.color and
                    kind == piece.kind then
                    nifu  = true
                end
              end
            end
          end -- not(nifu)
          local illegal_hit = nifu
          if not(illegal_hit) then
            if kind == CSA.FU or kind == CSA.KY then
              if color == Color.BLACK then
                if to.y == 1 then
                  illegal_hit = true
                end
              elseif color == Color.WHITE then
                if to.y == 9 then
                  illegal_hit = true
                end
              end
            elseif kind == CSA.KE then
              if color == Color.BLACK then
                if to.y == 1 or to.y == 2 then
                  illegal_hit = true
                end
              elseif color == Color.WHITE then
                if to.y == 9 or to.y == 8 then
                  illegal_hit = true
                end
              end
            end
          end -- not(illegal_hit)
          local check = illegal_hit
          if not(check) then
            self:hit(to.x, to.y, kind, color)
            check = check or self:isCheck(color)
            --  打ち歩詰め
            if kind == CSA.FU then
              local pawn_attack_pos = {
                x = to.x,
                y = to.y - 1,
              }
              if color == Color.WHITE then
                pawn_attack_pos.y = to.y + 1
              end
              local piece = self:getPiece(pawn_attack_pos.x, pawn_attack_pos.y)
              if piece.color == Color.reverse(color) and piece.kind == CSA.OU then
                check = check or
                    (self:isCheck(Color.reverse(color)) and
                      self:isCheckmate(Color.reverse(color)))
              end
            end
            self:unhit(to.x, to.y, kind, color)
            if check == false then
              table.insert(moves, {
                color = color,
                to    = {
                  x = to.x,
                  y = to.y,
                },
                piece     = kind,
                relative  = Relative.H,
              })
            end
          end -- not(check)
        end -- n > 0
      end -- for CSA.HAND
    end -- for #list
  else
    for _, kind in ipairs(CSA.HAND) do
      local n = self:getHandPiece(color, kind)
      if n > 0 then
        local list  = self:getRangeHit(kind, color)
        for i = 1, #list do
          local to  = list[i]
          local check = false
          self:hit(to.x, to.y, kind, color)
          check = self:isCheck(color)
          --  打ち歩詰め
          if kind == CSA.FU then
            local pawn_attack_pos = {
              x = to.x,
              y = to.y - 1,
            }
            if color == Color.WHITE then
              pawn_attack_pos.y = to.y + 1
            end
            local piece = self:getPiece(pawn_attack_pos.x, pawn_attack_pos.y)
            if piece.color == Color.reverse(color) and piece.kind == CSA.OU then
              check = check or
                  (self:isCheck(Color.reverse(color)) and
                    self:isCheckmate(Color.reverse(color)))
            end
          end
          self:unhit(to.x, to.y, kind, color)
          if check == false then
            table.insert(moves, {
              color = color,
              to    = {
                x = to.x,
                y = to.y,
              },
              piece     = kind,
              relative  = Relative.H,
            })
          end
        end -- for #list
      end -- if n > 0
    end -- for CSA.HAND
  end -- checked
  --print("moveHit: " .. #moves)
  return moves
end

function M:getBoard()
  local board = {}
  for i = 1, 9 do
    board[i]  = {}
    for j = 1, 9 do
      board[i][j] = self.board[i][j]
    end
  end
  return board
end

function M:getHands(color)
  assert(color)
  local hands = {}
  for k, v in pairs(self.hands[color]) do
    hands[k]  = v
  end
  return hands
end

function M:dump()
  for y = 1, 9 do
    local line  = ""
    for x = 9, 1, -1 do
      if self.board[x][y].kind then
        if self.board[x][y].color == Color.BLACK then
          line = line .. string.upper(self.board[x][y].kind)
        else
          line = line .. string.lower(self.board[x][y].kind)
        end
      else
          line = line .. "--"
      end
    end
    print(line)
  end
end

return M
