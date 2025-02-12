local KifuPlayer    = require("kifu_player")
local Color = KifuPlayer.Color
local Path          = require("path")
local StringBuffer  = require("string_buffer")
local files = {}
local t = {}

files = {
  {
    filename = Path.join("talk", "shogi", "thinking", "0001.kif"),
    difficulty  = 4,
  },
  {
    filename = Path.join("talk", "shogi", "thinking", "0002.kif"),
    difficulty  = 4,
  },
  {
    filename = Path.join("talk", "shogi", "thinking", "0003.kif"),
    difficulty  = 4,
  },
}

table.insert(t, {
  id  = "OnShogiThinking",
  content = function(shiori, ref)
    local page  = tonumber(ref[0]) or 1
    if page < 1 then
      page  = 1
    elseif page > math.ceil(#files / 16) then
      page  = math.ceil(#files / 16)
    end
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
    str:append([=[\q[ランダム出題,将棋_何指す_ランダム]]=])
    --for i, v in ipairs(files) do
    for i = 1 + (page - 1) * 16, page * 16 do
      local v = files[i]
      str:append([[\n]])
      if v then
        str:append([[\__q[何指す_]] .. i .. "]問題" .. string.format("%03d", i))
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
    end
    str:append([[\n\n]])
    str:append(string.format([=[\q[前のページ,OnShogiThinking,%d] \q[次のページ,OnShogiThinking,%d]]=], page - 1, page + 1))
    str:append([[
\n
\n
\![*]\q[戻る,将棋メニュー] \![*]\q[閉じる,閉じる]\n
\_q
\_l[0,0]
何を指すかを考える問題集だよ。\n
メニューから進行一例を表示出来るよ。\n
]])
    return str:tostring()
  end,
})

local function generateTalk(num, path, is_answer, is_continue)
  local id  = "何指す_" .. num
  if is_answer then
    id  = id .. "_進行一例"
  elseif is_continue then
    id = id .. "_指し継ぐ"
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
        __("_何指す問題ID", nil)
      elseif is_continue then
        __("_何指す問題ID", nil)
        __("_PlayerColor", Color.BLACK)
        __("_Quiet", "Shogi")
        __("_InGame", true)
        __("_ScoreList", {})
        __("_CurrentMoves", {nodes = 0, pv = {}})
        __("_CurrentScore", 0)
        __("_CurrentJudgement", 6)
        __("_SeizaCount", os.time())
        __("_NoCount", true)
        return [=[\![raise,OnStartShogiEngine,OnShogiGameTurnBegin]]=]
      else
        __("_何指す問題ID", id)
      end
      local str = StringBuffer()
      str:append(shiori:talk("OnShogiViewMinimal"))
      str:append(shiori:talk("OnShogiViewComments"))
      if is_answer then
        str:append([[
\0
\n
\_q\![*]\q[問題選択に戻る,OnShogiThinking] \![*]\q[閉じる,閉じる]\n\_q
]])
      end
      return str
    end,
  }
end

table.insert(t, {
  id  = "将棋_何指す_ランダム",
  content = function(shiori, ref)
    return shiori:talk("何指す_" .. math.random(#files))
  end,
})
for i, v in ipairs(files) do
  table.insert(t, generateTalk(i, v.filename, false, false))
  table.insert(t, generateTalk(i, v.filename, true, false))
  table.insert(t, generateTalk(i, v.filename, false, true))
end
table.insert(t, {
  id  = "将棋_何指す_進行一例",
  content = function(shiori, ref)
    local __  = shiori.var
    local id  = __("_何指す問題ID")
    if id then
      return shiori:talk(id .. "_進行一例")
    end
  end,
})
table.insert(t, {
  id  = "将棋_何指す_指し継ぐ",
  content = function(shiori, ref)
    local __  = shiori.var
    local id  = __("_何指す問題ID")
    if id then
      return shiori:talk(id .. "_指し継ぐ")
    end
  end,
})

return t
