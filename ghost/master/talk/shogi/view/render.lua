local utf8          = require("lua-utf8")
local KifuPlayer           = require("kifu_player")
local SS            = require("sakura_script")
local SSBindUpdater = require("ss_bind_updater")
local StringBuffer  = require("string_buffer")
local Color         = KifuPlayer.Color
local CSA           = KifuPlayer.CSA

local updater = SSBindUpdater()

local function getSquareCategory(x, y, reverse)
  if reverse then
    x = 10 - x
    y = 10 - y
  end
  return  x .. y
end

local color_str = {
  [Color.BLACK] = "BLACK",
  [Color.WHITE] = "WHITE",
}

local function getSquareParts(piece, reverse)
  assert(piece)
  local color = piece.color
  if reverse then
    color = Color.reverse(color)
  end
  return color_str[color] .. "_" .. piece.kind
end

local function getHandCategory(color, kind, reverse)
  if reverse then
    color = Color.reverse(color)
  end
  return color_str[color] .. "_" .. kind
end

local function getDummyColor(color, reverse)
  if reverse then
    color = Color.reverse(color)
  end
  return "DUMMY_" .. color_str[color]
end

local function getHandNumCategory(color, kind, reverse)
  return getHandCategory(color, kind, reverse) .. "_NUM"
end

local _kanji2part = {
  ["-"] = "HAIFUN",
  ["▲"] = "SENTE",
  ["△"] = "GOTE",
  -- １〜９
  ["１"]  = "n1",
  ["２"]  = "n2",
  ["３"]  = "n3",
  ["４"]  = "n4",
  ["５"]  = "n5",
  ["６"]  = "n6",
  ["７"]  = "n7",
  ["８"]  = "n8",
  ["９"]  = "n9",
  -- 一〜九
  ["一"]  = "k1",
  ["二"]  = "k2",
  ["三"]  = "k3",
  ["四"]  = "k4",
  ["五"]  = "k5",
  ["六"]  = "k6",
  ["七"]  = "k7",
  ["八"]  = "k8",
  ["九"]  = "k9",
  --同
  ["同"]  = "DOU",
  --歩〜玉
  ["歩"]  = "FU",
  ["と"]  = "TO",
  ["香"]  = "KY",
  ["桂"]  = "KE",
  ["銀"]  = "GI",
  ["金"]  = "KI",
  ["角"]  = "KA",
  ["馬"]  = "UM",
  ["飛"]  = "HI",
  ["龍"]  = "RY",
  ["玉"]  = "OU",
  --右〜左
  ["右"]  = "R",
  ["直"]  = "C",
  ["左"]  = "L",
  --上〜引
  ["上"]  = "U",
  ["寄"]  = "M",
  ["引"]  = "D",
  --成不成打
  ["成"]  = "P",
  ["不"]  = "NP",
  ["打"]  = "H",
}

local function kanji2part(k)
  return _kanji2part[k]
end

local _special2part = {
  ["投了"]  = "TORYO",
  ["中断"]  = "CHUDAN",
  ["千日手"]  = "SENNICHITE",
  ["封じ手"]  = "FUJITE",
  ["待った"]  = "MATTA",
  ["反則勝ち"]  = "ILLEGAL_WIN",
  ["反則負け"]  = "ILLEGAL_LOSE",
  ["持将棋"]  = "JISHOGI",
  ["入玉勝ち"]  = "NYUGYOKU_WIN",
  ["入玉"]  = "NYUGYOKU",
  ["トライ"]  = "TRY",
  ["時間切れ"]  = "TIME_UP",
  -- 独自拡張
  ["パス"]  = "PASS",
}

local function special2part(s)
  return _special2part[s]
end

