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

  /*
  * dataTable: table of points, where each point has the population at that point,
   * pathPlanner: class that stores memory about paths
   */
  public AgentHandler(Table dataTable, PathPlanner pathPlanner, int personPerCar, int carsPerAgent, int carsDrawn)
  {
    // Create an array of cars for every hour
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
    // To make agents based on traffic count data
    for (int i = 0; i < dataTable.getRowCount (); i++) 
    {

      // Print a progress bar
      if (i%5 == 0)
      {
        print("-");
      }

      // Read in information from the table
      PVector start = new PVector(dataTable.getRow(i).getFloat("x"), dataTable.getRow(i).getFloat("y"));
      PVector end;
      points.add(start);
      int pop = dataTable.getRow(i).getInt("count");
      int hour = dataTable.getRow(i).getInt("time_since_midnight");

      for (int j = 0; j < pop; j++) // half of people drive in rush hour
      {
        if (j%carsDrawn ==0)
        {
          draw = true;
          cardrawn++;
        } 
        else
        {
          draw = false;
        }
        // Chose destination points 
        // random points within displayed area
        float randLat = (float) (42.361473 + (42.368775 - 42.361473) * Math.random());
        float randLon = (float) (-71.092645 + (-71.080661 - -71.092645) * Math.random());
        // main exits to kendall traffic, depending on where the cars started
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

        timedCars.get(hour).add(new Car(pathPlanner, start, end, draw));
      }
    }

    println();
    println("[AgentHandler] Num cars drawn: " + cardrawn);
    println("[AgentHandler] Num agents: " + timedCars.size());
    println("[AgentHandler] Finished agent handler");
    
    // randomize order of cars in each list
    Collections.shuffle(cars);
    for (int i = 0; i < 24; i++)
    {
      Collections.shuffle(timedCars.get(i));
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

