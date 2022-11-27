
return {
  {
    id  = "将棋トーク_",
    content = function(shiori, ref)
      local __  = shiori.var
      local strength  = __["Strength"] or "観る将"
      local strength2genre  = {
        ["無"]  = {
          "C1", "C1", "C2", "C2", "C2", "C2", "C3", "C3", "Com", "G1",
        },
        ["入門"]  = {
          "C2", "C2", "C3", "C3", "C3", "C3", "C4", "C4", "Com", "G1",
        },
        ["初級"]  = {
          "C3", "C3", "C4", "C4", "C4", "C4", "C5", "C5", "Com", "G1",
        },
        ["中級"]  = {
          "C4", "C4", "C5", "C5", "C5", "C5", "C6", "C6", "Com", "G1",
        },
        ["上級"]  = {
          "C5", "C5", "C6", "C6", "C6", "C6", "C7", "C7", "Com", "G1",
        },
        ["有段"]  = {
          "C6", "C6", "C7", "C7", "C7", "C7", "C8", "C8", "Com", "G1",
        },
        ["高段"]  = {
          "C7", "C7", "C8", "C8", "C8", "C8", "C9", "C9", "Com", "G1",
        },
        ["観る将"]  = {
          "Com", "G1",
        },
      }
      local genre_list = assert(strength2genre[strength])
      local genre = assert(genre_list[math.random(#genre_list)])
      return shiori:talk("将棋トーク_" .. genre)
    end,
  },
}
