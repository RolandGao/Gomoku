import java.util.*; 

//HashMap<Long, Integer> transposition = new HashMap<Long, Integer>(1024);
HashMap<Long, TTNode> tt = new HashMap<Long, TTNode>(8192*64);
int hashCount = 0;
final boolean doHash = true;
final boolean testMode = false;
Game game;

// 3 levels of threat: savable 3 _BBB_ savable 4 WBBBB_  unsavable 4 _BBBB_
// possible moves might not work

// skip (7, 9), corner (8,8), side, (7,8)

// 7 steps
// 102 ms for skip
// 118 ms for corner
// 129 ms for side

// 9 steps
// 1001 ms for skip
// 651 ms for corner
// 749 ms for side

// 10 steps
// 2042ms for side

// four optimization and extension
// diagnol 2
// first step choices=
// think for white / negamax

void setup() {
  size(540, 540);
  game = new Game(9, 2);
}

void draw() {
  game.update();
}

void mouseClicked() {
  int x = (mouseX-4)/36;
  int y = (mouseY-4)/36;
  if (game.isValid())
    game.update(x, y);
}

class Location {
  private int x, y, score;
  Location() {
    x = 1;
    y = 1;
    score = 0;
  }
  Location (int x, int y, int score) {
    this.x = x;
    this.y = y;
    this.score = score;
  }
  int getX() {
    return x;
  }
  int getY() {
    return y;
  }
  int getScore() {
    return score;
  }
  void setScore(int x) {
    score = x;
  }
}
enum Flag {
  EXACT, UPPERBOUND, LOWERBOUND;
}

class TTNode {
  int value, depth;
  Flag flag;
  TTNode(int value, int depth, Flag flag) {
    this.value = value;
    this.depth = depth;
    this.flag = flag;
  }
}

void keyPressed() {
  if (key == 'g' || key == 'G')
    game.undo();
}

Location negamaxRoot(Board board, int depth, int alpha, int beta, int side) {
  //int c = side == 1 ? 1 : -1;
  println("size: " + tt.size());
  println("count: " + hashCount);
  tt.clear();
  hashCount = 0;
  int side2 = side == 1 ? 2 : 1;
  ArrayList<Location> moves = board.findMoves(side, true);
  if (moves.size() == 1)
    return moves.get(0);
  //int before = board.getState();
  //long k = board.getKey();

  Location bestLocation = new Location(1, 1, -1000000);
  for (Location lo : moves) {
    board.update(lo.getX(), lo.getY(), side, lo.getScore());
    //board.updateState(lo.getX(), lo.getY(), side);
    int value;
    if (lo.getScore() > 100 && lo.getScore() < 800)
      value = -negamax(board, depth+1, -beta, -alpha, side2);
    else
      value = -negamax(board, depth-1, -beta, -alpha, side2);
    //value = -negamax(board, depth-1, -beta, -alpha, side2);
    board.undo();
    //board.setState(before, k);
    //board.put(lo.getX(), lo.getY(), 0);
    if (value > bestLocation.getScore()) {
      bestLocation = lo;
      bestLocation.setScore(value);
    }
    alpha = max(alpha, value);
    if (alpha >= beta)
      break;
    if (value > 2000)
      break;
  }
  return bestLocation;
}
boolean contains(int [] arr, int k) {
  for (int a : arr) {
    if (a == k)
      return true;
  }
  return false;
}
int negamax(Board board, int depth, int alpha, int beta, int side) { // beta upperbound; alpha lowerbound
  int alphaOrig = alpha;
  int[] levels = {4, 5, 6, 7, 8};
  if (game.getDifficulty() == 7)
    levels = new int[]{3, 4};
  int steps = game.getDifficulty() - depth;
  if (doHash && contains(levels, steps)) {
    TTNode node = tt.get(board.getKey());
    if (node != null && node.depth >= depth) {
      hashCount++;
      if (node.flag == Flag.EXACT)
        return node.value;
      else if (node.flag == Flag.LOWERBOUND)
        alpha = max(alpha, node.value);
      else if (node.flag == Flag.UPPERBOUND)
        beta = min(beta, node.value);
      if (alpha >= beta)
        return node.value;
    }
  }

  int c = side == 1 ? 1 : -1;
  int side2 = side == 1 ? 2 : 1;
  if (depth == 0 || board.isGameOver())
    return c*board.getState();
  int bestMove = -1000000;
  ArrayList<Location> moves = board.findMoves(side, false);
  //int before = board.getState();
  //long k = board.getKey();
  for (Location lo : moves) {
    board.update(lo.getX(), lo.getY(), side, lo.getScore());
    if (lo.getScore() > 100 && lo.getScore() < 800)
      bestMove = max(bestMove, -negamax(board, depth+1, -beta, -alpha, side2));
    else
      bestMove = max(bestMove, -negamax(board, depth-1, -beta, -alpha, side2));
    //bestMove = max(bestMove, -negamax(board, depth-1, -beta, -alpha, side2));
    alpha = max(bestMove, alpha);
    board.undo();
    //board.setState(before, k);
    //board.put(lo.getX(), lo.getY(), 0);
    if (alpha >= beta)
      break;
    if (bestMove > 2000)
      break;
  }
  if (doHash && contains(levels, steps)) {
    long bk = board.getKey();
    Flag flag;
    if (bestMove <= alphaOrig)
      flag = Flag.UPPERBOUND;
    else if (bestMove >= beta)
      flag = Flag.LOWERBOUND;
    else
      flag = Flag.EXACT;
    TTNode node = new TTNode(bestMove, depth, flag);
    tt.put(bk, node);
  }
  return bestMove;
}
/*
Location minimaxRoot (Board board, int depth, int alpha, int beta, int side) {
 println("size: " + transposition.size());
 println("count: " + hashCount);
 transposition.clear();
 hashCount = 0;
 ArrayList<Location> sortMoves = board.findMoves(side, true);
 if (sortMoves.size() == 1)
 return sortMoves.get(0);
 int before = board.getState();
 long k = board.getKey();
 
 if (side == 1) {
 Location bestLocation = new Location(1, 1, -1000000);
 for (Location lo : sortMoves) {
 board.updateState(lo.getX(), lo.getY(), 1);
 int value;
 if (lo.getScore() > 100 && lo.getScore() < 800)
 value = alphabeta(board, depth+1, alpha, beta, 2);
 else
 value = alphabeta(board, depth-1, alpha, beta, 2);
 board.setState(before, k);
 board.put(lo.getX(), lo.getY(), 0);
 if (value > bestLocation.getScore()) {
 bestLocation = lo;
 bestLocation.setScore(value);
 }
 alpha = max(alpha, value);
 if (alpha >= beta)
 break;
 if (value > 2000)
 break;
 }
 return bestLocation;
 } else {
 Location bestLocation = new Location(1, 1, 1000000);
 for (Location lo : sortMoves) {
 board.updateState(lo.getX(), lo.getY(), 2);
 int value;
 if (lo.getScore() > 100 && lo.getScore() < 800)
 value = alphabeta(board, depth+1, alpha, beta, 1);
 else
 value = alphabeta(board, depth-1, alpha, beta, 1);
 board.setState(before, k);
 board.put(lo.getX(), lo.getY(), 0);
 if (value < bestLocation.getScore()) {
 bestLocation = lo;
 bestLocation.setScore(value);
 }
 beta = min(beta, value);
 if (alpha >= beta)
 break;
 if (value < -2000)
 break;
 }
 return bestLocation;
 }
 }*/
