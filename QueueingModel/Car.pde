/*
* Class describing the agents in this model
* Each car contains information about its origin, destination, and path
* For the queueing model, each car also knows how much time left on the road
*/
public class Car
{
//  RoadNetwork roads;

  // Pathfinding information
  Node start;  
  Node end;
  // Stores path information as a list of roads, in order, that the car must move along
  ArrayList<Road> path = new ArrayList<Road>();

  // Queueing Model information
  // Keep track of current road and time left on road
  int currentIndex;
  float timeRemaining; // time left on road
  
  // For drawing
  boolean draw; // whether this car will be drawn
  color c;
  // PVector that will be updated with ever time step to show movement
  // This will also contain approximate information about location along road,
  // for visualization purposes
  PVector current = null;
  
  // Agent parameters information
  public int hurrCat; // Minimum category of hurricane which will require evacuation
  
  // Timing info (for validation)
  float startTime;
  float endTime;
  float totalTime = 0;
   
  
  
  public Car(PathPlanner pathPlanner, PVector start, PVector end)
  {    
    this.path = pathPlanner.getPath(start, end, "car");
    this.draw = true;
    this.hurrCat = 1;
    this.c = color(255, 170, 0);
//    this.restart();
  }
  
  /*
  * Start cars from the origin again, for restarting the simulation
  * Reset path planning information
  */
  public void restart()
  {
    this.currentIndex = -1;
//    println("[Car] path: " + path);
    if (path.size() > 0) // Make sure that a path exists, prevents errors
    {
      this.current = path.get(0).nodes[0].node;
      this.path.get(0).addCar(this);
//      println("[Car] path: " + this.path);
//       println("[Car] road cars: " + this.path.get(0).cars, " capacity: " + this.path.get(0).capacity, " waitlist: " + this.path.get(0).waitlist);
    }
    this.startTime = millis();
    totalTime = 0;
  }

  ////////////////////////////////////////////////////////////// QUEUEING MODEL

  /*
  * Return the next road in the path, or null if the car is at the end
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

  // Behavior for when the car gets accepted onto the next road
  public void moveOntoNextRoad()
  {
    // If already along the path, the remove the car from the current road
    if (currentIndex > -1)
    {
      path.get(currentIndex).cars.remove(this);
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
  
  // Draw the car as a circle on the main map
  public void drawCar(MercatorMap mercatorMap)
  {
    if (draw)
    {
      stroke(c);
      strokeWeight(2.5);
      PVector point = mercatorMap.getScreenLocation(this.current);
      ellipse(point.x, point.y, 2.5, 2.5);
    }
  }
  
  // Draw the car using graphics
  public void drawCar(MercatorMap mercatorMap, PGraphics pg)
  {
//    print(this.current+",");
    if (draw)
    {
      pg.fill(c);
      pg.noStroke();
      PVector point = mercatorMap.getScreenLocation(this.current);
      pg.ellipse(point.x, point.y, 6, 6);
    }
  }

}

