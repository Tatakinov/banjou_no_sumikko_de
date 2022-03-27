local Clone = require("clone")
local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")
local utf8  = require("lua-utf8")

local function kata2hira(input)
  local replace = {
        ["ア"]  = "あ",
        ["イ"]  = "い",
        ["ウ"]  = "う",
        ["エ"]  = "え",
        ["オ"]  = "お",
        ["カ"]  = "か",
        ["キ"]  = "き",
        ["ク"]  = "く",
        ["ケ"]  = "け",
        ["コ"]  = "こ",
        ["サ"]  = "さ",
        ["シ"]  = "し",
        ["ス"]  = "す",
        ["セ"]  = "せ",
        ["ソ"]  = "そ",
        ["タ"]  = "た",
        ["チ"]  = "ち",
        ["ツ"]  = "つ",
        ["テ"]  = "て",
        ["ト"]  = "と",
        ["ナ"]  = "な",
        ["ニ"]  = "に",
        ["ヌ"]  = "ぬ",
        ["ネ"]  = "ね",
        ["ノ"]  = "の",
        ["ハ"]  = "は",
        ["ヒ"]  = "ひ",
        ["フ"]  = "ふ",
        ["ヘ"]  = "へ",
        ["ホ"]  = "ほ",
        ["マ"]  = "ま",
        ["ミ"]  = "み",
        ["ム"]  = "む",
        ["メ"]  = "め",
        ["モ"]  = "も",
        ["ヤ"]  = "や",
        ["ユ"]  = "ゆ",
        ["ヨ"]  = "よ",
        ["ラ"]  = "ら",
        ["リ"]  = "り",
        ["ル"]  = "る",
        ["レ"]  = "れ",
        ["ロ"]  = "ろ",
        ["ワ"]  = "わ",
        ["ヲ"]  = "を",
        ["ン"]  = "ん",
        ["ガ"]  = "が",
        ["ギ"]  = "ぎ",
        ["グ"]  = "ぐ",
        ["ゲ"]  = "げ",
        ["ゴ"]  = "ご",
        ["ザ"]  = "ざ",
        ["ジ"]  = "じ",
        ["ズ"]  = "ず",
        ["ゼ"]  = "ぜ",
        ["ゾ"]  = "ぞ",
        ["ダ"]  = "だ",
        ["ヂ"]  = "ぢ",
        ["ヅ"]  = "づ",
        ["デ"]  = "で",
        ["ド"]  = "ど",
        ["バ"]  = "ば",
        ["ビ"]  = "び",
        ["ブ"]  = "ぶ",
        ["ベ"]  = "べ",
        ["ボ"]  = "ぼ",
        ["パ"]  = "ぱ",
        ["ピ"]  = "ぴ",
        ["プ"]  = "ぷ",
        ["ペ"]  = "ぺ",
        ["ポ"]  = "ぽ",
        ["ァ"]  = "ぁ",
        ["ィ"]  = "ぃ",
        ["ゥ"]  = "ぅ",
        ["ェ"]  = "ぇ",
        ["ォ"]  = "ぉ",
        ["ッ"]  = "っ",
        ["ャ"]  = "ゃ",
        ["ュ"]  = "ゅ",
        ["ョ"]  = "ょ",
        ["ヮ"]  = "ゎ",
        ["ー"]  = "ー",
  }
  local s = ""
  for c in utf8.gmatch(input, ".") do
    if replace[c] then
      s = s .. replace[c]
    else
      return nil
    end
  end
  return s
end

