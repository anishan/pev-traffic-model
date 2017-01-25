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
  ArrayList<ArrayList<Bike>> timedBikes = new ArrayList<ArrayList<Bike>>();
  ArrayList<Car> activeCars = new ArrayList<Car>();
  ArrayList<Bike> bikes = new ArrayList<Bike>();
  ArrayList<Bike> activeBikes = new ArrayList<Bike>();
  ArrayList<PVector> home = new ArrayList<PVector>();
  ArrayList<PVector> work = new ArrayList<PVector>();

  /*
  * dataTable: table of points, where each point has the population at that point,
   * pathPlanner: class that stores memory about paths
   */
  public AgentHandler(Table dataTable, PathPlanner pathPlanner, int personPerCar, int carsPerAgent, int carsDrawn)
  {
    float[] hourProbs = {
      0.004844407, 0.009688814, 0.014533221, 0.019377628, 0.024222035000000003, 0.077415704, 0.221071947, 0.473739582, 0.718247572, 0.7993760990000001, 0.8347518920000001, 0.8513739580000002, 0.8716323880000002, 0.8918908180000003, 0.9121492480000003, 0.9324076780000004, 0.9408548070000003, 0.9493019360000003, 0.9577490650000003, 0.9661961940000003, 0.9746433230000003, 0.9830904520000003, 0.9915375810000003, 1
    };
    // Create an array of cars for every hour
    for (int i = 0; i < 24; i++)
    {
      timedCars.add(new ArrayList<Car>());
      timedBikes.add(new ArrayList<Bike>());
    }

    // To keep track of the number of agents and agents drawn
    // Only some of the car agents will be drawn, to reduce computational complexity
    int numcars = 0; // number of car objects
    int numbikes = 0;
    int cardrawn = 0; // number of car objects that will be drawn on the screen
    boolean draw;

    // Print progress of proccessing table, formatted nicely
    print("[AgentHandler] progress: 0%");
    for (int i = 0; i < (dataTable.getRowCount ()/5000) - 5; i++)
    {
      print(" ");
    }
    println("100%");
    print("[AgentHandler] progress: ");

    // Loop through all rows of the data table, and create appropriate car agents
    // To make agents based on traffic count data
    for (int i = 0; i < dataTable.getRowCount (); i++) 
//    for (int i = 0; i < 1000; i++) // for testing with limited data set
    {

      // Print a progress bar
      if (i%5000 == 0)
      {
        print("-");
      }

      // Read in information from the table
      PVector start = new PVector(dataTable.getRow(i).getFloat("startx"), dataTable.getRow(i).getFloat("starty"));
      PVector end = new PVector(dataTable.getRow(i).getFloat("endx"), dataTable.getRow(i).getFloat("endy"));
      points.add(start);

      // chose hour of the day based on probability
      double randHour = Math.random();

      int hour = 0;
      for (hour = 0; hour < hourProbs.length; hour++)
      {
        if (hourProbs[hour] > randHour)
        {
          break;
        }
      }
      if (hour == 24)
      {
        println("[AgentHandler] hour is 24");
      }

      // choose car or bike based on probability of mode of transportation
      // Baseline: 0.391 car and 0.42 bike
      // 25% of car start biking: 0.29325 car, 0.42 bike
      double randTransport = Math.random();
      if (randTransport < 0.391)
      {
        // Is a car
        if (i%carsDrawn ==0)
        {
          draw = true;
          cardrawn++;
          Car newCar = new Car(pathPlanner, start, end, draw);
          if (newCar.path.size() != 0)
          {
            timedCars.get(hour).add(newCar);
            timedCars.get((hour+10)%24).add(new Car(pathPlanner, end, start, draw)); // return trip
            numcars++;
            home.add(start);
            work.add(end);
          }
        }
      } else if (randTransport < 0.42)
      {
        // Is a bike
        Bike newBike = new Bike(pathPlanner, start, end);
        if (newBike.path.size() != 0)
        {
          timedBikes.get(hour).add(newBike);
          timedBikes.get((hour+10)%24).add(new Bike(pathPlanner, end, start)); // return trip
          numbikes++;
          home.add(start);
          work.add(end);
        }
      }
    }


    // Uncomment to add more housing in Kendall Sq
    // to make more jobs, change line 197 to end, and line 204 to 
//    for (int k = 0; k < 500; k++)
//    {
//      // randomize start point within that property
//      float randstarty = (float) (-71.08604 + (Math.random()*(-71.08431 - -71.08604)));
//      float randstartx = (float) (42.36287 + (Math.random()*(42.36615 - 42.36287)));
//      PVector start = new PVector(randstartx, randstarty);
//      
//      // choose a destination
//      float randendy = (float) (42.361473 + (42.368775 - 42.361473) * Math.random());
//      float randendx = (float) (-71.092645 + (-71.080661 - -71.092645) * Math.random());
//      float[][] destinations = {{42.36156,-71.07528},{42.35471,-71.09148},{42.36355,-71.10040},{42.37323,-71.10040},{randendx,randendy}}; // longfellow, mass ave bridge, main st, hampshire, random
//      int random = (int)(Math.random() * 5);
//      PVector end = new PVector(destinations[random][0], destinations[random][1]);
//      
//      
//      // chose hour of the day based on probability
//      double randHour = Math.random();
//      
//      int hour = 0;
//      for (hour = 0; hour < hourProbs.length; hour++)
//      {
//        if (hourProbs[hour] > randHour)
//        {
//          break;
//        }
//      }
//      if (hour == 24)
//      {
//        println("[AgentHandler] hour is 24");
//        
//      }
//      double randTransport = Math.random();
//      if (randTransport < 0.391)
//      {
//        // Is a car
//        Car newCar = new Car(pathPlanner, start, end, true);
//        if (newCar.path.size() != 0)
//        {
//          timedCars.get(hour).add(newCar);
//          timedCars.get((hour+10)%24).add(new Car(pathPlanner, end, start, true)); // return trip
//          numcars++;
//          home.add(start);
//          work.add(end);
//        }
//      }
//      else if (randTransport < 0.42)
//      {
//        // Is a bike
//        Bike newBike = new Bike(pathPlanner, start, end);
//        if (newBike.path.size() != 0)
//        {
//          timedBikes.get(hour).add(newBike);
//          timedBikes.get((hour+10)%24).add(new Bike(pathPlanner, end, start)); // return trip
//          numbikes++;
//          home.add(start);
//          work.add(end);
//        }
//      }
//    }

    println();
    println("[AgentHandler] Num agents drawn: " + cardrawn);
    println("[AgentHandler] Num cars: " + numcars);
    println("[AgentHandler] Num bikes: " + numbikes);
    println("[AgentHandler] Finished agent handler");

    // randomize order of cars in each list
    for (int i = 0; i < 24; i++)
    {
      Collections.shuffle(timedCars.get(i));
      Collections.shuffle(timedBikes.get(i));
      println("[AgentHandler] cars size: " + timedCars.get(i).size());
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
      c.totalTime = 0;
      c.restart(); // Restart the car
      activeCars.add(c);
    }
    activeBikes.clear();
    for (Bike b : bikes)
    {
      b.totalTime = 0;
      b.restart(); // Restart the car
      activeBikes.add(b);
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


  public void controlCars(float globalTime)
  {
    int hour = int(globalTime/3600);
    float timeFrac = (globalTime - (hour*3600))/3600; // number 0 to 1 of how far through hour has progessed
    if (hour > 23)
    {
      return;
    }
    int numCars = int(timedCars.get(hour).size());
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

    // bikes
    int numBikes = int(timedBikes.get(hour).size());
    for (int i = 0; i < timeFrac * numBikes; i++)
    {
      Bike b = timedBikes.get(hour).get(i);
      if (!activeBikes.contains(b))
      {
        b.totalTime = 0;
        b.restart(); // Restart the car
        activeBikes.add(b);
      }
    }
  }

  public void drawPoints(MercatorMap mercatorMap, PGraphics pg, int hour)
  {
//    println("[AgentHandler] in drawpoints, hour: " + hour);
    pg.ellipseMode(CENTER);
//    //    println("[AgentHandler] in drawPoints");
//    
//    //    println("[AgentHandler] width: " + width + " height: " + height);
    pg.noStroke();
//    pg.fill(255, 0, 0, 254);
//    ////    PVector point = new PVector(50,50);
//    //    println("[AgentHandler] width: " + width + " height: " + height);
//    pg.ellipse(100, 100, 20, 20);
//    color c = color(100,100,100);
//    pg.stroke(c, 200);
//    pg.strokeWeight(20);
//    pg.line(50, 50, 51,51);
    //    println("[AgentHandler] width: " + width + " height: " + height);
    //    for (int carList = 0; carList < timedCars.size (); carList++)
    //    {
//    for (hour = 0; hour<24; hour++)
    {

    for (int i = 0; i < home.size(); i++)
    {
//      println("[AgentHander] car: " + timedCars.get (hour).get(i).start.x); 
      boolean onscreenStart;
      boolean onscreenEnd;
      PVector start = new PVector(0, 0);
      PVector end = new PVector(0, 0);
      float radius = 0;
      try
      {
//        println("[AgentHander] startx: " + timedCars.get(hour).get(i).start.x + " starty: " + timedCars.get(hour).get(i).start.y);
        start = mercatorMap.getScreenLocation(home.get(i));
        radius = 10;
        onscreenStart = start.x > 0 && start.x < width && start.y > 0 && start.y < height;
        // draw white circle at start
        //          pg.fill(#ffffff, 10);
        //          pg.ellipse(start.x, start.y, radius/2, radius/2);
        //          pg.fill(#ffffff, 7);
        //          pg.ellipse(start.x, start.y, radius*3/4, radius*3/4);
        pg.fill(#cccccc, 100);
        float r = (float)(50*Math.random());
        if (start.x == 42.3601076 && start.y == -71.09094946)
        {
          r = (float)(150*Math.random());
        }
        float angle = (float)(2*Math.PI*Math.random());
        pg.ellipse((float)(start.x + (r*cos(angle))), (float)(start.y + (r*sin(angle))), radius, radius);
      }
      catch (Exception e)
      {
      }
      
    }
      for (int i = 0; i < work.size(); i++)
      {
        boolean onscreenStart;
        boolean onscreenEnd;
        PVector start = new PVector(0, 0);
        PVector end = new PVector(0, 0);
        float radius = 0;
        try
        {
          end = mercatorMap.getScreenLocation(work.get(i));
          radius = 10;
          onscreenEnd = end.x > 0 && end.x < width && end.y > 0 && end.y < height;
          pg.fill(#ff8800, 100);
          // randomly in circle
          float r = (float)(50*Math.random());
          if (work.get(i).x == 42.3601076 && work.get(i).y == -71.09094946)
          {
            r = (float)(150*Math.random());
          }
          float angle = (float)(2*Math.PI*Math.random());
          pg.ellipse((float)(end.x + (r*cos(angle))), (float)(end.y + (r*sin(angle))), radius, radius);
        }
        catch (Exception e)
        {
        }
      }
    }
  }
}

