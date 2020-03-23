class Player {
  boolean isHuman;
  int side; // 1 is black, 2 is white
  int difficulty;
  
  Player(){
    isHuman = true;
    side = 1;
    difficulty = 1;
  }
  Player (boolean isHuman, int side){
    this.isHuman = isHuman;
    this.side = side;
    difficulty = 0;
  }
  Player (boolean isHuman, int side, int difficulty){
    this.isHuman = isHuman;
    this.side = side;
    this.difficulty = difficulty;
  }
  Location find(Board board){
    Location lo = negamaxRoot(board, difficulty, -1000000, 1000000, side);
    //Location lo = minimaxRoot(board, difficulty, -1000000, 1000000, side);
    return lo;
  }
  boolean getIsHuman(){return isHuman;}
}
