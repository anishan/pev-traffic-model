/*
* Class that creates agents from relevant information, and stores agents
* Contains function to begin agent movement
*/
public class AgentHandler
{
  // Store the agents and associated information
  ArrayList<PVector> points = new ArrayList<PVector>(); // PVector locations of all census points
  ArrayList<Integer> hurrCats = new ArrayList<Integer>();
  ArrayList<Integer> pops = new ArrayList<Integer>();
  ArrayList<Car> cars = new ArrayList<Car>();
  ArrayList<Car> activeCars = new ArrayList<Car>();
  ArrayList<Bike> bikes = new ArrayList<Bike>();
  ArrayList<Bike> activeBikes = new ArrayList<Bike>();

  /*
  * dataTable: table of points, where each point has the population at that point,
  *   and which category of hurricane effects it
  * pathPlanner: class that stores memory about paths
  */
  public AgentHandler(Table dataTable, PathPlanner pathPlanner, int personPerCar, int carsPerAgent, int carsDrawn)
  {
    // To keep track of the number of agents and agents drawn
    // Only some of the car agents will be drawn, to reduce computational complexity
    int carnum = 0; // number of car objects
    int cardrawn = 0; // number of car objects that will be drawn on the screen
    boolean draw;
    
    // Print progress of proccessing table, formatted nicely
    print("[AgentHandler] progress: 0%");
    for (int i = 0; i < (dataTable.getRowCount()/20) - 5; i++)
    {
      print(" ");
    }
    println("100%");
    print("[AgentHandler] progress: ");
    
    // Loop through all rows of the data table, and create appropriate car agents
    for (int i = 0; i < dataTable.getRowCount (); i++) 
//    for (int i = 0; i < 20; i++) // Limited data for testing
    {
      
      // Print a progress bar
      if (i%20 == 0)
      {
        print("-");
      }
      
      // Read in information from the table
      PVector start = new PVector(dataTable.getRow(i).getFloat("x"), dataTable.getRow(i).getFloat("y"));
      PVector end = new PVector(dataTable.getRow(i).getFloat("endx"), dataTable.getRow(i).getFloat("endy"));
      points.add(start);
      String type = dataTable.getRow(i).getString("type");
      if (type.equals("car"))
      {
        cars.add(new Car(pathPlanner, start, end));
        carnum++;
      }
      else if (type.equals("bike"))
      {
        bikes.add(new Bike(pathPlanner, start, end));
      }
      // Create the objects
//      for (int j = 0; j <= pop/ (personPerCar*carsPerAgent); j++) // One car per 40 people
//      {
//        if (carnum%carsDrawn == 0) // Draw every 20th car
//        {
//          draw = true;
//          cardrawn++;
//        }
//        else
//        {
//          draw = false;
//        }
//        // Create car object
//        cars.add(new Car(pathPlanner, point.x, point.y, hurrCat, draw));
//        // Increase count of cars
//        carnum++;
//      }
    }
    
    println();
    println("[AgentHandler] Num cars drawn: " + cardrawn);
    println("[AgentHandler] Num agents: " + cars.size());
    println("[AgentHandler] Finished agent handler");
  }

  /*
  * Draw the location of each point with population data
  * mercatorMap: the same map object used by the main visualization
  */
  public void drawPoints(MercatorMap mercatorMap)
  {
    stroke(#ff00ff);
    strokeWeight(2);
    for (PVector p : this.points)
    {
      PVector point = mercatorMap.getScreenLocation(p);
      ellipse(point.x, point.y, .5, .5);
    }
  }
  
  public void drawPoints(MercatorMap mercatorMap, PGraphics pg)
  {
//    pg.fill(#ff00ff, 100);
    pg.fill(#ffffff, 75);
    pg.noStroke();
    for (int i = 0; i < points.size(); i ++)
    {
//      if ((hurrCats.get(i) != 0) && (hurrCats.get(i) <= hurrCat))
//      {
        PVector point = mercatorMap.getScreenLocation(points.get(i));
        float radius = 20 * (pops.get(i)/10000.0);
        pg.ellipse(point.x, point.y, radius/2, radius/2);
        pg.fill(#ffffff, 50);
        pg.ellipse(point.x, point.y, radius*3/4, radius*3/4);
        pg.fill(#ffffff, 25);
        pg.ellipse(point.x, point.y, radius, radius);
//      }
    }
  }
  
  /* 
  * Start moving the cars at the beginning of each simulation scenario
  */
  public void startVehicles()
  {
    // Clear the cars from the current simulation information
    activeCars.clear();
    for (Car c: cars)
    {
//      println("[AgentHandler] car: " + c);
      c.totalTime = 0;
      // Check whether that agent is in the category to be restarted
//      if ((c.hurrCat != 0) && (c.hurrCat <= hurrCat))
//      {
        c.restart(); // Restart the car
        activeCars.add(c);
//      }
    }
    activeBikes.clear();
    for (Bike b: bikes)
    {
//      println("[AgentHandler] car: " + c);
      b.totalTime = 0;
      // Check whether that agent is in the category to be restarted
//      if ((c.hurrCat != 0) && (c.hurrCat <= hurrCat))
//      {
        b.restart(); // Restart the car
        activeBikes.add(b);
//      }
    }
  }
  
}