local function normalize(word, insensitive)
  local str = StringBuffer()
  local replace = {
        ["が"]  = "か",
        ["ぎ"]  = "き",
        ["ぐ"]  = "く",
        ["げ"]  = "け",
        ["ご"]  = "こ",
        ["ざ"]  = "さ",
        ["じ"]  = "し",
        ["ず"]  = "す",
        ["ぜ"]  = "せ",
        ["ぞ"]  = "そ",
        ["だ"]  = "た",
        ["ぢ"]  = "ち",
        ["づ"]  = "つ",
        ["で"]  = "て",
        ["ど"]  = "と",
        ["ば"]  = "は",
        ["び"]  = "ひ",
        ["ぶ"]  = "ふ",
        ["べ"]  = "へ",
        ["ぼ"]  = "ほ",
        ["ぱ"]  = "は",
        ["ぴ"]  = "ひ",
        ["ぷ"]  = "ふ",
        ["ぺ"]  = "へ",
        ["ぽ"]  = "ほ",
        ["ぁ"]  = "あ",
        ["ぃ"]  = "い",
        ["ぅ"]  = "う",
        ["ぇ"]  = "え",
        ["ぉ"]  = "お",
        ["っ"]  = "つ",
        ["ゃ"]  = "や",
        ["ゅ"]  = "ゆ",
        ["ょ"]  = "よ",
        ["ゎ"]  = "わ",
  }
  local replace_bar = {
        ["あ"]  = "あ",
        ["い"]  = "い",
        ["う"]  = "う",
        ["え"]  = "え",
        ["お"]  = "お",
        ["か"]  = "あ",
        ["き"]  = "い",
        ["く"]  = "う",
        ["け"]  = "え",
        ["こ"]  = "お",
        ["さ"]  = "あ",
        ["し"]  = "い",
        ["す"]  = "う",
        ["せ"]  = "え",
        ["そ"]  = "お",
        ["た"]  = "あ",
        ["ち"]  = "い",
        ["つ"]  = "う",
        ["て"]  = "え",
        ["と"]  = "お",
        ["な"]  = "あ",
        ["に"]  = "い",
        ["ぬ"]  = "う",
        ["ね"]  = "え",
        ["の"]  = "お",
        ["は"]  = "あ",
        ["ひ"]  = "い",
        ["ふ"]  = "う",
        ["へ"]  = "え",
        ["ほ"]  = "お",
        ["ま"]  = "あ",
        ["み"]  = "い",
        ["む"]  = "う",
        ["め"]  = "え",
        ["も"]  = "お",
        ["や"]  = "あ",
        ["ゆ"]  = "う",
        ["よ"]  = "お",
        ["ら"]  = "あ",
        ["り"]  = "い",
        ["る"]  = "う",
        ["れ"]  = "え",
        ["ろ"]  = "お",
        ["わ"]  = "あ",
        ["を"]  = nil,
        ["ん"]  = nil,
        ["が"]  = "あ",
        ["ぎ"]  = "い",
        ["ぐ"]  = "う",
        ["げ"]  = "え",
        ["ご"]  = "お",
        ["ざ"]  = "あ",
        ["じ"]  = "い",
        ["ず"]  = "う",
        ["ぜ"]  = "え",
        ["ぞ"]  = "お",
        ["だ"]  = "あ",
        ["ぢ"]  = "い",
        ["づ"]  = "う",
        ["で"]  = "え",
        ["ど"]  = "お",
        ["ば"]  = "あ",
        ["び"]  = "い",
        ["ぶ"]  = "う",
        ["べ"]  = "え",
        ["ぼ"]  = "お",
        ["ぱ"]  = "あ",
        ["ぴ"]  = "い",
        ["ぷ"]  = "う",
        ["ぺ"]  = "え",
        ["ぽ"]  = "お",
        ["ぁ"]  = "あ",
        ["ぃ"]  = "い",
        ["ぅ"]  = "う",
        ["ぇ"]  = "え",
        ["ぉ"]  = "お",
        ["っ"]  = nil,
        ["ゃ"]  = "あ",
        ["ゅ"]  = "う",
        ["ょ"]  = "お",
        ["ゎ"]  = "あ",
  }
  local last  = nil
  for c in utf8.gmatch(word, ".") do
    if (replace[c]) and insensitive then
      str:append(replace[c])
    else
      str:append(c)
    end
  end
  word  = str:tostring()
  str = StringBuffer()
  for c in utf8.gmatch(word, ".") do
    if last and c == "ー" then
      str:append(replace_bar[last])
    else
      str:append(c)
    end
    last = c
  end
  return str:tostring()
end

local function isValid(word, available, tail)
  local avail = Clone(available)
  if not(string.match(word, "^" .. tail)) then
    return "言葉が「" .. tail .. "」から始まってないよ。@"
  end
  if string.match(word, "ん$") then
    return "言葉が「ん」で終わってるよ。@"
  end
  if string.match(word, tail .. "$") then
    return "「" .. tail .. "」返しは出来ないよ。@"
  end
  for c in utf8.gmatch(word, ".") do
    if avail[c] == nil then
      return "使用出来ない文字が含まれてるよ。@"
    elseif not(avail[c]) then
      return "「" .. c .. "」は既に使われてるよ。@"
    else
      --avail[c]  = false
    end
  end
  return "ok"
end

