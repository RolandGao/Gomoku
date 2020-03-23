class Game {
  private int turn, humanTurn, difficulty;
  private boolean isGaming;
  private Player p1, p2;
  private Board board;
  private int ms1, ms2, numMoves, totalTime;
  private boolean isFirstStep;
  private ArrayList<Location> steps = new ArrayList<Location>();

  Game(int difficulty, int humanTurn) {
    turn = 1;
    this.humanTurn = humanTurn;
    this.difficulty = difficulty;
    isGaming = true;
    numMoves = 0;
    totalTime = 0;
    board = new Board();
    isFirstStep = true;
    initPlayers(); // make sure difficulty and humanTurn are initialized first
    if (p1.getIsHuman() == false) {
      update(7, 7);
      if (p2.getIsHuman() == false)
        update(8, 8);
    }
  }
  boolean isGaming() {
    return isGaming;
  }
  int getDifficulty() {
    return difficulty;
  }

  void update() {
    if (isGaming == false)
      return;
    else if (turn == 1 && p1.getIsHuman() == false) {
      if (testMode || p2.getIsHuman()|| p2.getIsHuman() == false && frameCount % 60 == 0) {
        ms1 = millis();
        Location lo = p1.find(board);
        ms2 = millis();
        numMoves++;
        totalTime += ms2-ms1;
        update(lo.getX(), lo.getY());
      }
    } else if (turn == 2 && p2.getIsHuman() == false) {
      if (testMode || p1.getIsHuman() || p1.getIsHuman() == false && frameCount % 60 == 0) {
        ms1 = millis();
        Location lo = p2.find(board);
        ms2 = millis();
        numMoves++;
        totalTime += ms2-ms1;
        update(lo.getX(), lo.getY());
      }
    }
  }
  boolean isValid() {
    if (isGaming == false)
      return false;
    if (turn == 1 && p1.getIsHuman() == false)
      return false;
    if (turn == 2 && p2.getIsHuman() == false)
      return false;
    return true;
  }
  void update(int x, int y) {
    int side = turn == 1 ? 1 : 2;
    if (board.play(x, y, side)) {
      steps.add(new Location(x, y, 0));
      //println("state: " + board.getState());
      turn = turn == 1 ? 2 : 1;
      if (board.isGameOver()) {
        isGaming = false;
        if (!p1.getIsHuman() || !p2.getIsHuman())
          println("An anverage move needs " + totalTime/numMoves + " miliseconds");
      }
    }
    if (isFirstStep && p1.getIsHuman() && p2.getIsHuman() == false) {
      isFirstStep = false;
      Openbook open = new Openbook(x, y);
      Location lo = open.play();
      update(lo.getX(), lo.getY());
    }
  }
  void undo() {
    if (steps.size() > 1) {
      Location a = steps.remove(steps.size()-1);
      Location b = steps.remove(steps.size()-1);
      //board.updateState(a.getX(), a.getY(), 0);
      //board.updateState(b.getX(), b.getY(), 0);
      board.undo();
      board.undo();
      board.drawBoard();
    }
    isGaming = true;
  }
  private void initPlayers() {
    if (humanTurn == 1) {
      p1 = new Player(true, 1);
      p2 = new Player(false, 2, difficulty);
    } else if (humanTurn == 2) {
      p1 = new Player(false, 1, difficulty);
      p2 = new Player(true, 2);
    } else if (humanTurn == 3) {
      p1 = new Player(false, 1, difficulty);
      p2 = new Player(false, 2, difficulty);
    } else {
      p1 = new Player(true, 1);
      p2 = new Player(true, 2);
    }
  }
}
