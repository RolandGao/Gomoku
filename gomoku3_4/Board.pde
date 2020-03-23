class Context {// the context immediately before playing a piece (x,y)
  int x, y;
  int state;
  long k;
  //private int [][]pointStates = new int[4][7]; // right, down, right-down, left-down
  // only the first n values will be used depending on the position.
  //the original pointstate of x,y
  Context(int x, int y, int state, long k) {
    this.x = x;
    this.y = y;
    this.state = state;
    this.k = k;
  }
}


class Board {
  private PImage boardImage, blackPiece, whitePiece;
  private int [][] board = new int[15][15];
  private int state;
  private long [][][]hash = new long[15][15][2]; // row column color
  private long k;
  private int [][][]pointStates = new int[15][15][4];
  private int [][] near = new int[15][15];
  private Stack<Context> history = new Stack<Context>();
  Board() {
    boardImage = loadImage("chessboard.jpg");
    blackPiece = loadImage("piece_black.png");
    whitePiece = loadImage("piece_white.png");
    background(boardImage);
    state = 0;
    k = 0;
    initHash();
  }
  void initHash() {
    for (int i = 0; i < 15; i++) {
      for (int j = 0; j < 15; j++) {
        hash[i][j][0] = (long)(Math.random() * Long.MAX_VALUE);
        hash[i][j][1] = (long)(Math.random() * Long.MAX_VALUE);
      }
    }
  }
  void updateNear(int x, int y, int c) {
    for (int i = max(0, x-2); i <= min(14, x+2); i++) {
      for (int j = max(0, y-2); j <= min(14, y+2); j++) {
        if (abs(x-i)+abs(y-j) <= 2) {
          near[i][j] += c;
        }
      }
    }
  }
  void initPointStates() {
    for (int i = 0; i < 15; i++) {
      for (int j = 0; j < 15; j++) {
        if (board[i][j] == 1) {
          pointStates[i][j][0] = score(i, j, i+4, j, 1, 2);
          pointStates[i][j][1] = score(i, j, i, j+4, 1, 2);
          pointStates[i][j][2] = score(i, j, i+4, j+4, 1, 2);
          pointStates[i][j][3] = score(i, j, i-4, j+4, 1, 2);
        } else if (board[i][j] == 2) {
          pointStates[i][j][0] = -score(i, j, i+4, j, 2, 1);
          pointStates[i][j][1] = -score(i, j, i, j+4, 2, 1);
          pointStates[i][j][2] = -score(i, j, i+4, j+4, 2, 1);
          pointStates[i][j][3] = -score(i, j, i-4, j+4, 2, 1);
        } else {
          pointStates[i][j][0] = 0;
          pointStates[i][j][1] = 0;
          pointStates[i][j][2] = 0;
          pointStates[i][j][3] = 0;
        }
      }
    }
  }
  /*
  void recover(Context c) {
   int x = c.x, y = c.y;
   board[x][y] = 0;
   this.state = c.state;
   this.k = c.k;
   
   int left = max(0, x-4);
   int right = min(14, x+2);
   for (int i = left; i <= right; i++) {
   pointStates[i][y][0] = c.pointStates[0][i-left];
   }
   int top = max(0, y-4);
   int bottom = min(14, y+2);
   for (int j = top; j <= bottom; j++) {
   pointStates[x][j][1] = c.pointStates[1][j-top];
   }
   int dif1 = min(4, x, y);
   int dif2 = min(2, 14-x, 14-y);
   for (int i = x-dif1, j = y-dif1; i <= x+dif2; i++, j++) {
   pointStates[i][j][2] = c.pointStates[2][j-(y-dif1)];
   }
   dif1 = min(4, 14-x, y);
   dif2 = min(2, x, 14-y);
   for (int i = x+dif1, j = y-dif1; i >= x-dif2; i--, j++) {
   pointStates[i][j][3] = c.pointStates[3][j-(y-dif1)];
   }
   }*/
  void update(int x, int y, int u) {//for human input
  assert u != 0 : 
    "u shouldn't be 0";
    Context c = new Context(x, y, state, k);
    history.push(c);

    updateHash(x, y, u);
    updateNear(x, y, 1);
    int before = calcPointState(x, y);
    board[x][y] = u;
    int after = calcPointState(x, y);
    state = state + after-before;
  }
  void update(int x, int y, int u, int after) {
  assert u != 0 : 
    "u shouldn't be 0";
    Context c = new Context(x, y, state, k);
    history.push(c);

    updateHash(x, y, u);
    updateNear(x, y, 1);
    board[x][y] = u;
    state = after;
  }

