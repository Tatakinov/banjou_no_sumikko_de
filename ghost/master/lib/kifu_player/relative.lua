local Color = require("kifu_player.color")

local M = {}

M.D = "D"
M.M = "M"
M.U = "U"
M.L = "L"
M.C = "C"
M.R = "R"
M.H = "H"

--  読み上げはsubから処理するためsub-main-hitの順番
local relative_string = {
  -- sub
  {
    D = "引",
    M = "寄",
    U = "上",
  },
  -- main
  {
    L = "左",
    C = "直",
    R = "右",
  },
  -- hit
  {
    H = "打",
  },
}

function M.getRelativeString(relative)
  local ret = ""
  for _, v in ipairs(relative_string) do
    for k, v in pairs(v) do
      if string.find(relative, k) then
        ret = ret .. v
      end
    end
  end
  return ret
end

local relative_list = {
  -- 移動先から見た移動元の位置
  -- 左上 (from: ６四 -> to: ５五)
  TL  = {
    x = 1, y = -1,  -- 盤上での相対座標
    main  = M.D,    -- 相対情報1
    sub   = M.L,    -- 相対情報2
  },
  -- 上 (from: ５四 -> to: ５五)
  T   = {
    x = 0, y = -1,
    main  = M.D,
    sub   = M.C,
  },
  -- 右上 (from: ４四 -> to: ５五)
  TR  = {
    x = -1, y = -1,
    main  = M.D,
    sub   = M.R,
  },
  -- 左 (from: ６五 -> to: ５五)
  L   = {
    x = 1, y = 0,
    main  = M.M,
    sub   = M.L,
  },
  -- 真ん中は特になし
  -- 右 (from: ４五 -> to: ５五)
  R   = {
    x = -1, y = 0,
    main  = M.M,
    sub   = M.R,
  },
  -- 左下 (from: ６六 -> to: ５五)
  BL  = {
    x = 1, y = 1,
    main  = M.U,
    sub   = M.L,
  },
  -- 下 (from: ５六 -> to: ５五)
  B   = {
    x = 0, y = 1,
    main  = M.U,
    sub   = M.C,
  },
  -- 右下 (from: ４六 -> to: ５五)
  BR  = {
    x = -1, y = 1,
    main  = M.U,
    sub   = M.R,
  },
  -- 左下(桂馬) (from: ６七 -> to ５五)
  KL  = {
    x = 1, y = 2,
    main  = M.U,
    sub   = M.L,
  },
  -- 右下(桂馬) (from: ４七 -> to ５五)
  KR  = {
    x = -1, y = 2,
    main  = M.U,
    sub   = M.R,
  },
}

local function createRelative(color, relative, running)
  assert(color and relative)

  if color == Color.BLACK then
    color = 1
  else
    color = -1
  end

  local base = relative_list[relative]

  local ret = {
    x       = base.x * color,
    y       = base.y * color,
    main    = base.main,
    sub     = base.sub,
    running = running,
  }
  return ret
end

for _, color in ipairs({Color.BLACK, Color.WHITE}) do
  relative_list[color] = {
    FU  = {
      B = createRelative(color, "B"),
    },
    KY  = {
      B = createRelative(color, "B", true),
    },
    KE  = {
      KL  = createRelative(color, "KL"),
      KR  = createRelative(color, "KR"),
    },
    GI  = {
      TL  = createRelative(color, "TL"),
      TR  = createRelative(color, "TR"),
      BL  = createRelative(color, "BL"),
      B   = createRelative(color, "B"),
      BR  = createRelative(color, "BR"),
    },
    KI  = {
      T   = createRelative(color, "T"),
      L   = createRelative(color, "L"),
      R   = createRelative(color, "R"),
      BL  = createRelative(color, "BL"),
      B   = createRelative(color, "B"),
      BR  = createRelative(color, "BR"),
    },
    KA  = {
      TL  = createRelative(color, "TL", true),
      TR  = createRelative(color, "TR", true),
      BL  = createRelative(color, "BL", true),
      BR  = createRelative(color, "BR", true),
    },
    UM  = {
      TL  = createRelative(color, "TL", true),
      TR  = createRelative(color, "TR", true),
      BL  = createRelative(color, "BL", true),
      BR  = createRelative(color, "BR", true),
      T   = createRelative(color, "T"),
      L   = createRelative(color, "L"),
      R   = createRelative(color, "R"),
      B   = createRelative(color, "B"),
    },
    HI  = {
      T   = createRelative(color, "T", true),
      L   = createRelative(color, "L", true),
      R   = createRelative(color, "R", true),
      B   = createRelative(color, "B", true),
    },
    RY  = {
      T   = createRelative(color, "T", true),
      L   = createRelative(color, "L", true),
      R   = createRelative(color, "R", true),
      B   = createRelative(color, "B", true),
      TL  = createRelative(color, "TL"),
      TR  = createRelative(color, "TR"),
      BL  = createRelative(color, "BL"),
      BR  = createRelative(color, "BR"),
    },
    OU  = {
      TL  = createRelative(color, "TL"),
      T   = createRelative(color, "T"),
      TR  = createRelative(color, "TR"),
      L   = createRelative(color, "L"),
      R   = createRelative(color, "R"),
      BL  = createRelative(color, "BL"),
      B   = createRelative(color, "B"),
      BR  = createRelative(color, "BR"),
    },
  }
  for _, v in ipairs({"TO", "NY", "NK", "NG"}) do
    relative_list[color][v] = relative_list[color]["KI"]
  end
end

--- colorの駒kindが存在し得る位置のリストを返す
function M.getRelativeList(color, kind)
  return assert(relative_list[color][kind])
end

return M
