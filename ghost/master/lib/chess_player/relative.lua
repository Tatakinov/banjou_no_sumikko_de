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
  -- 下 (from: ５六 -> to: ５五)
  B2  = {
    x = 0, y = 2,
    weak  = true,
    main  = M.U,
    sub   = M.C,
  },
  -- 右下 (from: ４六 -> to: ５五)
  BR  = {
    x = -1, y = 1,
    main  = M.U,
    sub   = M.R,
  },
  -- 下左(桂馬) (from: ６七 -> to ５五)
  KBL  = {
    x = 1, y = 2,
    main  = M.U,
    sub   = M.L,
  },
  -- 下右(桂馬) (from: ４七 -> to ５五)
  KBR  = {
    x = -1, y = 2,
    main  = M.U,
    sub   = M.R,
  },
  -- 左下(桂馬) (from: ７六 -> to ５五)
  KLB  = {
    x = 2, y = 1,
    main  = M.U,
    sub   = M.L,
  },
  -- 左上(桂馬) (from: ７四 -> to ５五)
  KLT  = {
    x = 2, y = -1,
    main  = M.U,
    sub   = M.R,
  },
  -- 上左(桂馬) (from: ６三 -> to ５五)
  KTL  = {
    x = 1, y = -2,
    main  = M.U,
    sub   = M.L,
  },
  -- 上右(桂馬) (from: ４三 -> to ５五)
  KTR  = {
    x = -1, y = -2,
    main  = M.U,
    sub   = M.R,
  },
  -- 右上(桂馬) (from: ３四 -> to ５五)
  KRT  = {
    x = -2, y = -1,
    main  = M.U,
    sub   = M.L,
  },
  -- 右下(桂馬) (from: ３六 -> to ５五)
  KRB  = {
    x = -2, y = 1,
    main  = M.U,
    sub   = M.R,
  },
  R2 = {
    weak  = true,
    x = -2, y = 0,
  },
  L2 = {
    weak  = true,
    x = 2, y  = 0,
  },
}

local function createRelative(color, relative, running)
  assert(color and relative)

  if color == Color.WHITE then
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
    N = {
      KTL  = createRelative(color, "KTL"),
      KTR  = createRelative(color, "KTR"),
      KBL  = createRelative(color, "KBL"),
      KBR  = createRelative(color, "KBR"),
      KRT  = createRelative(color, "KRT"),
      KRB  = createRelative(color, "KRB"),
      KLT  = createRelative(color, "KLT"),
      KLB  = createRelative(color, "KLB"),
    },
    P = {
      BL  = createRelative(color, "BL"),
      B   = createRelative(color, "B"),
      B2  = createRelative(color, "B2"),
      BR  = createRelative(color, "BR"),
    },
    B = {
      TL  = createRelative(color, "TL", true),
      TR  = createRelative(color, "TR", true),
      BL  = createRelative(color, "BL", true),
      BR  = createRelative(color, "BR", true),
    },
    R = {
      T   = createRelative(color, "T", true),
      L   = createRelative(color, "L", true),
      R   = createRelative(color, "R", true),
      B   = createRelative(color, "B", true),
    },
    Q = {
      T   = createRelative(color, "T", true),
      L   = createRelative(color, "L", true),
      R   = createRelative(color, "R", true),
      B   = createRelative(color, "B", true),
      TL  = createRelative(color, "TL", true),
      TR  = createRelative(color, "TR", true),
      BL  = createRelative(color, "BL", true),
      BR  = createRelative(color, "BR", true),
    },
    K = {
      TL  = createRelative(color, "TL"),
      T   = createRelative(color, "T"),
      TR  = createRelative(color, "TR"),
      L   = createRelative(color, "L"),
      R   = createRelative(color, "R"),
      BL  = createRelative(color, "BL"),
      B   = createRelative(color, "B"),
      BR  = createRelative(color, "BR"),
      R2  = createRelative(color, "R2"),
      L2  = createRelative(color, "L2"),
    },
  }
end

--- colorの駒kindが存在し得る位置のリストを返す
function M.getRelativeList(color, kind)
  return assert(relative_list[color][kind])
end

return M
