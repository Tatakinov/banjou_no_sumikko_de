local Config  = {
  SAORI = {
    process = [[saori\process\process.dll]],
    backgammon  = [[saori\kay\kay.dll]],
    mahjong = [[saori\MahjongUtil\MahjongUtilCustom.dll]],
    othello = [[saori\cocoa\cocoa.dll]],
    quoridor  = [[saori\charlotte\charlotte.dll]],
    gomoku  = [[saori\sharo\sharo.dll]],
    connect6  = [[saori\mio\mio.dll]],
    TexasHoldem = [[saori\TexasHoldemUtil\TexasHoldemUtil.dll]],
    mancala = [[saori\yui\yui.dll]],
  },
  Replace = {
    {
      before  = [[、]],
      after   = [[、\w9]],
    },
    {
      before  = [[、@]],
      after   = [[、]],
    },
    {
      before  = [[。]],
      after   = [[。\w9\w9]],
    },
    {
      before  = [[。@]],
      after   = [[。]],
    },
    {
      before  = [[…]],
      after   = [[…\w9]],
    },
    {
      before  = [[…@]],
      after   = [[…]],
    },
    {
      before  = [[？@]],
      after   = [[？\w9\w9]],
    },
    {
      before  = [[！@]],
      after   = [[！\w9\w9]],
    },
    {
      before  = [[ｰ]],
      after   = [[ｰ\w9]],
    },
    {
      before  = [[ｰ@]],
      after   = [[ｰ]],
    },
  },
  External  = {
    [[OnMahjong]],
  },
}

return Config