  void undo() {
    assert !history.empty() : 
    "history is empty";
    Context c = (Context) history.pop();
    int x = c.x; 
    int y = c.y;
    updateHash(x, y, 0);
    updateNear(x,y,-1);
    board[x][y] = 0;
    state = c.state;
    k = c.k;
  }
  int getState() {
    return state;
  }
  long getKey() {
    return k;
  }
  void setState(int state, long k) {
    this.state = state;
    this.k = k;
  }
  void updateHash(int x, int y, int u) {// have to call this first
    if (u >= 1) {
      xor(hash[x][y][u-1]);
    } else if (u == 0) {
      xor(hash[x][y][board[x][y]-1]);
    }
  }
  void xor(long k) {
    this.k = this.k ^ k;
  }
  /*
  void updateState(int x, int y, int u) {
   updateHash(x,y,u);
   int before = findPointState(x, y);
   board[x][y] = u;
   int after = calcPointState(x, y);
   state = state + after-before;
   }*/
  int tryState(int x, int y, int u) {
    int before = findPointState(x, y);
    board[x][y] = u;
    int after = calcPointState(x, y);
    board[x][y] = 0;
    return state+after-before;
  }
  private int rightTrav(int x, int y, boolean isNew) {
    int left = max(0, x-4);
    int right = min(14, x+2);
    int value = 0;
    for (int i = left; i <= right; i++) {
      if (isNew) {
        if (board[i][y] == 1)
          value += score(i, y, i+4, y, 1, 2);
        else if (board[i][y] == 2)
          value -= score(i, y, i+4, y, 2, 1);
      } else {
        value += pointStates[i][y][0];
      }
    }
    return value;
  }
  private int downTrav(int x, int y, boolean isNew) {
    int top = max(0, y-4);
    int bottom = min(14, y+2);
    int value = 0;
    for (int j = top; j <= bottom; j++) {
      if (isNew) {
        if (board[x][j] == 1)
          value += score(x, j, x, j+4, 1, 2);
        else if (board[x][j] == 2)
          value -= score(x, j, x, j+4, 2, 1);
      } else {
        value += pointStates[x][j][1];
      }
    }
    return value;
  }
  private int diag1Trav(int x, int y, boolean isNew) {
    int dif1 = min(4, x, y);
    int dif2 = min(2, 14-x, 14-y);
    int value = 0;
    for (int i = x-dif1, j = y-dif1; i <= x+dif2; i++, j++) {
      if (isNew) {
        if (board[i][j] == 1)
          value += score(i, j, i+4, j+4, 1, 2);
        else if (board[i][j] == 2)
          value -= score(i, j, i+4, j+4, 2, 1);
      } else {
        value += pointStates[i][j][2];
      }
    }
    return value;
  }
  private int diag2Trav(int x, int y, boolean isNew) {
    int dif1 = min(4, 14-x, y);
    int dif2 = min(2, x, 14-y);
    int value = 0;
    for (int i = x+dif1, j = y-dif1; i >= x-dif2; i--, j++) {
      if (isNew) {
        if (board[i][j] == 1)
          value += score(i, j, i-4, j+4, 1, 2);
        else if (board[i][j] == 2)
          value -= score(i, j, i-4, j+4, 2, 1);
      } else {
        value += pointStates[i][j][3];
      }
    }
    return value;
  }

  private int calcPointState(int x, int y) {
    int value = 0;
    value += rightTrav(x, y, true);
    value += downTrav(x, y, true);
    value += diag1Trav(x, y, true);
    value += diag2Trav(x, y, true);
    return value;
  }
  private int findPointState(int x, int y) {
    boolean b = false;// gonna change
    int value = 0;
    value += rightTrav(x, y, b);
    value += downTrav(x, y, b);
    value += diag1Trav(x, y, b);
    value += diag2Trav(x, y, b);
    return value;
  }