/*
int alphabeta(Board board, int depth, int alpha, int beta, int side) {
 int[] levels = {20, 4};
 int difficulty = game.getDifficulty();
 if (doHash && (difficulty-depth == levels[0] || difficulty-depth == levels[1])) {
 long bk = board.getKey();
 if (transposition.containsKey(bk)) {
 hashCount++;
 return transposition.get(bk);
 }
 }
 if (depth == 0 || board.isGameOver())
 return board.getState();
 ArrayList<Location> bestMoves = board.findMoves(side, false);
 //if (bestMoves.size() == 1)
 //return (side == 1) ? bestMoves.get(0).getScore() : -bestMoves.get(0).getScore();
 int before = board.getState();
 long k = board.getKey();
 int bestMove;
 if (side == 1) {
 bestMove = -100000;
 for (Location lo : bestMoves) {
 board.updateState(lo.getX(), lo.getY(), 1); // hmm
 if (lo.getScore() > 100 && lo.getScore() < 800)
 bestMove = max(bestMove, alphabeta(board, depth+1, alpha, beta, 2));
 else
 bestMove = max(bestMove, alphabeta(board, depth-1, alpha, beta, 2));
 board.setState(before, k);
 board.put(lo.getX(), lo.getY(), 0);
 alpha = max(alpha, bestMove);
 if (alpha >= beta)
 return bestMove;
 if (bestMove > 2000)
 break;
 }
 } else {
 bestMove = 100000;
 for (Location lo : bestMoves) {
 board.updateState(lo.getX(), lo.getY(), 2);
 if (lo.getScore() > 100 && lo.getScore() < 800)
 bestMove = min(bestMove, alphabeta(board, depth+1, alpha, beta, 1));
 else
 bestMove = min(bestMove, alphabeta(board, depth-1, alpha, beta, 1));
 board.setState(before, k);
 board.put(lo.getX(), lo.getY(), 0);
 beta = min(beta, bestMove);
 if (alpha >= beta)
 return bestMove;
 if (bestMove < -2000)
 break;
 }
 }
 if (doHash && (difficulty-depth == levels[0] || difficulty-depth == levels[1])) {
 long bk = board.getKey();
 transposition.put(bk, bestMove);
 }
 return bestMove;
 }*/
