/*
* Class that creates agents from relevant information, and stores agents
 * Contains function to begin agent movement
 */

import java.util.Collections;

public class AgentHandler
{
  // Store the agents and associated information
  ArrayList<PVector> points = new ArrayList<PVector>(); // PVector locations of all census points
  ArrayList<Integer> hurrCats = new ArrayList<Integer>();
  ArrayList<Integer> pops = new ArrayList<Integer>();
  ArrayList<Car> cars = new ArrayList<Car>();
  ArrayList<ArrayList<Car>> timedCars = new ArrayList<ArrayList<Car>>();
  ArrayList<Car> activeCars = new ArrayList<Car>();
  ArrayList<Bike> bikes = new ArrayList<Bike>();
  ArrayList<Bike> activeBikes = new ArrayList<Bike>();
  ArrayList<Car> start6am = new ArrayList<Car>();
  ArrayList<Car> start7am = new ArrayList<Car>();
  ArrayList<Car> start8am = new ArrayList<Car>();
  ArrayList<Car> start9am = new ArrayList<Car>();
  int nextIndex = 0;

  /*
  * dataTable: table of points, where each point has the population at that point,
   *   and which category of hurricane effects it
   * pathPlanner: class that stores memory about paths
   */
  public AgentHandler(Table dataTable, PathPlanner pathPlanner, int personPerCar, int carsPerAgent, int carsDrawn)
  {
    for (int i = 0; i < 24; i++)
    {
      timedCars.add(new ArrayList<Car>());
    }


    // To keep track of the number of agents and agents drawn
    // Only some of the car agents will be drawn, to reduce computational complexity
    int carnum = 0; // number of car objects
    int cardrawn = 0; // number of car objects that will be drawn on the screen
    boolean draw;

    // Print progress of proccessing table, formatted nicely
    print("[AgentHandler] progress: 0%");
    for (int i = 0; i < (dataTable.getRowCount ()/5) - 5; i++)
    {
      print(" ");
    }
    println("100%");
    print("[AgentHandler] progress: ");

    // Loop through all rows of the data table, and create appropriate car agents
    // To make agents based on people who live in cambridge
    for (int i = 0; i < dataTable.getRowCount (); i++) 
      //    for (int i = 0; i < 20; i++) // Limited data for testing
    {

      // Print a progress bar
      if (i%5 == 0)
      {
        print("-");
      }

      // Read in information from the table
      PVector start = new PVector(dataTable.getRow(i).getFloat("x"), dataTable.getRow(i).getFloat("y"));
      //      println("[AgentHandler] start: " + start);
      PVector end;
      //PVector end = new PVector(dataTable.getRow(i).getFloat("endx"), dataTable.getRow(i).getFloat("endy"));
      points.add(start);
      int pop = dataTable.getRow(i).getInt("count");
      int hour = dataTable.getRow(i).getInt("time_since_midnight");
      //      int workingPop = int(pop*0.578); // 57.8% of cambridge residents are employed

      // Camb residents that work in camb and drive (16.3%)
      for (int j = 0; j < pop; j++) // half of people drive in rush hour
      {
        if (j%carsDrawn ==0)
        {
          draw = true;
          cardrawn++;
        } else
        {
          draw = false;
        }
        // Chose destination points randomly, assuming that most businesses are clustered at squares
        // TODO, randomize exact locations within that area
        // in the future, maybe get ameneties data
        float[][] cambsqs = {{42.3954, -71.1425}, {42.3884, -71.1191}, {42.3736, -71.1190}, {43.2867, -76.1460}, {42.3629, -71.0901}}; // alewife, porter, harvard, central, kendall
//        ThreadLocalRandom.current().nextDouble(42.361473, 42.368775), ThreadLocalRandom.current().nextDouble(-71.092645, -71.080661)
        float randLat = (float) (42.361473 + (42.368775 - 42.361473) * Math.random());
        float randLon = (float) (-71.092645 + (-71.080661 - -71.092645) * Math.random());
        float[][] destinations1 = {{42.361833,-71.080630},{42.360350,-71.083908},{42.359249,-71.087163},{42.368023,-71.080774},{randLat,randLon}};
        float[][] destinations2 = {{42.368023,-71.080774},{42.362109,-71.090881},{42.365779,-71.092001},{42.362857,-71.091945},{randLat,randLon}};
        float[][] destinations;
        if (i < 73) // coming from the west
        {
          destinations = destinations1;
        }
        else // coming from the east
        {
          destinations = destinations2;
        }
        
        
        
        
        int random = (int)(Math.random() * 5);
        end = new PVector(destinations[random][0], destinations[random][1]);
        // try catch because pathplanner sometimes has null error because ofroad permissions
        //        end = new PVector(42.36549, -71.08254);
        //        try 
        //        {
        //          cars.add(new Car(pathPlanner, start, end, draw));
        timedCars.get(hour).add(new Car(pathPlanner, start, end, draw));
        //        } catch (Exception e) {
        //          e.printStackTrace();
        //        }
      }
      //      
      // Camb residents that work in abutting cities and drive (randomize between arlington, belmon, boston, brookline, somerville, watertown (26%)
      //      for (int j = 0; j < int(workingPop*0.26*.25); j++) // only half of people drive in rush hour
      //      {
      //        if (j%carsDrawn ==0)
      //        {
      //          draw = true;
      //          cardrawn++;
      //        }
      //        else
      //        {
      //          draw = false;
      //        }
      //        // Chose destination points randomly, assuming that most businesses are clustered at squares
      //        // TODO, randomize exact locations within that area
      //        // randomize between arlington, belmon, boston, brookline, somerville, watertown
      //        float[][] cambsqs = {{42.4154, -71.1565}, {42.3956, -71.1776}, {42.3601, -71.0589}, {42.3601, -71.0589}, {42.3318, 71.1212}, {42.3876, -71.0995}, {43.9748, -75.9108}};
      //        int random = (int)(Math.random() * 7);
      ////        end = new PVector(cambsqs[random][0], cambsqs[random][1]);
      //        end = new PVector(42.3901, -71.1211);
      ////        try 
      ////        {
      //          cars.add(new Car(pathPlanner, start, end, draw));
      ////        } catch (Exception e) {
      ////          e.printStackTrace();
      ////        }
      //      }


      // Camb residents that work far away and drive (destination to highway points) (70.8%)




      //      String type = dataTable.getRow(i).getString("type");
      //      if (type.equals("car"))
      //      {
      //        cars.add(new Car(pathPlanner, start, end));
      //        carnum++;
      //      }
      //      else if (type.equals("bike"))
      //      {
      //        bikes.add(new Bike(pathPlanner, start, end));
      //      }

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


    // TODO make agents that work in cambridge

    //    for (int k = 0; k < cars.size(); k++)
    //    {
    //      if (k%4==0)
    //      {
    //        start6am.add(cars.get(k));
    //      }
    //      else if (k%4 ==1)
    //      {
    //        start7am.add(cars.get(k));
    //      }
    //      else if (k%4==2)
    //      {
    //        start8am.add(cars.get(k));
    //      }
    //      else
    //      {
    //        start9am.add(cars.get(k));
    //      }
    //      
    //    }

    //    cars.add(new Car(pathPlanner, new PVector(42.3856, -71.1172), new PVector(42.3648, -71.1037), true));
    //    bikes.add(new Bike(pathPlanner, new PVector(42.3856, -71.1172), new PVector(42.3648, -71.1037)));
    //    bikes.add(new Bike(pathPlanner, new PVector(42.3648, -71.087983), new PVector(42.3856, -71.1172)));
    //  bikes.add(new Bike(pathPlanner, new PVector(42.3856, -71.1172), new PVector(42.360622, -71.087983)));
    //    bikes.add(new Bike(pathPlanner, new PVector(42.353833, -71.10976), new PVector(42.360622, -71.087983)));

    println();
    println("[AgentHandler] Num cars drawn: " + cardrawn);
    println("[AgentHandler] Num agents: " + cars.size());
    println("[AgentHandler] Finished agent handler");
    Collections.shuffle(cars);
    for (int i = 0; i < 24; i++)
    {
      Collections.shuffle(timedCars.get(i));
    }
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
    for (int i = 0; i < points.size (); i ++)
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
    for (Car c : cars)
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
    for (Bike b : bikes)
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

  public void startBikes()
  {
    activeBikes.clear();
    for (Bike b : bikes)
    {
      b.totalTime = 0;
      b.restart(); // Restart the car
      activeBikes.add(b);
    }
  }

  public void startCars()
  {
    activeCars.clear();
    for (Car c : cars)
    {
      c.totalTime = 0;
      c.restart(); // Restart the car
      activeCars.add(c);
    }
  }

  /* 
   * Start moving the cars at the beginning of each simulation scenario
   */
  public void start6am()
  {
    println("[AgentHandler] active crs: " + activeCars);
    activeCars.clear();
    println("[AgentHandler] active crs: " + activeCars);
    // Clear the cars from the current simulation information
    for (Car c : start6am)
    {
      c.totalTime = 0;
      c.restart(); // Restart the car
      if (!activeCars.contains(c))
      {
        activeCars.add(c);
      }
    }
  }
  public void start7am()
  {
    // Clear the cars from the current simulation information
    for (Car c : start7am)
    {
      c.totalTime = 0;
      c.restart(); // Restart the car
      if (!activeCars.contains(c))
      {
        activeCars.add(c);
      }
    }
  }
  public void start8am()
  {
    // Clear the cars from the current simulation information
    for (Car c : start8am)
    {
      c.totalTime = 0;
      c.restart(); // Restart the car
      if (!activeCars.contains(c))
      {
        activeCars.add(c);
      }
    }
  }
  public void start9am()
  {
    // Clear the cars from the current simulation information
    for (Car c : start9am)
    {
      c.totalTime = 0;
      c.restart(); // Restart the car
      if (!activeCars.contains(c))
      {
        activeCars.add(c);
      }
    }
  }

  //  public void startTimed(time)
  //  {
  //    // Clear the cars from the current simulation information
  //    for (Car c: start9am)
  //    {
  //      c.totalTime = 0;
  //      c.restart(); // Restart the car
  //      if (!activeCars.contains(c))
  //      {
  //        activeCars.add(c);
  //      }
  //    }
  //  }

  public void controlCars(float globalTime)
  {
    int hour = int(globalTime/3600);
    float timeFrac = (globalTime - (hour*3600))/3600; // number 0 to 1 of how far through hour has progessed
    if (hour > 23)
    {
      return;
    }
    int numCars = int(timedCars.get(hour).size());
    //    activeCars.clear();
    for (int i = 0; i < timeFrac * numCars; i++)
    {
      Car c = timedCars.get(hour).get(i);
      if (!activeCars.contains(c))
      {
        c.totalTime = 0;
        c.restart(); // Restart the car
        activeCars.add(c);
      }
    }
  }
}