  boolean play(int x, int y, int u) {
    if (board[x][y] == 0) {
      update(x, y, u);
      drawPiece(board[x][y], x, y);
      return true;
    }
    return false;
  }
  void put (int x, int y, int u) {
    board[x][y] = u;
  }
  boolean isFull() {
    for (int [] a : board) {
      for (int b : a) {
        if (b == 0)
          return false;
      }
    }
    return true;
  }
  boolean isGameOver() {
    if (abs(state) > 2000 || isFull() == true) {
      return true;
    }
    return false;
  }
  void drawBoard() {
    background(boardImage);
    for (int i = 0; i < 15; i++) {
      for (int j = 0; j < 15; j++) {
        if (board[i][j] != 0)
          drawPiece(board[i][j], i, j);
      }
    }
  }
  private void drawPiece(int m, int x, int y) {
    if (m == 1)
      image(blackPiece, 22+x*36-18, 22+y*36-17);
    else
      image(whitePiece, 22+x*36-18, 22+y*36-17);
  }

  ArrayList<Location> findMoves(int side, boolean included) {
    ArrayList<Location> moves = possibleMoves(side); // hmm
    Collections.sort(moves, new Comparator<Location>() {
      public int compare(Location a, Location b) {
        return abs(b.getScore()-state) - abs(a.getScore()-state);
      }
    }
    );

    if (moves.size() <= 15)
      return moves;
    ArrayList<Location> bestMoves = new ArrayList<Location>(15);
    for (int i = 0; i < 15; i++)
      bestMoves.add(moves.get(i));
    return bestMoves;
  }
  /*
  ArrayList<Location> findMoves2(int side, boolean included) {
   ArrayList<Location> possibleMoves = possibleMoves2(side, included);
   ArrayList<Location> bestMoves = new ArrayList<Location>(15);
   for (int n = 0; n < 15; n++) { // || possibleMoves.size() == 0
   Location bestLocation = new Location(0, 0, -1);
   for (Location lo : possibleMoves) {
   if (bestLocation.getScore() <= lo.getScore()) {
   bestLocation = lo;
   }
   }
   bestMoves.add(bestLocation);
   if (bestLocation.getScore() > 2000)
   break;
   possibleMoves.remove(bestLocation);
   }
   return bestMoves;
   }*/
  ArrayList<Location> possibleMoves(int side) {
    initPointStates();
    ArrayList<Location> possibleMoves = new ArrayList<Location>();
    for (int i = 0; i < 15; i++) {
      for (int j = 0; j < 15; j++) {
        if (isNear(i, j)) {
          int after = tryState(i, j, side);
          int value = abs(after-state);
          possibleMoves.add(new Location(i, j, after));
          if (value > 2000)
            return possibleMoves;
        }
      }
    }
    return possibleMoves;
  }
  /*
  ArrayList<Location> possibleMoves2(int side, boolean included) {
   ArrayList<Location> moves = new ArrayList<Location>(15);
   ArrayList<Location> five = new ArrayList<Location>();
   ArrayList<Location> five2 = new ArrayList<Location>();
   ArrayList<Location> Lfour = new ArrayList<Location>();
   ArrayList<Location> Lfour2 = new ArrayList<Location>();
   ArrayList<Location> four = new ArrayList<Location>();
   int side2 = side == 1 ? 2 : 1;
   for (int i = 0; i < 15; i++) {
   for (int j = 0; j < 15; j++) {
   if (isNear(i, j)) {
   int value1 = abs(tryState(i, j, side)-state);
   int value2 = abs(tryState(i, j, side2)-state);
   //int value2 = 0;
   if (value1 > 2000) {
   five.add(new Location(i, j, value1));
   return five;
   } else if (value2 > 2000)
   five2.add(new Location(i, j, value2));
   else if (value1 > 800)
   Lfour.add(new Location(i, j, value1));
   else if (value2 > 800)
   Lfour2.add(new Location(i, j, value2));
   else if (value1 > 100)
   four.add(new Location(i, j, value1));
   if (value1 > 0 || included)
   moves.add(new Location(i, j, value1));
   }
   }
   }
   if (five2.size() != 0)
   return five2;
   if (Lfour.size() != 0)
   return Lfour;
   if (Lfour2.size() != 0) {
   Lfour2.addAll(four);
   return Lfour2;
   }
   return moves;
   }*/
  /*
  private boolean isNear(int x, int y) {
   if (board[x][y] != 0)
   return false;
   
   for (int i = max(0, x-2); i <= min(14, x+2); i++) {
   for (int j = max(0, y-2); j <= min(14, y+2); j++) {
   if (abs(x-i)+abs(y-j) <= 2) { // || abs(x-i) == 2 && abs(y-j) == 2 
   if (board[i][j] != 0)
   return true;
   }
   }
   }
   return false;
   }*/
  private boolean isNear(int x, int y) {
    if (board[x][y] != 0 || near[x][y] == 0)
      return false;
    return true;
  }

