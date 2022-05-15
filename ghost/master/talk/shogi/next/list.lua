--[[
見る人が見たら「こんなものは『次の一手』とは呼べん！」
と思われるものがほとんどだと思いますが、
ほかに良い名称も思い浮かばないのでどうかご容赦願います。

最序盤のあれこれは例外として、局面は自分の指した棋譜を元に作っています。
--]]

local KifuPlayer    = require("kifu_player")
local Path  = require("path")
local StringBuffer  = require("string_buffer")

local files = {}
local t = {}

Path.dirWalk(Path.join("talk", "shogi", "next"), function(filename)
  if string.sub(filename, -4, -1) == ".kif" then
    table.insert(files, filename)
  end
end
)

files = {
  {
    filename = Path.join("talk", "shogi", "next", "next001.kif"),
    difficulty  = 4,
  },
  {
    filename = Path.join("talk", "shogi", "next", "next002.kif"),
    difficulty  = 5,
  },
  {
    filename = Path.join("talk", "shogi", "next", "next003.kif"),
    difficulty  = 4,
  },
  {
    filename = Path.join("talk", "shogi", "next", "next004.kif"),
    difficulty  = 3,
  },
  {
    filename = Path.join("talk", "shogi", "next", "next005.kif"),
    difficulty  = 3,
  },
  {
    filename = Path.join("talk", "shogi", "next", "next006.kif"),
    difficulty  = 4,
  },
  {
    filename = Path.join("talk", "shogi", "next", "next007.kif"),
    difficulty  = 4,
  },
  {
    filename = Path.join("talk", "shogi", "next", "next008.kif"),
    difficulty  = 3,
  },
  {
    filename = Path.join("talk", "shogi", "next", "next009.kif"),
    difficulty  = 4,
  },
  {
    filename = Path.join("talk", "shogi", "next", "next010.kif"),
    difficulty  = 3,
  },
}

table.insert(t, {
  id  = "OnShogiNextMove",
  content = function(shiori, ref)
    local str = StringBuffer()
    str:append([[
\0
\_q
\b[2]
\n
\n
\n
\n
]])
    str:append([=[\q[ランダム出題,将棋_次の一手_ランダム]]=])
    for i, v in ipairs(files) do
      str:append([[\n]])
      str:append([[\__q[次の一手_]] .. i .. "]問題" .. string.format("%03d", i))
      --str:append("\\_l[120,]")
      str:append("                ")
      for i = 1, v.difficulty do
        str:append("★")
      end
      for i = v.difficulty + 1, 5 do
        str:append("☆")
      end
      str:append([[\__q]])
    end
    str:append([[
\n
\n
\![*]\q[戻る,将棋メニュー] \![*]\q[閉じる,閉じる]\n
\_q
\_l[0,0]
次の一手/手筋/実践詰将棋などの問題集だよ。\n
メニューの選択肢か A キーを押せば答えが表示されるよ。\n
]])
    return str:tostring()
  end,
})

local function generateTalk(num, path, is_answer)
  local id  = "次の一手_" .. num
  if is_answer then
    id  = id .. "_答え"
  end
  return {
    id  = id,
    content = function(shiori, ref)
      local __  = shiori.var
      local player  = KifuPlayer.getInstance()
      if is_answer then
        __("_KeepBoardVisible", false)
        __("_Quiet", false)
      else
        __("_KeepBoardVisible", true)
        __("_Quiet", "Shogi")
      end
      player:load(path)
      player:head()
      player:forward()
      if is_answer then
        player:forward()
        __("_次の一手問題ID", nil)
      end
      local str = StringBuffer()
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append(shiori:talk("OnShogiViewComments"))
      if is_answer then
        str:append([[
\0
\n
\_q\![*]\q[問題選択に戻る,OnShogiNextMove] \![*]\q[閉じる,閉じる]\n\_q
]])
      elseif not(shiori:isReservedTalk(id .. "_答え")) then
        --shiori:reserveTalk(id .. "_答え")
        __("_次の一手問題ID", id)
      end
      return str
    end,
  }
end

table.insert(t, {
  id  = "将棋_次の一手_ランダム",
  content = function(shiori, ref)
    return shiori:talk("次の一手_" .. math.random(#files))
  end,
})
for i, v in ipairs(files) do
  table.insert(t, generateTalk(i, v.filename, false))
  table.insert(t, generateTalk(i, v.filename, true))
end
table.insert(t, {
  id  = "将棋_次の一手_答え",
  content = function(shiori, ref)
    local __  = shiori.var
    local id  = __("_次の一手問題ID")
    if id then
      return shiori:talk(id .. "_答え")
    end
  end,
})

return t
