local KifuPlayer    = require("kifu_player")
local Judgement     = require("talk.game._judgement")
local SS            = require("sakura_script")
local StringBuffer  = require("string_buffer")
local Process       = require("process")
local USI           = require("usi")

local function createTimer(shiori, timeout, callback)
  assert(tonumber(timeout))
  assert(type(callback) == "function")

  local __  = shiori.var
  local str = StringBuffer()
  __("_Callback", callback)
  --str:append(SS():C():timerraise({
  str:append(SS():timerraise({
    ID    = "OnShogiEngineTimeout",
    time  = timeout,
    loop  = false,
  }))
  return str:tostring()
end

local function destroyTimer()
  local str = StringBuffer()
  --str:append(SS():C():timerraise({
  str:append(SS():timerraise({
    ID  = "OnShogiEngineTimeout",
    time  = 0,
    loop  = true,
  }))
  return str:tostring()
end

local function calcJudge(score)
  local judge = Judgement.equality
  if score == 9999 then
    judge = Judgement.plus_mate
  elseif score == -9999 then
    judge = Judgement.minus_mate
  elseif score >= 2500 then
    judge = Judgement.won
  elseif score >= 1500 then
    judge = Judgement.winning
  elseif score >= 800 then
    judge = Judgement.plus
  elseif score >= 300 then
    judge = Judgement.plus_equal
  elseif score > -300 then
    judge = Judgement.equality
  elseif score > -800 then
    judge = Judgement.minus_equal
  elseif score > -1500 then
    judge = Judgement.minus
  elseif score > -2500 then
    judge = Judgement.losing
  else
    judge = Judgement.lost
  end
  return judge
end

local function isInaccuracy(judge, diff)
end

local judge2blunder = {
  [Judgement.plus_mate]   = {
    player  = 1, -- unreached
    cpu     = -1,
  },
  [Judgement.won]         = {
    player  = 9999,
    cpu     = -1000,
  },
  [Judgement.winning]     = {
    player  = 1000,
    cpu     = -700,
  },
  [Judgement.plus]        = {
    player  = 600,
    cpu     = -600,
  },
  [Judgement.plus_equal]  = {
    player  = 500,
    cpu     = -500,
  },
  [Judgement.equality]    = {
    player  = 400,
    cpu     = -400,
  },
  [Judgement.minus_equal] = {
    player  = 500,
    cpu     = -500,
  },
  [Judgement.minus]       = {
    player  = 600,
    cpu     = -600,
  },
  [Judgement.losing]      = {
    player  = 700,
    cpu     = -1000,
  },
  [Judgement.lost]        = {
    player  = 1000,
    cpu     = -9999,
  },
  [Judgement.minus_mate]  = {
    player  = 1,
    cpu     = -1, --unreached
  },
  [Judgement.equalize]    = {
    player  = 0,
    cpu     = 0,
  },
  [Judgement.unclear]     = {
    player  = 0,
    cpu     = 0,
  },
  [Judgement.critical]    = {
    player  = 0,
    cpu     = 0,
  },
}

local function isBlunder(judge, diff)
  local blunder = judge2blunder[judge]
  local ret = 0
  if diff > blunder.player then
    ret = 1
  elseif diff < blunder.cpu then
    ret = -1
  end
  if judge == Judgement.plus_mate or judge == Judgement.minus_mate then
    ret = ret * 2
  end
  return ret
end

return {
  {
    passthrough = true,
    id  = "OnShogiEngineOption",
    content = function(shiori, ref)
      local __        = shiori.var
      local str       = StringBuffer(SS():_q(true))
      local name      = ref[0]
      local value     = ref[1]
      local list      = __("EngineList") or {}
      local selected  = __("SelectedEngine")
      local engine    = list[selected]
      if type(engine) ~= "table" then
        str:append(SS():p(0))
            :append("エンジンが選択されてないよ")
            :append(SS():_w(1000):raise("OnShogiGameMenu"))
        return str:tostring()
      end

      local option  = engine.option
      table.sort(option)
      if name and value then
        if option[name].type == "spin" then
          -- TODO validate
          option[name].value  = value
        elseif option[name].type == "filename" then
          option[name].value  = value
        elseif option[name].type == "check" then
          option[name].value  = value == "false"
        elseif option[name].type == "combo" then
          local index = nil
          for i, v in ipairs(option[name].var) do
            if v == value then
              index = i
              break
            end
          end
          if index then
            option[name].value  = option[name].var[index % #option[name].var + 1]
          end
        end
      end
      for k, v in pairs(option) do
        if v.value == nil then
          v.value = v.default
        end
        str:append(k):append(SS():_l(160)):append(v.value)
        if v.type == "spin" then
          str:append(SS():_l(240):q("【変更】", "OnShogiEngineChangeOption", k, v.value))
        elseif v.type == "combo" or v.type == "check" then
          str:append(SS():_l(240):q("【変更】", "OnShogiEngineOption", k, v.value))
        elseif v.type == "filename" then
          str:append(SS():_l(240):q("【変更】", "OnShogiEngineChangeOption", k, v.value))
        elseif v.type == "string" then
          str:append(SS():_l(240):q("【変更】", "OnShogiEngineChangeOption", k, v.value))
        else
          -- TODO button
        end
        str:append("\\n")
      end
      str:append("\\n")
      str:append("\\![*]")
      str:append(SS():q("戻る", "OnShogiGameMenu"))
      str:append(SS():_q(false))
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiEngineChangeOption",
    content = function(shiori, ref)
      local __        = shiori.var
      local str       = StringBuffer()
      local name      = ref[0]
      local value     = ref[1]
      assert(name and value)
      __("_ChangingOptionName", name)
      str:append(SS():inputbox("OnShogiEngineChangingOption", 0, value))
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiEngineChangingOption",
    content = function(shiori, ref)
      local __        = shiori.var
      local str       = StringBuffer()
      local name  = __("_ChangingOptionName")
      local value     = ref[0]
      str:append(SS():raise("OnShogiEngineOption", name, value))
      return str:tostring()
    end,
  },
  {
    passthrough = true,
    id  = "OnManageShogiEngine",
    content = function(shiori, ref)
      local __        = shiori.var
      local str       = StringBuffer()
      local list      = __("EngineList") or {}
      local name      = ref[0]

      str:append(SS():_q(true))
      str:append(SS():p(0)):append("使用するエンジンを選択してね。\\n\\n")

      __("EngineList", list)
      str:append("エンジン一覧\\n")
      if name and list[name] then
        __("SelectedEngine", name)
      end

      local selected  = __("SelectedEngine") or ""
      for k, v in pairs(list) do
        local engine  = v
        str:append(SS():q(k, "OnManageShogiEngine", engine.name))
        if k == selected then
          str:append(SS():_l(160)):append("【選択中】")
        end
        str:append(SS():_l(220):q("【削除】", "OnShogiEngineDelete", engine.name))
        str:append("\\n")
      end
      str:append("\\n")
      str:append("【")
          :append(SS():q("追加", "OnShogiEngineAdd"))
          :append("】\\n")
      str:append("\\n")
      str:append("\\![*]")
      str:append(SS():q("戻る", "OnShogiGameMenu"))

      str:append(SS():_q(false))

      return str:tostring()
    end,
  },
  {
    id  = "OnShogiEngineAdd",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      if ref[0] == "open" then
        local path  = ref[2]
        str:append(SS():C():raise("OnShogiEngineSpawn", path))
      elseif ref[0] == "cancel" then
        str:append(SS():p(0)):append("キャンセルしたよ")
        str:append(SS():_w(1000):raise("OnManageShogiEngine"))
      elseif ref[0] then
        -- TODO error
        print("Unknown ref0: " .. ref[0])
      else
        str:append(SS():dialog("open", {
          title   = "エンジン選択",
          filter  = "実行ファイル|*.exe|全てのファイル|*.*",
          id      = "OnShogiEngineAdd",
          dir     = __("_path") .. "engine",
        }))
      end
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiEngineDelete",
    content = function(shiori, ref)
      local __        = shiori.var
      local engine_name = ref[0]
      local list  = __("EngineList")
      local selected  = __("SelectedEngine")
      list[engine_name] = nil
      if selected == engine_name then
        __("SelectedEngine", nil)
      end
      return SS():raise("OnManageShogiEngine"):tostring()
    end,
  },
  {
    id  = "OnShogiEngineSpawn",
    content = function(shiori, ref)
      local __      = shiori.var
      local str     = StringBuffer()
      local path    = assert(ref[0])
      local escaped = string.gsub(path, "\\", "\\\\")
      local engine  = {command = path, option = {}}
      local process = shiori:saori("process")
      process("uniqueid", __("_uniqueid"))
      local ret = process("spawn", path, nil, true, "OnShogiEngineChildProcess")
      __("_EnginePID", ret())

      if tonumber(ret()) >= 0 then
        process("send", __("_EnginePID"), USI.tostring{command = USI.Command.USI})
        __("_NewEngine", engine)
        local ret = createTimer(shiori,
            10000, function(data)
              if data.command == USI.Command.INFO then
                if data.str then
                  print(table.concat(data.str, " "))
                end
              elseif data.command == USI.Command.ID then
                if data.name then
                  engine.name = data.name
                elseif data.author then
                  engine.author = data.author
                end
              elseif data.command == USI.Command.OPTION then
                assert(data.name)
                local s = nil
                if data.default ~= nil then
                  s = data.name .. ": " .. tostring(data.default)
                else
                  s = data.name
                end
                print(s)
                engine.option[data.name]  = data
              elseif data.command == USI.Command.USIOK then
                return true, SS():raise("OnRegisterShogiEngine")
              end
              return nil
            end)
        str:append(SS():C()):append(ret)
        str:append(SS():p(0):_q(true))
        str:append(escaped)
        str:append("を起動中")
        str:append(SS():_q(false))
      else
        str:append(SS():p(0)):append(escaped):append("の起動に失敗したよ\\n")
        str:append(SS():_w(1000):raise("OnManageShogiEngine"))
      end
      return str:tostring()
    end,
  },
  {
    id  = "OnRegisterShogiEngine",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      local engine  = assert(__("_NewEngine"))
      local list  = __("EngineList") or {}
      __("EngineList", list)
      __("NewEngine", nil)
      list[engine.name] = engine
      shiori:talk("OnQuitShogiEngine")
      str:append(SS():p(0)):append(engine.name)
      str:append("を登録したよ"):append("\\n")
      str:append(SS():_w(1000):raise("OnManageShogiEngine"))
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiEngineTimeout",
    content = function(shiori, ref)
      local str = StringBuffer()
      shiori:talk("OnQuitShogiEngine")
      str:append(SS():p(0)):append("タイムアウトしたよ")
      str:append(SS():_w(1000):raise("OnShogiGameMenu"))
      return str:tostring()
    end,
  },
  {
    id  = "OnQuitShogiEngine",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      local process = shiori:saori("process")
      process("send", __("_EnginePID"), USI.tostring({command = USI.Command.QUIT}))
      shiori:talk("OnDespawnShogiEngine")
    end,
  },
  {
    id  = "OnAnalysisGameRecord",
    content = function(shiori, ref)
      local __          = shiori.var
      local prev_score  = nil
      local prev_judge  = Judgement.equality
      local prev_sign   = nil
      local turn_count  = 0
      local last_judge  = 0
      local judge = {}
      local point_move  = {}
      local judge_dist  = {
        -- plus_mate - minus_mate
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      }
      local judge_dist2 = {
        -- plus - minus
        0, 0, 0,
      }
      local score_list  = assert(__("_ScoreList"))
      for _, v in ipairs(score_list) do
        print(v.tesuu .. ": " .. v.score)
        local current_judge = calcJudge(v.score)
        judge_dist[current_judge] = judge_dist[current_judge] + 1
        if current_judge <= Judgement.plus then
          judge_dist2[1] = judge_dist2[1] + 1
        elseif current_judge >= Judgement.minus then
          judge_dist2[3] = judge_dist2[3] + 1
        else
          judge_dist2[2] = judge_dist2[2] + 1
        end

        if prev_score ~= nil then -- 駒落ち等では初期スコアが0でない可能性
          if prev_judge < Judgement.minus and
              current_judge >= Judgement.minus and
              prev_sign ~= 1 then
            if prev_sign == -1 then
              turn_count  = turn_count + 1
            end
            prev_sign = 1
            table.insert(judge, {n = v.tesuu, sign = 1})
          end
          if prev_judge > Judgement.plus and
              current_judge <= Judgement.plus and
              prev_sign ~= -1 then
            if prev_sign == 1 then
              turn_count  = turn_count + 1
            end
            prev_sign = -1
            table.insert(judge, {n = v.tesuu, sign = -1})
          end

          local point = isBlunder(prev_judge, v.score - prev_score)
          if point ~= 0 then
            local n
            if point == 1 then
              n = v.tesuu - 1 -- 直前のユーザーの手が悪手
            else
              n = v.tesuu - 2 -- 一手前の自分の手が悪手
            end
            table.insert(point_move, {n = n, sign = point})
          end
        end

        prev_score  = v.score
        prev_judge  = current_judge
      end
      if #score_list > 0 then
        local last_score  = score_list[#score_list]
        last_judge  = calcJudge(last_score.score)
        if last_judge <= Judgement.winning then
          last_judge  = 2
        elseif last_judge <= Judgement.plus then
          last_judge  = 1
        elseif last_judge < Judgement.minus then
          last_judge  = 0
        elseif last_judge < Judgement.losing then
          last_judge  = -1
        elseif last_judge <= Judgement.minus_mate then
          last_judge  = -2
        end
      end
      for i, v in ipairs(judge_dist) do
        print(i .. " => " .. v)
      end
      print("last judge: " .. tostring(last_judge))
      __("_AnalysisResult_Judgement", judge)
      __("_AnalysisResult_JudgementDistribution2", judge_dist2)
      __("_AnalysisResult_PointMove", point_move)
      __("_AnalysisResult_TurnCount", turn_count)
      __("_AnalysisResult_LastJudgement", last_judge)
    end,
  },
  {
    id  = "OnDespawnShogiEngine",
    content = function(shiori, ref)
      local __        = shiori.var
      local process = shiori:saori("process")
      process("despawn", __("_EnginePID"))
      __("_InGame", false)
    end,
  },
  {
    id  = "OnStartShogiEngine",
    content = function(shiori, ref)
      local __        = shiori.var
      local str       = StringBuffer()
      local list      = __("EngineList") or {}
      local selected  = __("SelectedEngine")
      local engine    = list[selected]
      if engine == nil then
        str:append(SS():p(0)):append("エンジンが選択されてないよ")
        str:append(SS():raise("OnShogiGameMenu"))
        return str:tostring()
      end
      local process = shiori:saori("process")
      process("uniqueid", __("_uniqueid"))
      local ret = process("spawn", engine.command, nil, true, "OnShogiEngineChildProcess")
      __("_EnginePID", ret())

      if tonumber(ret()) >= 0 then
        process("send", __("_EnginePID"), USI.tostring({command = USI.Command.USI}))
        local s         = createTimer(shiori, 10000, function(data)
          if data.command == USI.Command.USIOK then
            return true, SS():raise("OnShogiEngineReady")
          end
        end)
        str:append(s)
      else
        str:append("起動に失敗したよ"):append(SS():raise("OnShogiGameMenu"))
      end
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiEngineReady",
    content = function(shiori, ref)
      local __        = shiori.var
      local str       = StringBuffer()
      local list      = assert(__("EngineList"))
      local selected  = assert(__("SelectedEngine"))
      local process   = shiori:saori("process")
      local engine    = list[selected]
      local game_option = assert(__("GameOption"))
      process("send", __("_EnginePID"), USI.tostring({
        command = USI.Command.SETOPTION,
        name    = "USI_Ponder",
        value   = true,
      }))
      for k, v in pairs(engine.option) do
        local value = v.value or v.default
        if k == "Threads" then
          value = 1
        end
        print("setoption " .. k .. " value: " .. tostring(value))
        if value ~= nil then
          process("send", __("_EnginePID"), USI.tostring({
            command = USI.Command.SETOPTION,
            name    = k,
            value   = value,
          }))
        else
          process("send", __("_EnginePID"), USI.tostring({
            command = USI.Command.SETOPTION,
            name    = k,
          }))
        end
      end
      process("send", __("_EnginePID"), USI.tostring({command = USI.Command.ISREADY}))
      local s         = createTimer(shiori, 10000, function(data)
        if data.command == USI.Command.READYOK then
          return true, SS():raise("OnShogiEngineNewGame")
        end
      end)
      str:append(s)
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiEngineNewGame",
    content = function(shiori, ref)
      local __        = shiori.var
      local str       = StringBuffer()
      local process   = shiori:saori("process")
      process("send", __("_EnginePID"), USI.tostring({command = USI.Command.USINEWGAME}))
      str:append(SS():raise("OnShogiGameInit"))
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiGameEngineTurnBegin",
    content = function(shiori, ref)
      local __        = shiori.var
      local str       = StringBuffer()
      local process   = shiori:saori("process")
      local player    = KifuPlayer.getInstance()
      local _, init, moves  = player:toUSI()
      local options   = __("GameOption")
      local time  = math.floor(math.sqrt((player:getTesuu() + 1) * 10) * 1000)
      if options.time_limit then
        time  = 3000
      end
      local ponder  = __("_Ponder")
      local ponderhit = false
      __("_Ponder", nil)
      if ponder ~= nil then
        if moves[#moves] == ponder then
          ponderhit = true
          process("send", __("_EnginePID"), USI.tostring({
            command   = USI.Command.PONDERHIT,
          }))
        else
          str:append(createTimer(shiori, 10000, function(data)
            if data.command == USI.Command.BESTMOVE then
              return true, SS():raise("OnShogiGameEngineTurnBegin")
            end
          end))
          process("send", __("_EnginePID"), USI.tostring({
            command   = USI.Command.STOP,
          }))
          return str
        end
      end
      if not(ponderhit) then
        if init[1] == "startpos" then
          process("send", __("_EnginePID"), USI.tostring({
            command   = USI.Command.POSITION,
            startpos  = true,
            moves     = moves,
          }))
        else
          process("send", __("_EnginePID"), USI.tostring({
            command   = USI.Command.POSITION,
            sfen      = init,
            moves     = moves,
          }))
        end
        process("send", __("_EnginePID"), USI.tostring({
          command   = USI.Command.GO,
          btime = time,
          wtime = time,
          byoyomi = 2000,
        }))
      end
      --local s         = createTimer(shiori, "OnShogiGameEngineBestMove", "OnShogiGameEngineTimeout", true, 100, 100, function(data)
      local s         = createTimer(shiori, time + 3000, function(data)
        if data.command == USI.Command.INFO then
          if type(data.pv) == "table" and #data.pv > 0 then
            --print("PV: " .. data.pv[1])
            local prev_score  = __("_PrevScore")
            local prev_judge  = __("_PrevJudgement")
            local judge = prev_judge
            local score = nil
            if data.mate then
              -- 31500に設定されているエンジンが多いが
              -- 簡易棋譜解析機能の関係で9999にしている
              score = math.floor(data.score / math.abs(data.score)) * 9999
            elseif data.cp then
              score = data.score
            end
            if score then
              judge = calcJudge(score)
              local sid = "形勢_" .. Judgement.sid(judge) -- 正座のsid
              --print("prev: " .. prev_score .. " score: " .. score .. " sid: " .. sid)
              __("_CurrentScore", score)
              __("_CurrentJudgement", judge)
              local str = SS():p(0):s(sid):tostring()
              --print(str)
              if data.multipv then
                local moves = __("_CurrentMoves")
                if moves.nodes ~= data.nodes then
                  moves.nodes = data.nodes
                  moves.pv    = {}
                end
                moves.pv[data.multipv]  = {
                  score = score,
                  move  = data.pv[1]
                }
              end
              return nil, str
            end
          else
            --print("info received")
          end
        elseif data.command == USI.Command.BESTMOVE then
          print("bestmove: " .. data.bestmove)
          print("ponder:   " .. tostring(data.ponder))
          local score = __("_CurrentScore")
          local judge = __("_CurrentJudgement")
          __("_PrevScore", score)
          __("_PrevJudgement", judge)
          __("_BestMove", data.bestmove)
          __("_Ponder", data.ponder)
          local moves = __("_CurrentMoves")
          for i, v in ipairs(moves.pv) do
            print(i .. ": " .. v.score .. ", " .. v.move)
          end
          return true, SS():raise("OnShogiGameEngineBestMove")
        end
      end)
      str:append(s)
      str:append(SS():_q(true))
      str:append(shiori:talk("OnShogiDisplayMinimal", ref))
      str:append(shiori:talk("OnShogiDisplayHeader", ref))
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiGameEngineBestMove",
    content = function(shiori, ref)
      local __        = shiori.var
      local str       = StringBuffer()
      local move      = assert(__("_BestMove"))
      local player    = KifuPlayer.getInstance()
      player:appendMove(move)
      local move_format = player:getMoveFormat()
      local special = move_format.special
      if special then
        if special == "TORYO" then
          table.insert(__("_ScoreList"), {
            tesuu = player:getTesuu(),
            score = -9999,
          })
          local score = __("成績")[__("SelectedEngine")]
          score.win = score.win + 1
          shiori:talk("OnShogiEngineGameOver", "lose")
          shiori:talk("OnQuitShogiEngine")
          str:append(SS():p(0):s(5073)):append("負けました…")
              :append(SS():_w(2000):s(2205))
              :append(shiori:talk("OnShogiView", ref))
        end
      else
        local score = __("_CurrentScore")
        if __("_ScoreList") == nil then
          __("_ScoreList", {})
        end
        table.insert(__("_ScoreList"), {
          tesuu = player:getTesuu(),
          score = score,
        })
        if player:isSennichite() then
          str:append(SS():raise("OnShogiGameSennichite"))
        else
          if __("_Ponder") then
            shiori:talk("OnShogiGameEnginePonder")
          end
          str:append(SS():raise("OnShogiGameTurnBegin"))
        end
      end
      return str:tostring()
    end,
  },
  {
    id  = "OnShogiGameEnginePonder",
    content = function(shiori, ref)
      local __        = shiori.var
      local process   = shiori:saori("process")
      local player  = KifuPlayer.getInstance()
      local _, init, moves  = player:toUSI()
      -- ponderを送る時点で既に#moves > 0が保証されている
      table.insert(moves, __("_Ponder"))
      if init[1] == "startpos" then
        process("send", __("_EnginePID"), USI.tostring({
          command   = USI.Command.POSITION,
          startpos  = true,
          moves     = moves,
        }))
      else
        process("send", __("_EnginePID"), USI.tostring({
          command   = USI.Command.POSITION,
          sfen      = init,
          moves     = moves,
        }))
      end
      local time  = (player:getTesuu() + 1) * 1000
      process("send", __("_EnginePID"), USI.tostring({
        command   = USI.Command.GO,
        ponder    = true,
        btime = time,
        wtime = time,
      }))
    end,
  },
  {
    id  = "OnShogiEngineGameOver",
    content = function(shiori, ref)
      local __        = shiori.var
      __("_PostGame", true)
      local seiza_count = __("_SeizaCount")
      -- 十分以上対局してたら足が痺れる/負けたら痺れる
      if os.time() - seiza_count >= 10 * 60 or ref[0] == "lose" then
        __("_SeizaShibire", os.time())
      end
      local process   = shiori:saori("process")
      process("send", __("_EnginePID"), USI.tostring({
        command   = USI.Command.GAMEOVER,
        result    = ref[0],
      }))
      -- 棋譜解析はここで行う
      return shiori:talk("OnAnalysisGameRecord")
    end,
  },
  {
    id  = "OnShogiEngineChildProcess",
    content = function(shiori, ref)
      local __        = shiori.var
      local str = StringBuffer()
      local line  = assert(ref[0])
      local callback  = __("_Callback")
      local data  = USI.parse(line)
      if data.command == USI.Command.NONE then
        -- TODO warning
      end
      if data.command == USI.Command.ERROR then
        -- TODO error
        print(data.reason)
      else
        local ret, s  = callback(data)
        if ret then
          str:append(destroyTimer(shiori))
          __("_Callback", function()end)
          --print("success")
        end
        if s then
          str:append(s)
        end
      end
      return str
    end,
  },
}