  private int score(int x1, int y1, int x2, int y2, int u, int v) { // 4 might contain v
    if (abs(x2-x1) != 4 && abs(y2-y1) != 4)
      return 0;
    if (y2 > 16 || x2 > 16 || x2 < -2) // hmmmmm
      return 0;
    int d1 = (x2-x1)/4;
    int d2 = (y2-y1)/4;
    int [] arr = new int[7];
    if (x1-d1 < 0|| x1-d1 > 14 || y1-d2 < 0) {
      arr[1] = v;
      arr[0] = v;
    } else {
      arr[1] = board[x1-d1][y1-d2];
      if (arr[1] == u)
        return 0;
      if (x1- 2*d1 < 0|| x1- 2*d1 > 14 || y1- 2*d2 < 0)
        arr[0] = v;
      else
        arr[0] = board[x1- 2*d1][y1- 2*d2];
    }
    for (int i = 0; i < 5; i++) {
      if (x1 + i*d1 >= 15 || x1 + i*d1 <= -1 || y1 + i*d2 >= 15)
        arr[i+2] = v;
      else
        arr[i+2] = board[x1 + i*d1][y1 + i*d2];
      if (arr[i+2] == v && (i+2 <= 4 || arr[1] == v || arr[0] == v && i+2 <= 5))
        return 0;
    }

    return points(arr, u, v);
  }
  private int points (int [] arr, int u, int v) { // length 7 2-4 should not contain v or W(4)W
    if (arr[5] == v) {
      if (arr[0] != u && arr[3] == u && arr[4] == 0) // _BB_W
        return 2;
      if (arr[0] != u && arr[3] == u && arr[4] == u) // _BBBW
        return 3;
      return 0;
    }
    int m = 0;
    for (int i = 2; i < 7; i++) {
      if (arr[i] != u)
        m++;
    }
    if (m == 0) // BBBBB
      return 10000;
    if (m == 1) {
      if (arr[1] == 0 && arr[3] == u && arr[4] == u && arr[5] == u && arr[6] == 0) // _BBBB_
        return 1000;
      //if (arr[3] == 0 && arr[4] == u && arr[5] == u && arr[6] == u) // _B_BBB added in _BBB_ already
      //return 0;
      return 20;
    }
    // 01 23456
    if (arr[1] == v) {
      if (arr[3] == u && arr[4] == 0 && arr[5] == u && arr[6] == 0) // WBB_B_
        return 3;
      if (arr[3] == 0 && arr[4] == u && arr[5] == u && arr[6] == 0) // WB_BB_ calculated in _BB_
        return 3;
      if (arr[3] == u && arr[4] == u && arr[5] == 0) // WBBB_
        return 3;
    }
    if (arr[1] == 0 && arr[0] == u) { //B_B
      if (arr[3] == 0 && arr[4] == u && arr[5] == 0) // B_B_B_
        return 3;
      if (arr[3] == 0 && arr[4] == u && arr[5] == u && arr[6] == 0) // B_B_BB_
        return 20;
      return 0;
    }
    if (arr[1] == 0) { // can be W_B or __B
      if (arr[0] == v && arr[3] == u && arr[4] == u && arr[5] == 0 && arr[6] == v) // W_BBB_W
        return 3;
      if (arr[3] == u && arr[4] == 0 && arr[5] == 0) // _BB__
        return 2;
      if (arr[3] == 0 && arr[4] == u && arr[5] == 0) // _B_B_
        return 2;
      if (arr[3] == u && arr[4] == u && arr[5] == 0) // _BBB_
        return 20;
      if (arr[3] == u && arr[4] == 0 && arr[5] == u && arr[6] == 0) // _BB_B_
        return 20;
      if (arr[3] == 0 && arr[4] == u && arr[5] == u && arr[6] == 0) // _B_BB_
        return 20;
      if (arr[3] == 0 && arr[4] == u && arr[5] == u && arr[6] == v) // _B_BBW
        return 3;
      if (arr[3] == u && arr[4] == 0 && arr[5] == u && arr[6] == v) // _BB_BW
        return 3;
    }
    return 0;
  }
}
