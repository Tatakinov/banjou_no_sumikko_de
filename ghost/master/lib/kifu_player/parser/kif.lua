local lpeg  = require("lpeg")
local Misc  = require("kifu_player.misc")
local Relative  = require("kifu_player.relative")
local StringBuffer  = require("string_buffer")
local utf8  = require("lua-utf8")

local M = {}

local function isPromote(s)
  if s == "成" then
    return true
  elseif s == "不成" then
    return false
  end
  return nil
end

local function isHit(s)
  if s == "打" then
    return true
  end
  return nil
end

local function isSame(s)
  return true
end

local Ascii   = lpeg.R("\x00\x7f")
local Number  = lpeg.R("09")
local MBHead  = lpeg.R("\xc2\xf4")
local MBData  = lpeg.R("\x80\xbf")
local Char    = Ascii + (MBHead * (MBData ^ 1))
local NL      = lpeg.S("\x0a")
local Space   = lpeg.S(" \t") + lpeg.P("　")
local HasFork = lpeg.S("+")

local ZenkakuNumber =
    lpeg.P("１") + lpeg.P("２") + lpeg.P("３")
    + lpeg.P("４") + lpeg.P("５") + lpeg.P("６")
    + lpeg.P("７") + lpeg.P("８") + lpeg.P("９")
local KanjiNumber =
    lpeg.P("一") + lpeg.P("二") + lpeg.P("三")
    + lpeg.P("四") + lpeg.P("五") + lpeg.P("六")
    + lpeg.P("七") + lpeg.P("八") + lpeg.P("九")

local Piece =
    lpeg.P("歩") + lpeg.P("と") + lpeg.P("香") + lpeg.P("成香")
    + lpeg.P("桂") + lpeg.P("成桂") + lpeg.P("銀") + lpeg.P("成銀")
    + lpeg.P("金") + lpeg.P("角") + lpeg.P("馬")
    + lpeg.P("飛") + lpeg.P("竜") + lpeg.P("龍") + lpeg.P("玉")
local OneCharPiece  = lpeg.P("杏") + lpeg.P("圭") + lpeg.P("全")

local HandNone  = lpeg.P("なし")
local HandNum = KanjiNumber
local Hand  = lpeg.Ct(lpeg.Ct(lpeg.Cg(Piece, "kind") * (lpeg.Cg(HandNum ^ 0, "num")) * lpeg.P("　")) ^ 0) + HandNone

local InitialBegin  = lpeg.P("  ９ ８ ７ ６ ５ ４ ３ ２ １") * NL
local InitialSep    = lpeg.P("+---------------------------+") * NL
local InitialDummyPiece = lpeg.P("・")
local InitialPiece  = lpeg.Ct(lpeg.Cg(lpeg.S(" v"), "color") * lpeg.Cg(InitialDummyPiece + OneCharPiece + Piece, "kind"))
local InitialLine   = lpeg.S("|") * lpeg.Ct((InitialPiece) ^ -9) * lpeg.S("|") * KanjiNumber * NL
local InitialPosition = lpeg.Ct(InitialBegin * InitialSep * lpeg.Cg(lpeg.Ct(InitialLine ^ -9), "initial") * InitialSep)

local Same  = lpeg.P("同")
local RelativePosition  = lpeg.P("右") + lpeg.P("直") + lpeg.P("左")
local RelativeAction  = lpeg.P("引") + lpeg.P("寄") + lpeg.P("上")
local RelativeHit = lpeg.P("打")
local Promote = lpeg.P("成") + lpeg.P("不成")

local MoveBegin = lpeg.Ct(lpeg.Cg(lpeg.P("手数----指手---------消費時間--") * (Space ^ 0), "move_begin"))

local Begin = lpeg.S("(")
local End   = lpeg.S(")")

local TimeSep = lpeg.S(":")
local TimeDiff  = (Space ^ 0) * lpeg.Cg(lpeg.Ct(lpeg.Cg(Number ^ 1, "m") * TimeSep * lpeg.Cg(Number ^ 1, "s")), "diff")
local TimeTotal = (Space ^ 0) * lpeg.Cg(lpeg.Ct(lpeg.Cg(Number ^ 1, "h") * TimeSep * lpeg.Cg(Number ^ 1, "m") * TimeSep * lpeg.Cg(Number ^ 1, "s")), "total")
local Time  = lpeg.Cg(lpeg.Ct(Begin * (Space ^ 0) * TimeDiff * (Space ^ 0) * lpeg.S("/") * (Space ^ 0) * TimeTotal * End), "time")

