/*
* Class describing the agents in this model
* Each bike contains information about its origin, destination, and path
* For the queueing model, each bike also knows how much time left on the road
*/
public class Bike
{
//  RoadNetwork roads;

  // Pathfinding information
  Node start;  
  Node end;
  // Stores path information as a list of roads, in order, that the bike must move along
  ArrayList<Road> path = new ArrayList<Road>();

  // Queueing Model information
  // Keep track of current road and time left on road
  int currentIndex;
  float timeRemaining; // time left on road
  
  // For drawing
  boolean draw; // whether this bike will be drawn
  color c;
  // PVector that will be updated with ever time step to show movement
  // This will also contain approximate information about location along road,
  // for visualization purposes
  PVector current = null;
    
  // Timing info (for validation)
  float startTime;
  float endTime;
  float totalTime = 0;
  
  public Bike(PathPlanner pathPlanner, PVector start, PVector end)
  {    
    this.path = pathPlanner.getPath(start, end, "bike");
    this.draw = true;
    int rand =  (int)(Math.random()*100) + 155;
    this.c = color(255, rand, 0);
  }
  
  /*
  * Start bikes from the origin again, for restarting the simulation
  * Reset path planning information
  */
  public void restart()
  {
    this.currentIndex = -1;
    if (path.size() > 0) // Make sure that a path exists, prevents errors
    {
      this.current = path.get(0).nodes[0].node;
      this.path.get(0).addBike(this);
    }
    this.startTime = millis();
    totalTime = 0;
  }

  ////////////////////////////////////////////////////////////// QUEUEING MODEL

  /*
  * Return the next road in the path, or null if the bike is at the end
  */
  public Road getNextRoad()
  {
    if (this.currentIndex + 1 < this.path.size())
    {
      return path.get(this.currentIndex + 1);
    }
    else
    {
      return null;
    }
  }

  // Behavior for when the bike gets accepted onto the next road
  public void moveOntoNextRoad()
  {
    // If already along the path, the remove the bike from the current road
    if (currentIndex > -1)
    {
      path.get(currentIndex).bikes.remove(this);
    }
    else // at end of path
    {
      this.endTime = millis();
    }
    // Update the index for the next road
    currentIndex++;
    // Update location for drawing
    current = path.get(this.currentIndex).nodes[0].node;
  }

  // Called by the road, to set the time left on that road until it reaches the end
  public void setTimeRemaining(float time)
  {
    this.timeRemaining = time;
  }

  // Return time remaining
  public float getTimeRemaining()
  {
    return this.timeRemaining;
  }
  
  ////////////////////////////////////////////////////////////// VISUALIZATION

  
  // Draw the bike using graphics
  public void drawBike(MercatorMap mercatorMap, PGraphics pg)
  {
    if (draw)
    {
      pg.fill(c);
      pg.noStroke();
      PVector point = mercatorMap.getScreenLocation(this.current);
      pg.ellipse(point.x, point.y, 5, 5);
    }
  }

}