local M = {
  {
    id  = "OnShogiRenderChangeMode",
    content = function(shiori, ref)
      updater:mode(tonumber(ref[0]))
    end,
  },
  {
    id  = "2headLeft",
    content = function(shiori, ref)
      return SS():raise("OnShogiViewControl", "move", "head", "OnShogiView")
    end,
  },
  {
    id  = "2backward10Left",
    content = function(shiori, ref)
      return SS():raise("OnShogiViewControl", "move", "backward10", "OnShogiView")
    end,
  },
  {
    id  = "2backwardLeft",
    content = function(shiori, ref)
      return SS():raise("OnShogiViewControl", "move", "backward", "OnShogiView")
    end,
  },
  {
    id  = "2forwardLeft",
    content = function(shiori, ref)
      return SS():raise("OnShogiViewControl", "move", "forward", "OnShogiView")
    end,
  },
  {
    id  = "2forward10Left",
    content = function(shiori, ref)
      return SS():raise("OnShogiViewControl", "move", "forward10", "OnShogiView")
    end,
  },
  {
    id  = "2tailLeft",
    content = function(shiori, ref)
      return SS():raise("OnShogiViewControl", "move", "tail", "OnShogiView")
    end,
  },
  {
    id  = "OnShogiRenderInitialize",
    content = function(shiori, ref)
      local __  = shiori.var
      updater = SSBindUpdater()
      updater:mode(__("描画モード"))
      shiori:talk("OnShogiRenderClear")
      shiori:talk("OnShogiRenderControlClear")
      return shiori:talk("OnShogiRenderShow") .. updater:toSS()
    end,
  },
  {
    id  = "OnShogiRenderShow",
    content = function(shiori, ref)
      return SS():p(2):s(12001)
    end,
  },
  {
    id  = "OnShogiRenderPre",
    content = function(shiori, ref)
      return updater:toSS()
    end,
  },
  {
    id  = "OnShogiRenderClear",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      local reverse = __("_BoardReverse")
      str:append(SS():p(2):b(-1):s(12001))
      -- 盤面
      for x = 1, 9 do
        for y = 1, 9 do
          local tag = getSquareCategory(x, y, reverse)
          --str:append(SS():bind(tag, nil, 0))
          updater:set(tag, nil, 0)
          --str:append(SS():bind("HIGHLIGHT_" .. tag, nil, 0))
          updater:set("HIGHLIGHT_" .. tag, nil, 0)
        end
      end
      -- 持ち駒
      for _, color in ipairs(Color.LIST) do
        for _, kind in ipairs(CSA.HAND) do
          local tag = getHandCategory(color, kind, reverse)
          --str:append(SS():bind(tag, nil, 0))
          updater:set(tag, nil, 0)
          --str:append(SS():bind(tag .. "_NUM", nil, 0))
          updater:set(tag .. "_NUM", nil, 0)
          --str:append(SS():bind("HIGHLIGHT_" .. tag, nil, 0))
          updater:set("HIGHLIGHT_" .. tag, nil, 0)
        end
      end
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiRenderControlClear",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      local reverse = __("_BoardReverse")
      -- 盤面
      for x = 1, 9 do
        for y = 1, 9 do
          local tag = getSquareCategory(x, y, reverse)
          --str:append(SS():bind("DUMMY_" .. tag, nil, 0))
          updater:set("DUMMY_" .. tag, nil, 0)
          --str:append(SS():bind("PROMOTE_WINDOW_" .. tag, nil, 0))
          updater:set("PROMOTE_WINDOW_" .. tag, nil, 0)
          --str:append(SS():bind("DUMMY_BLACK_PROMOTE_" .. tag, nil, 0))
          updater:set("DUMMY_BLACK_PROMOTE_" .. tag, nil, 0)
          --str:append(SS():bind("DUMMY_WHITE_PROMOTE_" .. tag, nil, 0))
          updater:set("DUMMY_WHITE_PROMOTE_" .. tag, nil, 0)
          --str:append(SS():bind("PROMOTE_" .. tag, nil, 0))
          updater:set("PROMOTE_" .. tag, nil, 0)
          --str:append(SS():bind("DUMMY_BLACK_UNPROMOTE_" .. tag, nil, 0))
          updater:set("DUMMY_BLACK_UNPROMOTE_" .. tag, nil, 0)
          --str:append(SS():bind("DUMMY_WHITE_UNPROMOTE_" .. tag, nil, 0))
          updater:set("DUMMY_WHITE_UNPROMOTE_" .. tag, nil, 0)
          --str:append(SS():bind("UNPROMOTE_" .. tag, nil, 0))
          updater:set("UNPROMOTE_" .. tag, nil, 0)
        end
      end
      -- 持ち駒
      for _, color in ipairs(Color.LIST) do
        for _, kind in ipairs(CSA.HAND) do
          local tag = getHandCategory(color, kind, reverse)
          --str:append(SS():bind("DUMMY_" .. tag, nil, 0))
          updater:set("DUMMY_" .. tag, nil, 0)
        end
      end
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiRenderBoard",
    content = function(shiori, ref)
      local str = StringBuffer()
      str:append(SS():p(2):s(12001))
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiRenderHighlight",
    content = function(shiori, ref)
      local x, y, num = ref[0], ref[1], tonumber(ref[2])
      num = num or 1
      if num == 1 then
        num = ""
      end
      updater:set("HIGHLIGHT_" .. x .. y, "HIGHLIGHT" .. num, 1)
      return "\\p[2]" .. updater:toSS()
    end
  },
  {
    id  = "OnShogiRenderSquare",
    content = function(shiori, ref)
      local __  = shiori.var
      local x, y, piece = ref[0], ref[1], ref[2]
      local reverse = __("_BoardReverse")
      local str = StringBuffer()
      local category  = getSquareCategory(x, y, reverse)
      if piece == "highlight" then
        --str:append(SS():bind("HIGHLIGHT_" .. category, "HIGHLIGHT", 1))
        updater:set("HIGHLIGHT_" .. category, "HIGHLIGHT", 1)
      elseif piece.kind == nil or piece.color == nil then
        updater:set(category, nil, 0)
      else
        local parts = getSquareParts(piece, reverse)
        --str:append(SS():bind(category, parts, 1))
        updater:set(category, parts, 1)
      end
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiRenderHand",
    content = function(shiori, ref)
      local __  = shiori.var
      local color, kind, num  = ref[0], ref[1], ref[2]
      local reverse = __("_BoardReverse")
      local str = StringBuffer()
      if num > 0 then
        --str:append(SS():bind(getHandCategory(color, kind, reverse), "PIECE", 1))
        updater:set(getHandCategory(color, kind, reverse), "PIECE", 1)
      end
      if num > 1 then
        --str:append(SS():bind(getHandNumCategory(color, kind, reverse), num, 1))
        updater:set(getHandNumCategory(color, kind, reverse), num, 1)
      else
        --str:append(SS():bind(getHandNumCategory(color, kind, reverse), nil, 0))
        updater:set(getHandNumCategory(color, kind, reverse), nil, 0)
      end
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiRenderPlayerName",
    content = function(shiori, ref)
      local t = ref[0]
      local str = StringBuffer()
      -- TODO stub
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiRenderMoveInfo",
    content = function(shiori, ref)
      local tesuu, move = ref[0], ref[1]
      local str = StringBuffer()
      local move  = move or "-"
      -- TODO stub
      local cnt = 0
      local h   = math.floor((tesuu % 1000) / 100)
      local t   = math.floor((tesuu % 100) / 10)
      local o   = math.floor(tesuu % 10)
      updater:set("MOVEINFO_100", nil, 0)
      if h > 0 then
        --str:append(SS():bind("MOVEINFO_100", h, 1))
        updater:set("MOVEINFO_100", h, 1)
      else
        --str:append(SS():bind("MOVEINFO_100", nil, 0))
        updater:set("MOVEINFO_100", nil, 0)
      end
      updater:set("MOVEINFO_10", nil, 0)
      if h > 0 or t > 0 then
        --str:append(SS():bind("MOVEINFO_10", t, 1))
        updater:set("MOVEINFO_10", t, 1)
      else
        --str:append(SS():bind("MOVEINFO_10", nil, 0))
        updater:set("MOVEINFO_10", nil, 0)
      end
      updater:set("MOVEINFO_1", nil, 0)
      --str:append(SS():bind("MOVEINFO_1", o, 1))
      updater:set("MOVEINFO_1", o, 1)
      for i = 1, 8 do --  一番長い▲４三銀右引不成で8文字
        --str:append(SS():bind("MOVEINFO_M" .. i, nil , 0))
        updater:set("MOVEINFO_M" .. i, nil , 0)
      end
      local part = special2part(move:sub(4))
      if part then
        --str:append(SS():bind("MOVEINFO_M1", part, 1))
        updater:set("MOVEINFO_M1", part, 1)
      else
        for _, code in utf8.next, move do
          cnt = cnt + 1
          local c = utf8.char(code)
          local part  = kanji2part(c)
          if part then
            --str:append(SS():bind("MOVEINFO_M" .. cnt, part, 1))
            updater:set("MOVEINFO_M" .. cnt, part, 1)
          else
            --str:append(SS():bind("MOVEINFO_M" .. cnt, nil, 0))
            updater:set("MOVEINFO_M" .. cnt, nil, 0)
          end
        end
      end
      --print("MoveInfo: " .. str:tostring())
      --return str:tostring()
      return updater:toSS()
    end,
  },
  {
    id  = "OnShogiRenderController",
    content = function(shiori, ref)
      local str = StringBuffer()
      -- TODO stub
      str:append(SS():p(2):s(12002))
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiRenderPost",
    content = function(shiori, ref)
      return updater:toSS()
    end,
  },
  {
    id  = "OnShogiRenderPlayerTurnBeginPre",
    content = function(shiori, ref)
      return shiori:talk("OnShogiRenderControlClear")
      --print("render")
      -- TODO comment
    end,
  },
  {
    id  = "OnShogiRenderPlayerTurnBeginSquare",
    content = function(shiori, ref)
      local __  = shiori.var
      local color, x, y, id  = ref[0], ref[1], ref[2], ref[3]
      local reverse = __("_BoardReverse")
      -- TODO stub
      local str = StringBuffer()
      local tag = getSquareCategory(x, y, reverse)
      --print("TurnBegin: " .. tag)
      --str:append(SS():bind("DUMMY_" .. tag, "DUMMY", 1))
      updater:set("DUMMY_" .. tag, "DUMMY", 1)
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiRenderPlayerTurnBeginHand",
    content = function(shiori, ref)
      local __  = shiori.var
      local color, piece  = ref[0], ref[1]
      local reverse = __("_BoardReverse")
      local str = StringBuffer()
      -- TODO stub
      local tag = getHandCategory(color, piece, reverse)
      --str:append(SS():p(2):bind("DUMMY_" .. tag, "DUMMY", 1))
      updater:set("DUMMY_" .. tag, "DUMMY", 1)
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiRenderPlayerTurnBeginPost",
    content = function(shiori, ref)
      -- TODO stub
      return updater:toSS()
    end,
  },
  {
    id  = "OnShogiRenderSelectPiecePre",
    content = function(shiori, ref)
      return shiori:talk("OnShogiRenderControlClear")
      -- TODO HIGHLIGHT2の非表示
    end,
  },
  {
    id  = "OnShogiRenderSelectPiece",
    content = function(shiori, ref)
      local __  = shiori.var
      local id, color = ref[0], ref[1]
      local list  = __("_PlayerMoves")[id]
      local reverse = __("_BoardReverse")
      --print("list, id: " .. type(list) .. " " .. type(id))
      assert(id)
      local str = StringBuffer()
      -- TODO stub
      if tonumber(id) then
        local x, y  = math.floor(id / 10), id % 10
        local id  = getSquareCategory(x, y, reverse)
        --str:append(SS():p(2):bind("HIGHLIGHT_" .. id, "HIGHLIGHT2", 1))
        updater:set("HIGHLIGHT_" .. id, "HIGHLIGHT2", 1)
      else
        -- TODO stub
        local id  = getHandCategory(color, id, reverse)
        --str:append(SS():p(2):bind("HIGHLIGHT_" .. id, "HIGHLIGHT2", 1))
        updater:set("HIGHLIGHT_" .. id, "HIGHLIGHT2", 1)
      end
      -- OnMouseEnter, OnMouseLeave,OnMouseClickの追加
      for k, move in pairs(list) do
        local tag = getSquareCategory(move.to.x, move.to.y, reverse)
        --str:append(SS():bind("DUMMY_" .. tag, "DUMMY", 1))
        if __("GameOption").control_guide then
          updater:set("HIGHLIGHT_" .. tag, "HIGHLIGHT3", 1)
        end
        updater:set("DUMMY_" .. tag, "DUMMY", 1)
        --print("SelectPiece: " .. color_str[move.color] .. move.piece)
      end
      --print("renderSelect: " .. str:tostring())
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiRenderSelectPiecePost",
    content = function(shiori, ref)
      -- TODO stub
      return updater:toSS()
    end,
  },
  {
    id  = "OnShogiRenderSelectPromotePre",
    content = function(shiori, ref)
      return shiori:talk("OnShogiRenderControlClear")
    end,
  },
  {
    id  = "OnShogiRenderSelectPromote",
    content = function(shiori, ref)
      local __  = shiori.var
      local id1, id2  = ref[0], ref[1]
      local move  = __("_PlayerMoves")[id1][id2]
      local reverse = __("_BoardReverse")
      -- TODO stub
      -- OnMouseEnter, OnMouseLeave,OnMouseClickの追加
      local str = StringBuffer()
      local color_str = {
        [Color.BLACK] = "BLACK",
        [Color.WHITE] = "WHITE",
      }
      local x = tonumber(string.sub(id2, 1, 1))
      local y = tonumber(string.sub(id2, 2, 2))
      local tag = getSquareCategory(x, y, reverse)
      local dummy_color = getDummyColor(move.color, reverse)
      --[[
      str:append(
        SS():bind("PROMOTE_WINDOW_" .. tag, "WINDOW", 1)
            :bind(dummy_color .. "_PROMOTE_" .. tag, "DUMMY", 1)
            :bind("PROMOTE_" .. tag, getHandCategory(move.color, KifuPlayer.Misc.promote(move.piece), reverse), 1)
            :bind(dummy_color .. "_UNPROMOTE_" .. tag, "DUMMY", 1)
            :bind("UNPROMOTE_" .. tag, getHandCategory(move.color, KifuPlayer.Misc.unpromote(move.piece), reverse), 1)
      )
      --]]
      updater:set("PROMOTE_WINDOW_" .. tag, "WINDOW", 1)
      updater:set(dummy_color .. "_PROMOTE_" .. tag, "DUMMY", 1)
      updater:set("PROMOTE_" .. tag, getHandCategory(move.color, KifuPlayer.Misc.promote(move.piece), reverse), 1)
      updater:set(dummy_color .. "_UNPROMOTE_" .. tag, "DUMMY", 1)
      updater:set("UNPROMOTE_" .. tag, getHandCategory(move.color, KifuPlayer.Misc.unpromote(move.piece), reverse), 1)
      print(str:tostring())
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiRenderSelectPromotePost",
    content = function(shiori, ref)
      -- TODO stub
      return updater:toSS()
    end,
  },
  {
    id  = "OnShogiRenderPlayerTurnEnd",
    content = function(shiori, ref)
      -- TODO stub
      -- OnMouseEnter, OnMouseLeave,OnMouseClickの削除
      -- PROMOTE*の非表示
      shiori:talk("OnShogiRenderControlClear")
      return SS():p(2):tostring() .. updater:toSS()
    end,
  },
  {
    id  = "OnShogiRenderGameController",
    content = function(shiori, ref)
      -- TODO stub
    end,
  },
  {
    id  = "2Right",
    content = function(shiori, ref)
      local __  = shiori.var
      if __("_InGame") then
        if __("_GameState") ~= "begin" then
          __("_GameState", "begin")
          __("_Sfen", nil) -- 強制的に盤面を再描画させる
          return SS():raise("OnShogiGamePlayerTurnBegin"):tostring()
        end
      end
    end,
  },
}