local Tesuu = lpeg.Cg((Number ^ 1) / tonumber, "tesuu")
local MoveFrom  = Begin * lpeg.Cg(lpeg.Ct(lpeg.Cg(Number / tonumber, "x") * lpeg.Cg(Number / tonumber, "y")), "from") * End
local MoveTo    = (lpeg.Cg(lpeg.Ct(lpeg.Cg(ZenkakuNumber / Misc.z2n, "x") * lpeg.Cg(KanjiNumber / Misc.k2n, "y")), "to") + lpeg.Cg((Same * (Space ^ 0)) / isSame, "same")) * lpeg.Cg(Piece / Misc.k2csa, "piece") * lpeg.Cg((Promote ^ -1) / isPromote, "promote")
local Sashite = lpeg.Cg(lpeg.Ct(MoveTo * (MoveFrom + lpeg.Cg(RelativeHit / isHit, "hit"))), "move")
local Special = lpeg.Cg(lpeg.P("投了") + lpeg.P("中断") + lpeg.P("パス"), "special")

local Move  = lpeg.Ct((Space ^ 0) * Tesuu * (Space ^ 0) * (Sashite + Special) * (Space ^ 0) * (Time ^ -1) * (HasFork ^ -1)) * NL

local HeaderSep   = lpeg.P("：")
local HeaderName  = lpeg.Cg((Char - NL - HeaderSep) ^ 0, "name")
local HeaderValue = lpeg.Cg((Char - NL) ^ 0, "value")
local Teban       = lpeg.Cg(lpeg.P("先手番") + lpeg.P("後手番") + lpeg.P("下手番") + lpeg.P("上手番"), "teban")

local Header  = lpeg.Ct(lpeg.Cg(lpeg.Ct(HeaderName * HeaderSep * HeaderValue * NL + Teban * NL), "header"))

local Comment = lpeg.S("#") * (Char - NL) ^ 0 * NL
local KifuComment = lpeg.Ct(lpeg.S("*") * lpeg.Cg((Char - NL) ^ 0, "comment") * NL)

local Grammar = lpeg.Ct((Header + InitialPosition + Teban + Comment + MoveBegin + Move + KifuComment + NL) ^ 0) * -1
local GrammarMove = lpeg.Ct(Sashite + Special) * -1

local function dump(t, indent)
  indent  = indent or ""
  for k, v in pairs(t) do
    if type(v) == "table" then
      print(indent, k, "= {")
      dump(v, indent .. "\t")
      print(indent, "}")
    else
      print(indent, k, v)
    end
  end
end

function M.parse(player, str)
  local sfen_position
  local sfen_blackhand
  local sfen_whitehand
  local sfen_teban  = "b"
  local t = lpeg.match(Grammar, str)
  if t then
    for i = 1, #t do
      local header  = t[i].header
      if header then
        player:setHeader(header.name, header.value)
        if header.name == "先手の持駒" then
          local t = lpeg.match(Hand, header.value)
          local str = StringBuffer()
          for i = 1, #t do
            local piece = t[i]
            if piece.num == "　" then
              str:append(string.upper(Misc.csa2sfen(Misc.k2csa(piece.kind))))
            else
              str:append(Misc.k2n(piece.num))
              str:append(string.upper(Misc.csa2sfen(Misc.k2csa(piece.kind))))
            end
          end
          sfen_blackhand  = str:tostring()
        end
        if header.name == "後手の持駒" then
          local t = lpeg.match(Hand, header.value)
          local str = StringBuffer()
          for i = 1, #t do
            local piece = t[i]
            if piece.num == "　" then
              str:append(string.lower(Misc.csa2sfen(Misc.k2csa(piece.kind))))
            else
              str:append(Misc.k2n(piece.num))
              str:append(string.lower(Misc.csa2sfen(Misc.k2csa(piece.kind))))
            end
          end
          sfen_whitehand  = str:tostring()
        end
        local teban = header.teban
        if teban == "後手番" or teban == "上手番" then
          sfen_teban = "w"
        end
      end
      local initial = t[i].initial
      if initial then
        local str = StringBuffer()
        for i = 1, 9 do
          for j = 1, 9 do
            local piece = initial[i][j]
            if piece.kind == "・" then
              str:append("1")
            else
              if piece.color == " " then
                str:append(string.upper(Misc.csa2sfen(Misc.k2csa(piece.kind))))
              elseif piece.color == "v" then
                str:append(string.lower(Misc.csa2sfen(Misc.k2csa(piece.kind))))
              end
            end
          end
          str:append("/")
        end
        if str:strlen() > 0 then
          sfen_position = string.sub(str:tostring(), 1, -2)
          sfen_position = string.gsub(sfen_position, "111111111", "9")
          sfen_position = string.gsub(sfen_position, "11111111", "8")
          sfen_position = string.gsub(sfen_position, "1111111", "7")
          sfen_position = string.gsub(sfen_position, "111111", "6")
          sfen_position = string.gsub(sfen_position, "11111", "5")
          sfen_position = string.gsub(sfen_position, "1111", "4")
          sfen_position = string.gsub(sfen_position, "111", "3")
          sfen_position = string.gsub(sfen_position, "11", "2")
        end
      end
      local move_begin  = t[i].move_begin
      if move_begin then
        -- 初期局面があるか調べる
        if sfen_position then
          local str   = StringBuffer()
          local hand  = StringBuffer()
          str:append(sfen_position):append(" "):append(sfen_teban):append(" ")
          if sfen_blackhand then
            hand:append(sfen_blackhand)
          end
          if sfen_whitehand then
            hand:append(sfen_whitehand)
          end
          if hand:strlen() == 0 then
            str:append("-")
          else
            str:append(hand)
          end
          str:append(" 1")
          --print("sfen: " .. str:tostring())
          player:setPosition(str:tostring())
        else
          --print("sfen: startpos")
          player:setPosition()
        end
        --print("move_begin")
      end
      local move  = t[i].move
      if move then
        if move.hit then
          move.relative = "H"
        end
        player:go(t[i].tesuu - 1)
        player:appendMove(move)
      end
      if t[i].special then
        player:appendMove(t[i].special)
      end
      local comment = t[i].comment
      if comment then
        player:addComment(comment)
      end
    end
  else
    print("syntax error:", line, col)
  end
