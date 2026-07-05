final int OPENING_CORNER = 0;
final int OPENING_SIDE = 1;
final int OPENING_SKIP = 2;

class Openbook {
  int opening;
  int x, y;
  ArrayList<Location> locations;
  Openbook(int opening, int x, int y){
    this.opening = opening;
    this.x = x;
    this.y = y;
    init();
  }
  Openbook(int x, int y){
    this.x = x;
    this.y = y;
    int n = (int) random(3);
    switch (n){
      case 0: opening = OPENING_CORNER; break;
      case 1: opening = OPENING_SIDE; break;
      case 2: opening = OPENING_SKIP; break;
    }
    init();
  }
  Openbook(){
    int n = (int) random(3);
    switch (n){
      case 0: opening = OPENING_CORNER; break;
      case 1: opening = OPENING_SIDE; break;
      case 2: opening = OPENING_SKIP; break;
    }
    x = 7;
    y = 7;
    init();
  }
  void init(){
    locations = new ArrayList<Location>();
    switch(opening){
      case OPENING_CORNER : corner(); break;
      case OPENING_SIDE: side(); break;
      case OPENING_SKIP : skip(); break;
    }
  }
  void corner(){
    locations.add(new Location(x-1,y-1,0));
    locations.add(new Location(x-1,y+1,0));
    locations.add(new Location(x+1,y-1,0));
    locations.add(new Location(x+1,y+1,0));
  }
  void side (){
    locations.add(new Location(x,y+1,0));
    locations.add(new Location(x,y-1,0));
    locations.add(new Location(x+1,y,0));
    locations.add(new Location(x-1,y,0));
  }
  void skip(){
    locations.add(new Location(x,y+2,0));
    locations.add(new Location(x,y-2,0));
    locations.add(new Location(x+2,y,0));
    locations.add(new Location(x-2,y,0));
  }
  Location play(){
    Location bestLocation = new Location();
    if (x == 7 && y == 7){
      bestLocation = locations.get((int) random(4));
    }
    else {
      int value = 100;
      for (Location corner : locations){
        int v = abs(corner.getX()-7) + abs(corner.getY()-7);
        if (v < value){
          value = v;
          bestLocation = corner;
        }
      }
    }
    return bestLocation;
    //board.play(bestLocation.getX(), bestLocation.getY(), 2);
  }
}