for x = 1, 9 do
  for y = 1, 9 do
    local tag = getSquareCategory(x, y, false)
    local tag_rev = getSquareCategory(x, y, true)
    local t = {
      id  = "2" .. "DUMMY_" .. tag .. "Left",
      content = function(shiori, ref)
        local __  = shiori.var
        --print("Click: DUMMY_" .. x .. y)
        local state = __("_GameState")
        if state == "begin" then
          __("_GameState", "select")
          if __("_BoardReverse") then
            __("_GamePieceFrom", tag_rev)
          else
            __("_GamePieceFrom", tag)
          end
          -- raiseはreverseしていないものを送る
          return SS():raise("OnShogiGamePlayerSelectPiece", tag):tostring()
        elseif state == "select" then
          -- TODO stub
          if __("_BoardReverse") then
            __("_GamePieceTo", tag_rev)
          else
            __("_GamePieceTo", tag)
          end
          local str = StringBuffer()
          str:append(SS():raise("OnShogiGamePlayerSelectPromote"))
          return str:tostring()
        end
      end,
    }
    table.insert(M, t)
  end
end

for _, color in ipairs(Color.LIST) do
  for _, piece in ipairs(CSA.HAND) do
    local tag = getHandCategory(color, piece, false)
    local tag_rev = getHandCategory(color, piece, true)
    local t = {
      id  = "2" .. "DUMMY_" .. tag .. "Left",
      content = function(shiori, ref)
        local __  = shiori.var
        print("Click: " .. color_str[color] .. piece)
        local state = __("_GameState")
        if state == "begin" then
          __("_GameState", "select")
          __("_GamePieceFrom", piece)
          return SS():raise("OnShogiGamePlayerSelectPiece", piece):tostring()
        end
        return nil
      end,
    }
    table.insert(M, t)
  end
end

for x = 1, 9 do
  for y = 1, 9 do
    for _, color in ipairs(Color.LIST) do
      local tag = getSquareCategory(x, y, false)
      local dummy_color = getDummyColor(color, false)
      local t = {
        id  = "2" .. dummy_color .. "_PROMOTE_" .. tag .. "Left",
        content = function(shiori, ref)
          print("Click: PROMOTE_" .. tag)
          return SS():raise("OnShogiGamePlayerTurnEnd", nil, nil, true):tostring()
        end,
      }
      table.insert(M, t)
      local t = {
        id  = "2" .. dummy_color .. "_UNPROMOTE_" .. tag .. "Left",
        content = function(shiori, ref)
          print("Click: UNPROMOTE_" .. tag)
          return SS():raise("OnShogiGamePlayerTurnEnd", nil, nil, false):tostring()
        end,
      }
      table.insert(M, t)
    end
  end
end

return M
