final int COLOUR_1 = 255;
final int COLOUR_2 = 0;

Grid grid;
boolean alive = false;
int tickSpeed = 1000;

public void setup() {
  size(500,500);
  background(COLOUR_2);
  stroke(COLOUR_1);
  grid = new Grid(width,height,50,50); // offset lines gridsize (0,0,50,50,2,2)
}

public void draw() {
  if (alive) {
    grid.updateGrid();
  }
  delay(tickSpeed);
}

static class Point {
  int x, y;
   
  public Point(int x, int y) {
    this.x = x;
    this.y = y;
  }
  
  public Point(float x, float y) {
    this.x = (int)x;
    this.y = (int)y;
  }
  
  @Override
  public String toString() {
    return "("+x+","+y+")";
  }
}

class GridBox {
  Point p1,p2;
  boolean filled;
  
  public GridBox(Point p1, Point p2) {
    this.p1 = p1;
    this.p2 = p2;
    this.filled = false;
  }
  
  public boolean compare(Point p3) {
    if (p1.x < p3.x && p2.x > p3.x && p1.y < p3.y && p2.y > p3.y) return true;
    return false;
  }
  
  public void flip() {
    if (filled) {
      fill(0);
    } else {
      fill(255);
    }
    rect(p1.x,p1.y,p2.x-p1.x,p2.y-p1.y);
    filled = !filled;
  }
  
  @Override
  public String toString() {
    return "("+p1.x+","+p1.y+") ("+p2.x+","+p2.y+")";
  }
}

class Grid {
  ArrayList<GridBox> gridBoxes = new ArrayList<GridBox>();
  int xLines;
  
  public Grid(float x, float y, int xLines, int yLines) {
    this.xLines = xLines;
    final int s = 0;
    float xPos = 0;
    float yPos = 0;
    float xDif = x / xLines;
    float yDif = y / yLines;
    
    for (int i=0;i<xLines;i++) {
      line(xPos,s,xPos,y);
      xPos += xDif;
    }
    for (int i=0;i<yLines;i++) {
      line(s,yPos,x,yPos); 
      yPos += yDif; 
    }
    
    for (int i=0;i<yLines;i++) {
      for (int j=0;j<xLines;j++) {
        gridBoxes.add(new GridBox(new Point(j * x/xLines, i * y/yLines),new Point((j + 1) * x/xLines, (i + 1) * y/yLines)));
      }
    }
  }
  
  public GridBox getGridBox(Point p) {
    for(int i=0;i<gridBoxes.size();i++) {
      if (gridBoxes.get(i).compare(p)) {
        return gridBoxes.get(i);
      }
    }
    return null;
  }
  
  public void fillGridBox(Point p) {
    if (getGridBox(p) != null) getGridBox(p).flip();
  }
  
  public int getFilledNeighbours(int i, ArrayList<GridBox> gridBoxesB) {
    int fn = 0;
    
    int min = 0;
      int max = gridBoxes.size();
      
      int topl = i - xLines-1;
      int top = i - xLines;
      int topr = i - xLines+1;
      int l = i - 1;
      int r = i + 1;
      int botl = i + xLines-1;
      int bot = i + xLines;
      int botr = i + xLines+1;
      
      boolean inBoundsL = gridBoxesB.get(i).p1.x - 2 > 0;
      boolean inBoundsR = gridBoxesB.get(i).p2.x + 2 < width;
      
      if (topl > min && inBoundsL) if (gridBoxesB.get(topl).filled) fn++;
      
      if (top > min) if (gridBoxesB.get(top).filled) fn++;
      
      if (topr > min && inBoundsR) if (gridBoxesB.get(topr).filled) fn++;
      
      if (l > min && inBoundsL) if (gridBoxesB.get(l).filled) fn++;
      
      if (r < max && inBoundsR) if (gridBoxesB.get(r).filled) fn++;
            
      if (botl < max && inBoundsL) if (gridBoxesB.get(botl).filled) fn++;
      
      if (bot < max) if (gridBoxesB.get(bot).filled) fn++;
      
      if (botr < max && inBoundsR) if (gridBoxesB.get(botr).filled) fn++;
    
    return fn;
  }
  
  public void updateGrid() {
    ArrayList<GridBox> gridBoxesB = new ArrayList<GridBox>();//(ArrayList)gridBoxes.clone();
    
    for (int i=0;i<gridBoxes.size();i++) {
      gridBoxesB.add(new GridBox(new Point(gridBoxes.get(i).p1.x,gridBoxes.get(i).p1.y),new Point(gridBoxes.get(i).p2.x,gridBoxes.get(i).p2.y)));
      gridBoxesB.get(i).filled = gridBoxes.get(i).filled;
    }
    
    for(int i=0;i<gridBoxes.size();i++) {
      
      int fn = getFilledNeighbours(i, gridBoxesB);
      
      boolean caseA = gridBoxesB.get(i).filled;
      boolean case2 = fn == 2;
      boolean case3 = fn == 3;
      
      if ((caseA && !(case2 || case3)) || (!caseA && case3)) {
        gridBoxes.get(i).flip();
      }
    }
  }
  
  public void resetBoard() {
    for(int i=0;i<gridBoxes.size();i++) {
      if (gridBoxes.get(i).filled) {
        gridBoxes.get(i).flip();
      }
    }
  }
  
  public void printGrid() {
    for (int i=0;i<gridBoxes.size();i++) {
      if (i % xLines == 0) println();
      print(getFilledNeighbours(i, gridBoxes));
    }
    println();
    
    int t = 0;
    for (int i=0; i<gridBoxes.size();i++) {
      if (gridBoxes.get(i).filled) {
        t++;  
      }
    }
    println("total filled: "+t);
  }
  
}

public void mouseClicked() {
  grid.fillGridBox(new Point(mouseX,mouseY));
}

public void keyPressed() {
  if (key == 'c') {
    grid.resetBoard();
  } else if (key == 's') {
    alive = !alive;
  } else if (key == 't') {
    if (!(tickSpeed + 100 >= 1000)) {
      tickSpeed+=100;
    }
  } else if (key == 'g') {
    if (!(tickSpeed - 100 <= 0)) {
      tickSpeed-=100;
    }
  } else if (key == 'p') {
    grid.printGrid();
  }
}