end

function M.parseMove(str)
  local t = lpeg.match(GrammarMove, str)
  if t.move then
    return t.move
  elseif t.special then
    return Misc.special2csa(t.special)
  end
  return nil
end

local function evaluate(t)
  local sfen_position
  local sfen_blackhand
  local sfen_whitehand
  local sfen_teban  = "b"
  for i = 1, #t do
    --print(t[i])
    local header  = t[i].header
    if header then
      print(header.name .. ": " .. header.value)
      if header.name == "先手の持駒" then
        local t = lpeg.match(Hand, header.value)
        local str = StringBuffer()
        for i = 1, #t do
          local piece = t[i]
          if piece.num == "　" then
            str:append(string.upper(Misc.csa2sfen(Misc.k2csa(piece.kind))))
          else
            str:append(Misc.k2n(piece.num))
            str:append(string.upper(Misc.csa2sfen(Misc.k2csa(piece.kind))))
          end
        end
        sfen_blackhand  = str:tostring()
        print("BlackHand: " .. sfen_blackhand)
      end
      if header.name == "後手の持駒" then
        local t = lpeg.match(Hand, header.value)
        local str = StringBuffer()
        for i = 1, #t do
          local piece = t[i]
          if piece.num == "　" then
            str:append(string.lower(Misc.csa2sfen(Misc.k2csa(piece.kind))))
          else
            str:append(Misc.k2n(piece.num))
            str:append(string.lower(Misc.csa2sfen(Misc.k2csa(piece.kind))))
          end
        end
        sfen_whitehand  = str:tostring()
        print("WhiteHand: " .. sfen_whitehand)
      end
    end
    local teban = t[i].teban
    if teban then
      sfen_teban = "w"
    end
    local initial = t[i].initial
    if initial then
      local str = StringBuffer()
      for i = 1, 9 do
        for j = 1, 9 do
          local piece = initial[i][j]
          if piece.kind == "・" then
            str:append("1")
          else
            if piece.color == " " then
              str:append(string.upper(Misc.csa2sfen(Misc.k2csa(piece.kind))))
            elseif piece.color == "v" then
              str:append(string.lower(Misc.csa2sfen(Misc.k2csa(piece.kind))))
            end
          end
        end
        str:append("/")
      end
      if str:strlen() > 0 then
        sfen_position = string.sub(str:tostring(), 1, -2)
        sfen_position = string.gsub(sfen_position, "111111111", "9")
        sfen_position = string.gsub(sfen_position, "11111111", "8")
        sfen_position = string.gsub(sfen_position, "1111111", "7")
        sfen_position = string.gsub(sfen_position, "111111", "6")
        sfen_position = string.gsub(sfen_position, "11111", "5")
        sfen_position = string.gsub(sfen_position, "1111", "4")
        sfen_position = string.gsub(sfen_position, "111", "3")
        sfen_position = string.gsub(sfen_position, "11", "2")
      end
    end
    local move_begin  = t[i].move_begin
    if move_begin then
      local str   = StringBuffer()
      local hand  = StringBuffer()
      -- 初期局面があるか調べる
      if sfen_position then
        str:append(sfen_position):append(" "):append(sfen_teban):append(" ")
        if sfen_blackhand then
          hand:append(sfen_blackhand)
        end
        if sfen_whitehand then
          hand:append(sfen_whitehand)
        end
        if hand:strlen() == 0 then
          str:append("-")
        else
          str:append(hand)
        end
        str:append(" 1")
        print("sfen: " .. str:tostring())
      end
      print("move_begin")
    end
    local move  = t[i].move
    if move then
      for k, _ in pairs(move) do
        print("move: " .. k)
      end
      local str = ""
      if move.from then
        str = move.from.x .. move.from.y
      end
      str = str .. " -> "
      if move.same then
        str = str .. "same"
      end
      if move.to then
        str = str .. move.to.x .. move.to.y
      end
      if move.piece then
        str = str .. " " .. move.piece
      end
      if move.hit then
        move.relative = "H"
        move.hit  = nil
        str = str .. " " .. "Hit"
      end
      print(str)
    end
    if t[i].special then
      print("special: " .. t[i].special)
    end
    local comment = t[i].comment
    if comment then
      print("comment: " .. comment)
    end
  end
