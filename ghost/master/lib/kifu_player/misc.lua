local CSA = require("kifu_player.csa")
local Color = require("kifu_player.color")

local M = {}

--- 消費時間を表す文字列を連想配列へ変換する
-- hh:mm:ss -> {h = hh, m = mm, s = ss}
-- mmm:ss -> {h = hh, m = mm, s = ss}
-- @tparam string str [hh:]mm:ss、ただしmmは60を超える場合がある
function M.parseTime(str)
  local err = "Invalid TimeFormat"
  local array = {}
  for t in string.gmatch(str, "%d+") do
    table.insert(array, tonumber(t))
  end
  local t = {
    h = array[#array - 2],
    m = array[#array - 1],
    s = array[#array],
  }

  assert(t.m ~= nil and t.s ~= nil, err)

  assert(t.m >= 0 and t.s >= 0, err)
  assert(t.s < 60, err)

  assert(not(t.h and t.m >= 60), err)

  -- KIF
  --  一手に1時間以上使った場合はmが60以上になる場合がある
  if t.m >= 60 then
    t.h = math.floor(t.m / 60)
  end
end

--[[
--  TORYO
--  CHUDAN
--  SENNICHITE
--  TIME_UP         手番が時間切れ
--  ILLEGAL_MOVE    手番が反則
--  +ILLEGAL_ACTION 相手が反則  (先手の反則)
--  -ILLEGAL_ACTION 相手が反則  (後手の反則)
--  JISHOGI
--  KACHI           入玉勝ち
--  HIKIWAKE        入玉引き分け
--  MATTA
--  TSUMI
--  FUZUMI
--  ERROR
--]]
local special2csa = {
  -- KIF
  ["投了"]    = "TORYO",
  ["中断"]    = "CHUDAN",
  ["千日手"]  = "SENNICHITE",
  -- CSA
  ["TORYO"]       = "TORYO",
  ["CHUDAN"]      = "CHUDAN",
  ["SENNICHITE"]  = "SENNICHITE",
  -- USI
  ["resign"]  = "TORYO",
  ["win"]     = "KACHI",
  -- 独自拡張
  ["pass"]    = "PASS",
  ["パス"]    = "PASS",
}

function M.special2csa(str)
  assert(str)
  return special2csa[str]
end

local csa2special = {
  TORYO       = "投了",
  CHUDAN      = "中断",
  SENNICHITE  = "千日手",
  -- 独自拡張
  PASS        = "パス",
}

function M.csa2special(str)
  return csa2special[str]
end

local z2n = {
  ["１"] = 1,
  ["２"] = 2,
  ["３"] = 3,
  ["４"] = 4,
  ["５"] = 5,
  ["６"] = 6,
  ["７"] = 7,
  ["８"] = 8,
  ["９"] = 9,
}
--- 全角数字(文字列)から数値への変換
-- @tparam string str １、２など
-- @treturn int 1-9, otherwise error
function M.z2n(str)
  assert(str)
  local err = "Invalid Zenkaku number: "
  return (assert(z2n[str], err .. tostring(str)))
end

local n2z = {
  "１", "２", "３", "４", "５", "６", "７", "８", "９",
}

--- 数値から全角数字(文字列)への変換
-- @tparam int num
-- @treturn string
function M.n2z(num)
  local err = "Invalid number: "
  return (assert(n2z[num], err .. tostring(num)))
end

local k2n = {
  ["一"]  = 1,
  ["二"]  = 2,
  ["三"]  = 3,
  ["四"]  = 4,
  ["五"]  = 5,
  ["六"]  = 6,
  ["七"]  = 7,
  ["八"]  = 8,
  ["九"]  = 9,
}

--- 漢数字(文字列)から数値への変換
-- @tparam string str 一、二など
-- @treturn int 1-9, otherwise error
function M.k2n(str)
  assert(str)
  local err = "Invalid Kan-Suuji: "
  --return (assert(k2n[str], err .. tostring(str)))
  return k2n[str]
end

local n2k = {
  "一", "二", "三", "四", "五", "六", "七", "八", "九",
}

--- 数字に対応する漢数字を返す
-- @tparam int num
-- @treturn string
function M.n2k(num)
  assert(num)
  local err = "Invalid number: "
  return (assert(n2k[num], err .. tostring(num)))
end

local k2csa = {
  ["歩"]    = CSA.FU,
  ["と"]    = CSA.TO,
  ["香"]    = CSA.KY,
  ["成香"]  = CSA.NY,
  ["杏"]    = CSA.NY,
  ["桂"]    = CSA.KE,
  ["成桂"]  = CSA.NK,
  ["圭"]    = CSA.NK,
  ["銀"]    = CSA.GI,
  ["成銀"]  = CSA.NG,
  ["全"]    = CSA.NG,
  ["金"]    = CSA.KI,
  ["角"]    = CSA.KA,
  ["馬"]    = CSA.UM,
  ["飛"]    = CSA.HI,
  ["竜"]    = CSA.RY, --  表記揺れ
  ["龍"]    = CSA.RY, --
  ["玉"]    = CSA.OU,
}

--- 駒を表す漢字からCSAの駒表記へ変換
-- @tparam string str
-- @treturn string
function M.k2csa(str)
  assert(str)
  local err = "Invalid Kanji: "
  --return (assert(k2csa[str], err .. tostring(str)))
  return k2csa[str]
end

local csa2k = {
  FU  = "歩",
  TO  = "と",
  KY  = "香",
  NY  = "成香",
  KE  = "桂",
  NK  = "成桂",
  GI  = "銀",
  NG  = "成銀",
  KI  = "金",
  KA  = "角",
  UM  = "馬",
  HI  = "飛",
  RY  = "龍",
  OU  = "玉",
}

function M.csa2k(str)
  assert(str)
  local err = "Invalid CSA string: "
  return (assert(csa2k[str], err .. tostring(str)))
end

local sfen2csa = {
  p = CSA.FU,
  ["+p"]  = CSA.TO,
  l = CSA.KY,
  ["+l"]  = CSA.NY,
  n = CSA.KE,
  ["+n"]  = CSA.NK,
  s = CSA.GI,
  ["+s"]  = CSA.NG,
  g = CSA.KI,
  b = CSA.KA,
  ["+b"]  = CSA.UM,
  r = CSA.HI,
  ["+r"]  = CSA.RY,
  k = CSA.OU,
}

function M.sfen2csa(str)
  assert(str)
  local err = "Invalid sfen piece: "
  return (assert(sfen2csa[str], err .. tostring(str)))
end

local csa2sfen  = {
  [CSA.FU]  = "p",
  [CSA.TO]  = "+p",
  [CSA.KY]  = "l",
  [CSA.NY]  = "+l",
  [CSA.KE]  = "n",
  [CSA.NK]  = "+n",
  [CSA.GI]  = "s",
  [CSA.NG]  = "+s",
  [CSA.KI]  = "g",
  [CSA.KA]  = "b",
  [CSA.UM]  = "+b",
  [CSA.HI]  = "r",
  [CSA.RY]  = "+r",
  [CSA.OU]  = "k",
}

function M.csa2sfen(str)
  assert(str)
  local err = "Invalid CSA piece: "
  return (assert(csa2sfen[str], err .. tostring(str)))
end

local sfen2n  = {
  a = 1,
  b = 2,
  c = 3,
  d = 4,
  e = 5,
  f = 6,
  g = 7,
  h = 8,
  i = 9,
}

function M.sfen2n(str)
  assert(str)
  local err = "Invalid sfen number: "
  return (assert(sfen2n[str], err .. tostring(str)))
end

local n2sfen = {
  "a", "b", "c", "d", "e", "f", "g", "h", "i",
}

function M.n2sfen(str)
  assert(tonumber(str))
  local err = "Invalid number: "
  return (assert(n2sfen[str], err .. tostring(str)))
end

local promote = {
  FU  = "TO",
  TO  = "TO",
  KY  = "NY",
  NY  = "NY",
  KE  = "NK",
  NK  = "NK",
  GI  = "NG",
  NG  = "NG",
  KI  = "KI",
  KA  = "UM",
  UM  = "UM",
  HI  = "RY",
  RY  = "RY",
  OU  = "OU",
}

function M.promote(csa)
  assert(csa)
  local err = "Invalid CSA string: "
  return (assert(promote[csa], err .. tostring(csa)))
end

local unpromote = {
  FU  = "FU",
  TO  = "FU",
  KY  = "KY",
  NY  = "KY",
  KE  = "KE",
  NK  = "KE",
  GI  = "GI",
  NG  = "GI",
  KI  = "KI",
  KA  = "KA",
  UM  = "KA",
  HI  = "HI",
  RY  = "HI",
  OU  = "OU",
}

function M.unpromote(csa)
  assert(csa)
  local err = "Invalid CSA string: "
  return (assert(unpromote[csa], err .. tostring(csa)))
end

function M.canPromote(color, from_y, to_y, piece)
  assert(from_y)
  assert(to_y)
  assert(piece)
  local force = false
  -- 既に成っている
  if piece == M.promote(piece) then
    return false, force
  end
  if color == Color.BLACK then
    if from_y > 3 and to_y > 3 then
      return false, force
    end
  elseif color == Color.WHITE then
    if from_y < 7 and to_y < 7 then
      return false, force
    end
  end
  if piece == CSA.FU or piece == CSA.KY then
    if color == Color.BLACK then
      if to_y == 1 then
        force = true
      end
    elseif color == Color.WHITE then
      if to_y ==9 then
        force = true
      end
    end
  elseif piece == CSA.KE then
    if color == Color.BLACK then
      if to_y == 2 or to_y == 1 then
        force = true
      end
    elseif color == Color.WHITE then
      if to_y == 8 or to_y == 9 then
        force = true
      end
    end
  end
  return true, force
end

return M