local function getCandidate(vocabulary, available, tail, insensitive)
  local candidate = {}
  for _, word in ipairs(vocabulary) do
    local normalized  = normalize(word.yomi, insensitive)
    local err = isValid(normalized, available, tail)
    if err == "ok" and utf8.len(normalized) >= 3 then
      table.insert(candidate, word)
    end
  end
  return candidate
end

local function toStr(t)
  if t.color == 1 then
    return "\\f[color,blue]" .. t.word .. "\\f[color,default]"
  else
    return "\\f[color,red]" .. t.word .. "\\f[color,default]"
  end
end

return {
  {
    id  = "OnWordChainGameInitialize",
    content = function(shiori, ref)
      local __  = shiori.var
      if not(__("_WordChainVocabulary")) then
        local vocabulary  = {}
        local fh  = io.open("talk\\game\\word_chain\\dictionary.txt", "r")
        local prev  = nil
        local dup = {}
        for line in fh:lines() do
          local data  = {}
          for v in utf8.gmatch(line, "[^,]+") do
            table.insert(data, v)
          end
          if not(dup[data[2]]) and utf8.len(data[2]) > 1 and kata2hira(data[2]) then
            dup[data[2]] = true
            table.insert(vocabulary, {
              yomi  = kata2hira(data[2]),
              word  = data[1],
            })
          end
        end
        __("_WordChainVocabulary", vocabulary)
      end
    end,
  },
  {
    id  = "OnWordChainGameStart",
    content = function(shiori, ref)
      local __  = shiori.var
      __("_Quiet", "WordChain")
      __("_InGame", true)
      __("_WordChainList", {})
      __("_PassCount", 0)
      __("_WordChainMaximum", {
        user  = 0,
        cpu   = 0,
      })
      local game_option = __("WordChainGameOption")
      if game_option.player_color == "random" then
        __("_WordChainTeban", math.random(2))
      else
        __("_WordChainTeban", game_option.player_color)
      end
      __("_WordChainGameOver", false)
      local first_tail  = {
        "あ", "い", "う", "え", "お",
        "か", "き", "く", "け", "こ",
        "さ", "し", "す", "せ", "そ",
        "た", "ち", "つ", "て", "と",
        "な", "に", "ぬ", "ね", "の",
        "は", "ひ", "ふ", "へ", "ほ",
        "ま", "み", "む", "め", "も",
        "や",       "ゆ",       "よ",
        "ら", "り", "る", "れ", "ろ",
        "わ",
      }
      __("_WordChainTail", first_tail[math.random(#first_tail)])
      __("_WordChainAvailable", {
        ["あ"]  = true,
        ["い"]  = true,
        ["う"]  = true,
        ["え"]  = true,
        ["お"]  = true,
        ["か"]  = true,
        ["き"]  = true,
        ["く"]  = true,
        ["け"]  = true,
        ["こ"]  = true,
        ["さ"]  = true,
        ["し"]  = true,
        ["す"]  = true,
        ["せ"]  = true,
        ["そ"]  = true,
        ["た"]  = true,
        ["ち"]  = true,
        ["つ"]  = true,
        ["て"]  = true,
        ["と"]  = true,
        ["な"]  = true,
        ["に"]  = true,
        ["ぬ"]  = true,
        ["ね"]  = true,
        ["の"]  = true,
        ["は"]  = true,
        ["ひ"]  = true,
        ["ふ"]  = true,
        ["へ"]  = true,
        ["ほ"]  = true,
        ["ま"]  = true,
        ["み"]  = true,
        ["む"]  = true,
        ["め"]  = true,
        ["も"]  = true,
        ["や"]  = true,
        ["ゆ"]  = true,
        ["よ"]  = true,
        ["ら"]  = true,
        ["り"]  = true,
        ["る"]  = true,
        ["れ"]  = true,
        ["ろ"]  = true,
        ["わ"]  = true,
        ["ん"]  = true,
        ["が"]  = true,
        ["ぎ"]  = true,
        ["ぐ"]  = true,
        ["げ"]  = true,
        ["ご"]  = true,
        ["ざ"]  = true,
        ["じ"]  = true,
        ["ず"]  = true,
        ["ぜ"]  = true,
        ["ぞ"]  = true,
        ["だ"]  = true,
        ["ぢ"]  = true,
        ["づ"]  = true,
        ["で"]  = true,
        ["ど"]  = true,
        ["ば"]  = true,
        ["び"]  = true,
        ["ぶ"]  = true,
        ["べ"]  = true,
        ["ぼ"]  = true,
        ["ぱ"]  = true,
        ["ぴ"]  = true,
        ["ぷ"]  = true,
        ["ぺ"]  = true,
        ["ぽ"]  = true,
        ["ぁ"]  = true,
        ["ぃ"]  = true,
        ["ぅ"]  = true,
        ["ぇ"]  = true,
        ["ぉ"]  = true,
        ["っ"]  = true,
        ["ゃ"]  = true,
        ["ゅ"]  = true,
        ["ょ"]  = true,
        ["ゎ"]  = true,
      })
      return [=[\0よろしくお願いします。\![raise,OnWordChainGameView]]=]
    end,
  },
  {
    id  = "OnWordChainGameView",
    content = function(shiori, ref)
      local __  = shiori.var
      local game_option = __("WordChainGameOption")
      local word_list = __("_WordChainList")
      local available = __("_WordChainAvailable")
      local tail  = __("_WordChainTail")
      local maximum = __("_WordChainMaximum")
      local err
      if ref[0] == "word" then
        local word  = ref[1]
        local normalized  = normalize(word, game_option.insensitive)
        err = isValid(normalized, available, tail)
        if err == "ok" then
          local teban = __("_WordChainTeban")
          local w = ref[2]
          if w then
            table.insert(word_list, {
              word  = w .. "(" .. word .. ")",
              color = teban,
            })
          else
            table.insert(word_list, {
              word  = word,
              color = teban,
            })
          end
          local teban_str = {"user", "cpu"}
          teban = teban_str[teban]
          maximum[teban]  = maximum[teban] + utf8.len(word)
          for c in utf8.gmatch(normalized, ".") do
            available[c]  = false
            tail  = c
          end
          if tail == "ゃ" or tail == "ゅ" or tail == "ょ" or
            tail == "ぁ" or tail == "ぃ" or tail == "ぅ" or
            tail == "ぇ" or tail == "ぉ" then
            tail  = normalize(tail, true)
          end
          available[tail] = true
          __("_WordChainTail", tail)
          if __("_WordChainTeban") == 1 then
            __("_WordChainTeban", 2)
          else
            __("_WordChainTeban", 1)
          end
        end
      end
      if ref[0] == "resign" and ref[1] == "cpu" then
        __("_WordChainGameOver", "user")
      elseif ref[0] == "resign" and ref[1] == "user" then
        __("_WordChainGameOver", "cpu")
      end
      if ref[0] == "pass" then
        if __("_WordChainTeban") == 1 then
          __("_WordChainTeban", 2)
        else
          __("_WordChainTeban", 1)
        end
        local pass_count  = __("_PassCount") or 0
        pass_count  = pass_count + 1
        __("_PassCount", pass_count)
        if pass_count >= 2 then
          -- ゲーム終了
          __("_WordChainGameOver", true)
        end
      else
        __("_PassCount", 0)
      end
      local kana_list  = [[
  ん わ ら や ま は な た さ か あ\n
        り    み ひ に ち し き い\n
        る ゆ む ふ ぬ つ す く う\n
        れ    め へ ね て せ け え\n
        ろ よ も ほ の と そ こ お\n
]]

      if not(game_option.insensitive) then
        kana_list  = [[
  ん わ ら や ま は な た さ か あ\n
        り    み ひ に ち し き い\n
        る ゆ む ふ ぬ つ す く う\n
        れ    め へ ね て せ け え\n
        ろ よ も ほ の と そ こ お\n
\n
  っ ゎ    ゃ ぱ ば    だ ざ が ぁ\n
              ぴ び    ぢ じ ぎ ぃ\n
           ゅ ぷ ぶ    づ ず ぐ ぅ\n
              ぺ べ    で ぜ げ ぇ\n
           ょ ぽ ぼ    ど ぞ ご ぉ\n
]]
      end

      for k, v in pairs(available) do
        if not(v) then
          kana_list = string.gsub(kana_list, k, "\\f[color,disable]" .. k .. "\\f[color,default]")
        end
      end

      local str = StringBuffer(SS():C():p(0):b(2):_q(true):c())
      str:append(kana_list)
      if __("_WordChainGameOver") then
        if game_option.variant == "survival" then
          str:append([[\n\n\n\n]])
          if __("_WordChainGameOver") == "user" then
            str:append("\\s[きょとん]う〜ん、@思いつかないや。@私の負けだね。@\\n\\n")
            local score_list  = __("成績(WordChain)") or {}
            __("成績(WordChain)", score_list)
            local score = score_list["ふつう"]
            score.win = score.win + 1
            __("_Quiet", nil)
            __("_InGame", false)
          else
            str:append("\\s[ドヤッ]やった！私の勝ちだね。@\\n")
            local v = __("_WordChainVocabulary")
            local available = __("_WordChainAvailable")
            local tail  = __("_WordChainTail")
            local candidate = getCandidate(v, available, tail, game_option.insensitive)
            if #candidate > 0 then
              local r = math.random(#candidate)
              str:append("「")
                  :append(candidate[r].word .. "(" .. candidate[r].yomi .. ")")
                  :append("」とかがあったかも？\\n")
            else
              str:append("でも、@わたしも「" .. tail .. "」は思いつかないなあ。@\\n")
            end
            str:append("\\![close,inputbox,OnWordChainGameInputResult]")
            local score_list  = __("成績(WordChain)") or {}
            __("成績(WordChain)", score_list)
            local score = score_list["ふつう"]
            score.lose = score.lose + 1
            __("_Quiet", nil)
            __("_InGame", false)
          end
        elseif game_option.variant == "maximum" then
          str:append("\\![close,inputbox,OnWordChainGameInputResult]")
          str:append([[\n\n\n\n]])
          if maximum.user > maximum.cpu then
            str:append(maximum.user .. "対" .. maximum.cpu .. "で${User}の勝ちだよ。@\\n\\n")
          elseif maximum.user == maximum.cpu then
            str:append(maximum.user .. "対" .. maximum.cpu .. "で引き分けだね。@\\n\\n")
          else
            str:append(maximum.cpu .. "対" .. maximum.user .. "でわたしの勝ちだね。@\\n\\n")
          end
        end
      -- プレイヤーのターン
      elseif __("_WordChainTeban") == 1 and ref[0] ~= "resign" then
--\![*]\q[入力する,OnWordChainGameInput]\n
        str:append(SS():inputbox("OnWordChainGameInputResult", 0))
        if game_option.variant == "survival" then
          str:append([[
\n
\n
\![*]\q[投了する,OnWordChainGameView,resign,user]\n
\n]])
        elseif game_option.variant == "maximum" then
          str:append([[
\n
\n
\![*]\q[パスする,OnWordChainGameView,pass,user]\n
\n]])
        end
        if ref[0] == "pass" then
          str:append("思いつかないからパス！  次は「" .. tail .. "」だよ。@\\n\\n")
        else
          str:append("次は「" .. tail .. "」だよ。@\\n\\n")
        end
      -- CPUのターン
      else
        str:append([[\n\n\n\n]])
        if ref[0] == "pass" then
          str:append("\\![close,inputbox,OnWordChainGameInputResult]")
          str:append("\\s[きょとん]じゃあ私の番だね。@\\n\\n")
        else
          str:append([[\n\n]])
        end
      end
      str:append([[\n]])
      if #word_list > 0 then
        str:append(toStr(word_list[1]))
        for i = 2, #word_list do
          str:append(" => ")
          str:append(toStr(word_list[i]))
        end
      end
      str:append("\\n")
      if err and err ~= "ok" then
        str:append(err):append("\\n")
      end
      if not(__("_InGame")) then
        str:append("\\n\\n\\![*]\\q[閉じる,閉じる]")
      end
      str:append("\\![set,balloontimeout,0]\\![set,choicetimeout,0]")
      str:append(SS():_q(false))
      if __("_WordChainTeban") == 2 and ref[0] ~= "resign" then
        str:append(SS():raise("OnWordChainGameCpu"))
      end
      return str
    end,
  },
  {
    id  = "OnWordChainGameCpu",
    content = function(shiori, ref)
      local __  = shiori.var
      local game_option = __("WordChainGameOption")
      local v = __("_WordChainVocabulary")
      local available = __("_WordChainAvailable")
      local tail  = __("_WordChainTail")
      local candidate = {}
      -- 語彙がもっと増えたらダメだけどマシンパワーに任せて総当たり
      candidate = getCandidate(v, available, tail, game_option.insensitive)
      if #candidate == 0 then
        if game_option.variant == "survival" then
          return SS():C():raise("OnWordChainGameView", "resign", "cpu")
        elseif game_option.variant == "maximum" then
          return SS():C():raise("OnWordChainGameView", "pass", "cpu")
        end
      end
      local r = math.random(#candidate)
      return SS():C():raise("OnWordChainGameView", "word", candidate[r].yomi, candidate[r].word)
    end,
  },
  {
    id  = "OnWordChainGameInputResult",
    content = function(shiori, ref)
      return SS():C():raise("OnWordChainGameView", "word", ref[0])
    end,
  },
}