end

local function evalStr(s)
  local t = lpeg.match(Grammar, s)
  if t then
    evaluate(t)
  else
    print("syntax error")
  end
end

function M.toSashite(move_format)
  local move  = move_format.move
  if move then
    local str = StringBuffer()
    str:append(Misc.csa2k(move.piece))
    if move.promote then
      str:append("成")
    elseif move.promote == false then
      str:append("不成")
    end
    if move.same then
      local length  = utf8.len(str:tostring())
      if length > 1 then
        str:prepend("同")
      elseif length == 1 then
        str:prepend("同　")
      end
    else
      str:prepend(Misc.n2z(move.to.x) .. Misc.n2k(move.to.y))
    end
    if move.from == nil then
      str:append(Relative.getRelativeString(Relative.H))
    else
      str:append("(" .. move.from.x .. move.from.y .. ")")
    end
    return str:tostring()
  else
    return Misc.csa2special(move_format.special) or ""
  end
end

function M.toKIF(player, charset)
  charset = charset or "UTF-8"
  local str = StringBuffer()
  str:append("#KIF version=2.0 encoding=" .. charset .."\r\n")
  str:append("# KIF形式棋譜ファイル\r\n")
  str:append("# Generated by SSP用ゴースト「盤上の隅っこで」\r\n")
  -- TODO 駒落ちなどの手合の対応
  str:append("手合割：平手\r\n")
  -- TODO 対局者名の対応
  str:append("先手：\r\n")
  str:append("後手：\r\n")
  str:append("手数----指手---------消費時間--\r\n")
  local tesuu
  local tesuu_origin  = player:getTesuu()
  local winner  = nil
  player:go(1)
  repeat
    tesuu = player:getTesuu()
    -- TODO 消費時間
    -- TODO 指し手の後の空白を合わせる
    local move  = M.toSashite(player:getMoveFormat())
    local len = utf8.width(move)
    --print("len: " .. len)
    len = 13 - len + #move
    str:append(string.format("%4d %-" .. len .. "s (00:00 / 00:00:00)\r\n", tesuu, move))
    -- TODO 駒落ちの場合の勝者
    if move == "投了" then
      if tesuu % 2 == 0 then
        winner  = 2
      else
        winner  = 1
      end
    end
    player:forward()
  until tesuu == player:getTesuu()
  -- TODO 駒落ちの場合の勝者
  local winner_str  = {
    "先手",
    "後手",
  }
  if winner then
    str:append("まで" .. tesuu .. "手で" .. winner_str[winner] .. "の勝ち\r\n")
  end

  -- 元に戻す
  player:go(tesuu_origin)

  return str:tostring()
end

--[[
local filename  = arg[1] or ""
local fh  = io.open(filename, "r")
assert(fh)
local data  = fh:read("*a")
fh:close()

--print(data)

evalStr(data)
--]]

return M
