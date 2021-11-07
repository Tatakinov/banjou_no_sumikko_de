
return {
  {
    id  = "OnInitializeGameEngine",
    content = function(shiori, ref)
      local __  = shiori.var
      local list  = __("ChessEngineList") or {
        ["Arasan 23.0.1"]={
          ["option"]={
            ["Randomize book moves"]={
              ["command"]="option",
              ["max"]=100,
              ["type"]="spin",
              ["min"]=0,
              ["name"]="Randomize book moves",
              ["default"]=50,
            },
            ["SyzygyTbPath"]={
              ["type"]="string",
              ["command"]="option",
              ["name"]="SyzygyTbPath",
              ["default"]="syzygy",
            },
            ["Use NNUE"]={
              ["type"]="check",
              ["command"]="option",
              ["name"]="Use NNUE",
              ["default"]=true,
            },
            ["Threads"]={
              ["command"]="option",
              ["max"]=256,
              ["type"]="spin",
              ["min"]=1,
              ["name"]="Threads",
              ["default"]=1,
            },
            ["NNUE file"]={
              ["type"]="string",
              ["command"]="option",
              ["name"]="NNUE file",
              ["value"]=__("_path") .. "engine\\arasan\\arasan-d8-9-20210827.nnue"
            },
            ["Favor high-weighted book moves"]={
              ["command"]="option",
              ["max"]=100,
              ["type"]="spin",
              ["min"]=0,
              ["name"]="Favor high-weighted book moves",
              ["default"]=100,
            },
            ["OwnBook"]={
              ["type"]="check",
              ["command"]="option",
              ["name"]="OwnBook",
              ["default"]=true,
            },
            ["UCI_LimitStrength"]={
              ["type"]="check",
              ["command"]="option",
              ["name"]="UCI_LimitStrength",
              ["default"]=false,
              ["value"]=true,
            },
            ["Contempt"]={
              ["command"]="option",
              ["max"]=200,
              ["type"]="spin",
              ["min"]=-200,
              ["name"]="Contempt",
              ["default"]=0,
            },
            ["Favor best book moves"]={
              ["command"]="option",
              ["max"]=100,
              ["type"]="spin",
              ["min"]=0,
              ["name"]="Favor best book moves",
              ["default"]=50,
            },
            ["Move overhead"]={
              ["command"]="option",
              ["max"]=1000,
              ["type"]="spin",
              ["min"]=0,
              ["name"]="Move overhead",
              ["default"]=30,
            },
            ["SyzygyUse50MoveRule"]={
              ["type"]="check",
              ["command"]="option",
              ["name"]="SyzygyUse50MoveRule",
              ["default"]=true,
            },
            ["Use tablebases"]={
              ["type"]="check",
              ["command"]="option",
              ["name"]="Use tablebases",
              ["default"]=false,
            },
            ["SyzygyProbeDepth"]={
              ["command"]="option",
              ["max"]=64,
              ["type"]="spin",
              ["min"]=0,
              ["name"]="SyzygyProbeDepth",
              ["default"]=4,
            },
            ["Favor frequent book moves"]={
              ["command"]="option",
              ["max"]=100,
              ["type"]="spin",
              ["min"]=0,
              ["name"]="Favor frequent book moves",
              ["default"]=50,
            },
            ["Ponder"]={
              ["type"]="check",
              ["command"]="option",
              ["name"]="Ponder",
              ["default"]=true,
            },
            ["Hash"]={
              ["command"]="option",
              ["max"]=2000,
              ["type"]="spin",
              ["min"]=4,
              ["name"]="Hash",
              ["default"]=32,
            },
            ["UCI_Elo"]={
              ["command"]="option",
              ["max"]=2600,
              ["type"]="spin",
              ["min"]=1000,
              ["name"]="UCI_Elo",
              ["default"]=2600,
              ["value"]=1000,
            },
            ["MultiPV"]={
              ["command"]="option",
              ["max"]=10,
              ["type"]="spin",
              ["min"]=1,
              ["name"]="MultiPV",
              ["default"]=1,
            },
          },
          ["command"]=__("_path") .. "engine\\arasan\\arasanx-32.exe",
          ["name"]="Arasan 23.0.1",
          ["author"]="Jon Dart",
        },
      }
      __("ChessEngineList", list)
      local name  = __("SelectedChessEngine") or "Arasan 23.0.1"
      __("SelectedChessEngine", name)

      local shogi686_path = __("_path") .. "engine\\shogi686\\shogi686.exe"
      local sunfish4_path = __("_path") .. "engine\\sunfish4\\sunfish_usi.exe"
      local engine_list = {
        ["ほどほど"]={
          ["option"]={
            ["TimeMargin"]={
              ["default"]=100,
              ["max"]=3000,
              ["name"]="TimeMargin",
              ["min"]=0,
              ["command"]="option",
              ["type"]="spin",
            },
            ["Eval"]={
              ["default"]="Default",
              ["name"]="Eval",
              ["var"]={
                [1]="Default",
                [2]="Random(NoSearch)",
              },
              ["command"]="option",
              ["type"]="combo",
            },
            ["Mate"]={
              ["default"]="Default",
              ["name"]="Mate",
              ["var"]={
                [1]="Default",
                [2]="Learn",
                [3]="Average",
              },
              ["command"]="option",
              ["type"]="combo",
            },
            ["Ordering"]={
              ["default"]="Default",
              ["name"]="Ordering",
              ["var"]={
                [1]="Default",
                [2]="Random",
              },
              ["command"]="option",
              ["type"]="combo",
            },
            ["SaveTime"]={
              ["name"]="SaveTime",
              ["default"]=true,
              ["command"]="option",
              ["type"]="check",
            },
            ["RandomMove"]={
              ["command"]="option",
              ["type"]="check",
              ["name"]="RandomMove",
              ["default"]=false,
            },
          },
          ["author"]="merom686",
          ["command"]=shogi686_path,
          ["name"]="ほどほど",
        },
        ["つよい"]={
          ["author"]="Kubo Ryosuke",
          ["command"]=sunfish4_path,
          ["option"]={
            ["UseBook"]={
              ["type"]="check",
              ["command"]="option",
              ["default"]=true,
              ["name"]="UseBook",
            },
            ["Snappy"]={
              ["type"]="check",
              ["command"]="option",
              ["default"]=true,
              ["name"]="Snappy",
            },
            ["MultiPV"]={
              ["default"]=1,
              ["name"]="MultiPV",
              ["max"]=10,
              ["command"]="option",
              ["min"]=1,
              ["type"]="spin",
            },
            ["MarginMs"]={
              ["default"]=500,
              ["name"]="MarginMs",
              ["max"]=2000,
              ["command"]="option",
              ["min"]=0,
              ["type"]="spin",
            },
            ["Threads"]={
              ["default"]=1,
              ["name"]="Threads",
              ["max"]=32,
              ["command"]="option",
              ["min"]=1,
              ["type"]="spin",
            },
            ["MaxDepth"]={
              ["default"]=64,
              ["name"]="MaxDepth",
              ["max"]=64,
              ["command"]="option",
              ["min"]=1,
              ["type"]="spin",
            },
          },
          ["name"]="つよい",
        },
      }
      __("EngineList", engine_list)
      __("SelectedEngine", "ほどほど")
      local score_list  = {
        ["ほどほど"]  = {
          win   = 0,
          lose  = 0,
        },
        ["つよい"]  = {
          win   = 0,
          lose  = 0,
        },
      }
      __("成績", score_list)
      local filename  = __("_path") .. [[engine\version]]
      --print("filename: " .. filename)
      local fh  = io.open(filename, "r")
      if fh then
        __("Supplement_Engine_Version", fh:read("*l"))
        fh:close()
      end
    end,
  },
}
