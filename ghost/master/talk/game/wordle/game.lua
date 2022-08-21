local Clone = require("clone")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")
local utf8  = require("lua-utf8")

local function isValid(word, length, vocabulary)
  if utf8.len(word) ~= length then
    return false, "文字数があってないよ。"
  end
  if not(vocabulary[word]) then
    return false, "辞書に存在しない言葉だよ。"
  end
  return true
end

return {
  {
    id  = "OnWordleGameInitialize",
    content = function(shiori, ref)
      local __  = shiori.var
      if not(__("_WordleVocabulary")) then
        local vocabulary  = {}
        local vocabulary2 = {}
        local fh  = io.open("talk\\game\\wordle\\words.txt", "r")
        local dup = {}
        for line in fh:lines() do
          line  = string.upper(line)
          if not(dup[line]) then
            dup[line] = true
            dup[line .. "S"]  = true -- 3単現のsも除外するように。
            table.insert(vocabulary, line)
            vocabulary2[line] = true
          end
        end
        __("_WordleVocabulary", vocabulary)
        __("_WordleVocabulary2", vocabulary2)
      end
    end,
  },
  {
    id  = "OnWordleGameStart",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_Quiet", "Wordle")
      __("_InGame", true)
      __("_WordleList", {})
      local game_option = __("WordleGameOption")
      local vocabulary  = __("_WordleVocabulary")
      print(#vocabulary)
      local v = Clone(vocabulary)
      for i = #v, 2, -1 do
        local j = math.random(i)
        v[i], v[j]  = v[j], v[i]
      end
      for _, v in ipairs(v) do
        if utf8.len(v) == game_option.length then
          __("_WordleAnswer", v)
        end
      end
      __("_WordleGameOver", false)
      __("_WordleAvailable", {})
      return [=[\![raise,OnWordleGameView]]=]
    end,
  },
  {
    id  = "OnWordleGameView",
    content = function(shiori, ref)
      local __  = shiori.var
      local game_option = __("WordleGameOption")
      local vocabulary2 = __("_WordleVocabulary2")
      local available   = __("_WordleAvailable")
      local list        = __("_WordleList")
      local valid, err
      if ref[0] == "word" then
        local word  = string.upper(ref[1])
        valid, err = isValid(word, game_option.length, vocabulary2)
        if valid then
          local answer  = __("_WordleAnswer")
          local data  = {
            word = word,
          }
          local wt  = {}
          local at  = {}
          for c in utf8.gmatch(word, ".") do
            table.insert(wt, c)
          end
          for c in utf8.gmatch(answer, ".") do
            table.insert(at, c)
          end
          local map = {}
          for _, v in ipairs(at) do
            if not(map[v]) then
              map[v]  = 1
            else
              map[v]  = map[v] + 1
            end
          end
          for i, v in ipairs(wt) do
            if v == at[i] then
              data[i] = "match"
              available[v]  = true
              map[v]  = map[v] - 1
            end
          end
          for i, v in ipairs(wt) do
            if not(data[i]) and map[v] and map[v] > 0 then
              data[i] = "contain"
              available[v]  = true
              map[v]  = map[v] - 1
            elseif not(data[i]) then
              data[i] = "not match"
              available[v]  = false
            end
          end
          if word == answer then
            __("_InGame", false)
          end
          table.insert(list, data)
        end
      end

      local kana_list  = [[
  A B C D E F G H I J\n
  K L M N O P Q R S T\n
  U V W X Y Z\n
]]

      for k, v in pairs(available) do
        if v == true then
          kana_list = string.gsub(kana_list, k, "\\f[bold,1]\\f[color,magenta]" .. k .. "\\f[color,default]\\f[bold,0]")
        elseif v == false then
          kana_list = string.gsub(kana_list, k, "\\f[color,disable]" .. k .. "\\f[color,default]")
        end
      end

      local str = StringBuffer(SS():C():p(0):b(2):_q(true):c())
      str:append("\\f[height,200%]")
      if __("_InGame") then
        str:append(SS():inputbox("OnWordleGameInputResult", 0))
      end
      str:append(kana_list)
      str:append([[\n]])
      for _, v in ipairs(list) do
        str:append([=[\_l[40,]]=])
        local t  = {}
        for c in utf8.gmatch(v.word, ".") do
          table.insert(t, c)
        end
        for i, v in ipairs(v) do
          if v == "match" then
            str:append("\\f[bold,1]\\f[color,red]" .. t[i] .. "\\f[color,default]\\f[bold,0]")
          elseif v == "contain" then
            str:append("\\f[color,magenta]" .. t[i] .. "\\f[color,default]")
          else
            str:append("\\f[color,disable]" .. t[i] .. "\\f[color,default]")
          end
        end
        str:append("\\n")
      end
      str:append("\\n")
      if not(valid) then
        str:append(err):append("\\n")
      end
      str:append("\\f[height,default]")
      if not(__("_InGame")) then
        str:append("\\n\\n\\![*]\\q[戻る,OnWordleGameMenu] \\![*]\\q[閉じる,閉じる]")
      end
      str:append("\\![set,balloontimeout,0]\\![set,choicetimeout,0]")
      str:append(SS():_q(false))
      return str
    end,
  },
  {
    id  = "OnWordleGameInputResult",
    content = function(shiori, ref)
      return SS():C():raise("OnWordleGameView", "word", ref[0])
    end,
  },
}
