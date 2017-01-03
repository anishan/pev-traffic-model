// City Traffic Model
// Anisha Nakagawa


// Main Queueing Model

// Storing helper classes 
RoadNetwork roadNetwork;
RoadNetwork detailedRoadNetwork;
AgentHandler agentHandler;
MercatorMap mercatorMap;
PathPlanner pathPlanner;
BackgroundHandler backgroundHandler;

// Size Data

// Set up map size and merc projection with lat lon boundaries
// Change this if using different data sets

// Bounds for Boston
//float Top_lat = 42.399;
//float Bottom_lat = 42.3135;
//float Left_lon = -71.1715;//-71.1705; 
//float Right_lon = -71.0212;

//// Bounds for plot
float Top_lat = 42.368775;
float Bottom_lat = 42.361473;
float Left_lon = -71.092645;//-71.1705; 
float Right_lon = -71.080661;



////// Bounds for Kendall
//float Top_lat = 42.37417;
//float Bottom_lat = 42.35619;
//float Left_lon = -71.09986;//-71.1705; 
//float Right_lon = -71.07784;



//// Bounds for Camb
//float Top_lat = 42.3901;
//float Bottom_lat = 42.3521;
//float Left_lon = -71.1211;//-71.1705; 
//float Right_lon = -71.071;

// Bounds for eastern Mass
//float Top_lat = 42.8846;
//float Bottom_lat = 41.512;
//float Left_lon = -72.1; 
//float Right_lon = -69.955;

// Bounds for Kendall
//float Top_lat = 42.36296;
//float Bottom_lat = 42.35422;
//float Left_lon = -71.09647;//-71.1705; 
//float Right_lon = -71.08079;


// Bounding coordinates
PVector top_left_corner = new PVector(Top_lat, Left_lon);
PVector top_right_corner = new PVector(Top_lat, Right_lon);
PVector bottom_left_corner = new PVector(Bottom_lat, Left_lon);
PVector bottom_right_corner = new PVector(Bottom_lat, Right_lon);

// Calculate the size of the screen based on the actual distance between lat lon corneres
float widthDistance = MercatorMap.latlonToDistance(top_left_corner, top_right_corner);
float heightDistance = MercatorMap.latlonToDistance(top_left_corner, bottom_left_corner);
float aspectRatio = widthDistance / heightDistance;
int size = 800;

// Projection things
// for square:
PVector centerOriginal = MercatorMap.intermediate(top_left_corner, bottom_right_corner, 0.5);
float edgeDistanceOriginal = max(widthDistance, heightDistance);
float edgeDistanceOriginalWidth = edgeDistanceOriginal;
float edgeDistanceOriginalHeight = edgeDistanceOriginal;
//PVector centerOriginal = MercatorMap.intermediate(top_left_corner, bottom_right_corner, 0.5);
//float edgeDistanceOriginalWidth = widthDistance;
//float edgeDistanceOriginalHeight = heightDistance;

PVector viewCenter = centerOriginal;
//float viewDistance = edgeDistanceOriginal; // For square view
float viewDistanceWidth = edgeDistanceOriginalWidth;
float viewDistanceHeight = edgeDistanceOriginalHeight;


boolean showFrameRate = false;
boolean printWaitlist = false;

PGraphics agentsPGraphic;
boolean initialized = false;

// Modeling variables
int personPerCar = 5; // Each real-life car holds 5 people
int carsPerAgent = 1; // Each agent represents n cars
int carsDrawn = 1; // One in every n cars will be drawn to screen

// Simulation timing
float prevTime;
// 0.1: 100 sec sim time in 1 sec real time (100x speed)
// 1.0: 1000 sec sim time in 1 sec real time (1000x speed)
float timeStep = 0.08; // simulation time (seconds) / real time (ms)
// Higher numbers make the simulation run faster
float globalTime = 0; // seconds
float prevResidueTime = globalTime;

boolean addResidue;

// To simplify the graph
// super simple: 10000
// still normal and lots of nodes: 100
// looks reasonable but simplified: 1000
int simplification = 5;

// Validation
Car testCar;

boolean pause = false;

void setup()
{
  size(int(size), int(size), P2D);    

  // Load road data
  // All roads:
  println("[QueueingModel] before load data");
  Table roadTable = loadTable("data/kendall-roads-small-nodes-clean.csv", "header");
  // Attributes:
  Table roadAttrTable = loadTable("data/kendall-roads-small-attr-clean.csv", "header");
  println("[QueueingModel] loaded road data");
  Table massTable = loadTable("data/massstatessimple-nodes-clean.csv", "header");

  
  println("[QueueingModel] before roadnetwork");
  // Build road network
  roadNetwork = new RoadNetwork(roadTable, roadAttrTable, carsPerAgent, simplification);
  println("[QueueingModel] Number of roads: " + roadNetwork.roads.size());

  // Build pathplanner class
  pathPlanner = new PathPlanner(roadNetwork);

  // Load population data
  Table agentsDataTable = loadTable("data/trafficcounts.csv", "header");
//  Table agentsDataTable = loadTable("data/kendall-pop-nodes-clean.csv", "header");
//  Table agentsDataTable = loadTable("data/test-nodes-clean.csv", "header");

  // Create agent handler (which creates agents
  agentHandler = new AgentHandler(agentsDataTable, pathPlanner, personPerCar, carsPerAgent, carsDrawn);
  
  backgroundHandler = new BackgroundHandler(massTable, roadNetwork, agentHandler);

  // Start the cars onto the first roads
//  agentHandler.startVehicles(); // 1=hurricane category 1

  // Start tracking time
  prevTime = millis();
  

  //  noLoop(); // for testing only
  println("[QueueingModel] just before draw()");
}

void draw()
{


    if (showFrameRate)
    {
      println("[QueueingModel] framerate: " + frameRate);
    }
  
    if (!initialized)
    {
      // Draw setup visualization
      PVector viewTopLeft = MercatorMap.endpoint(viewCenter, sqrt(viewDistanceWidth*viewDistanceWidth/4.0 + viewDistanceHeight*viewDistanceHeight/4.0), -90+degrees(atan(viewDistanceHeight/viewDistanceWidth))); // NW
      PVector viewBottomRight = MercatorMap.endpoint(viewCenter, sqrt(viewDistanceWidth*viewDistanceWidth/4.0 + viewDistanceHeight*viewDistanceHeight/4.0), 90+degrees(atan(viewDistanceHeight/viewDistanceWidth))); // SE
      mercatorMap = new MercatorMap(size, size/aspectRatio, viewTopLeft.x, viewBottomRight.x, viewTopLeft.y, viewBottomRight.y);

//      backgroundHandler.createMassOutline(mercatorMap);
      backgroundHandler.createRoads(mercatorMap);
      backgroundHandler.createPopCenters(mercatorMap);
//      backgroundHandler.createResidue(mercatorMap);
//      backgroundHandler.createText();
      
      agentsPGraphic = createGraphics(width, height);
      initialized = true;
      prevTime = millis();
      
//      agentHandler.startCars();
      
//        for (int i = 0; i < agentHandler.cars.size(); i++)
//        {
//          agentHandler.cars.get(i).restart();
//        }
    }
    
    agentHandler.controlCars(globalTime);
    
    // start cars
//    if (int(globalTime/60) == 0) // 6am
//    {
//      agentHandler.start6am();
//    }
//    if (int(globalTime/60) == 60) // 7am
//    {
//      agentHandler.start7am();
//    }
//    if (int(globalTime/60) == 120) // 8am
//    {
//      agentHandler.start8am();
//    }
//    if (int(globalTime/60) == 180) // 9am
//    {
//      agentHandler.start9am();
//    }
  
    // Only adds residue to the graph every 10 minutes (simulation time)
    addResidue = globalTime > prevResidueTime + 10*60; // every 10 min
    float currentTime = millis();
    if (!pause)
    {  
      // Take step
      for (int i = 0; i < roadNetwork.roads.size (); i++)
      {
        
        Road r = roadNetwork.roads.get(i);
        r.moveBikes((currentTime-prevTime)*timeStep/3, printWaitlist);
        r.moveCars((currentTime-prevTime)*timeStep/3, printWaitlist);
        
        // Draw residue
        if (addResidue && r.waitlist.size() > 5) // for congested roads
        {
          backgroundHandler.addResidue(r);
          prevResidueTime = globalTime;
        }
        
      }
      globalTime += (currentTime-prevTime)*timeStep;
      prevTime = millis();
    }
    
    
    
    // Draw the cars
    // This is in a separate loop than calculaing because:
    // 1) Prevents duplicate points drawn when a car switches roads
    // 2) Experimentally found to run faster this way
    agentsPGraphic.clear();
    agentsPGraphic.beginDraw();
    boolean emptyModel = true;
    for (Road r: roadNetwork.roads)
    {
      for (int i = r.bikes.size() -1; i >=0; i--)
      {
        emptyModel = false;
        // Draw car
//        println("[QueueingModel] bikes: " + r.bikes.get(i));
        r.bikes.get(i).drawBike(mercatorMap, agentsPGraphic);
        
      }
      for (int i = r.cars.size() -1; i >=0; i--)
      {
        emptyModel = false;
        // Draw car
        r.cars.get(i).drawCar(mercatorMap, agentsPGraphic);      
      }
//      println("[QueueingModel] bikes size: " + r.bikes.size());
      
    }
    
    if (emptyModel)
    {
//      pause = true;
//      // Histogram, uncomment to print to screen
//      ArrayList<Integer> time = new ArrayList<Integer>();
//      ArrayList<Integer> count = new ArrayList<Integer>();
//      for (Car c: agentHandler.cars)
//      {
//        if (c.totalTime != 0)
//        {
//          int timeInt = int(c.totalTime/3600); // hours
//          if (time.contains(timeInt))
//          {
//            int index = time.indexOf(timeInt);
//            int countInt = count.remove(index);
//            count.add(index, countInt+1);
//          }
//          else
//          {
//            time.add(int(c.totalTime/3600));
//            count.add(1);
//          }
//        }
//      }
//      for (int i = 0; i < time.size(); i ++)
//      {
//        println(time.get(i) + "," + count.get(i));
//      }
    }
    
//    testCar.drawCar(mercatorMap, agentsPGraphic);
    agentsPGraphic.endDraw();
    
    
  
    // Draw PGraphic
    backgroundHandler.drawAll(mercatorMap);   
    image(agentsPGraphic, 0, 0, width, height);
//    backgroundHandler.drawText();
    
    // Text
    fill(255, 225);
    textSize(height*0.022);
    text("Time: " + int(globalTime/3600) + ":" + int(globalTime/60)%60, width*0.8, height*0.96); 

}

// Restart the model based on keyboard input
void keyPressed()
{
  if (key == '0') // restart
  {
    println("[QueueingModel] in 0");
//    hurrCat = 1;
    roadNetwork.clearRoads();
    globalTime = 0; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
//    emptymodel = false;
  } 
  if (key == 'b') // restart
  {
    println("[QueueingModel] in b");
    agentHandler.startBikes();
  } 
  if (key == '1') // restart ///////////////////////////////////
  {
    roadNetwork.clearRoads();
    agentHandler.activeCars.clear();
    globalTime = 6*3600; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
  } 
  if (key == '2') // restart
  {
    roadNetwork.clearRoads();
    agentHandler.activeCars.clear();
    globalTime = 8*3600; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
  } 
  if (key == '3') // restart
  {
    roadNetwork.clearRoads();
    agentHandler.activeCars.clear();
    globalTime = 10*3600; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
  } 
  if (key == '4') // restart
  {
    roadNetwork.clearRoads();
    agentHandler.activeCars.clear();
    globalTime = 12*3600; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
  } 
  if (key == '5') // restart
  {
    roadNetwork.clearRoads();
    agentHandler.activeCars.clear();
    globalTime = 14*3600; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
  } 
  if (key == '6') // restart
  {
    roadNetwork.clearRoads();
    agentHandler.activeCars.clear();
    globalTime = 16*3600; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
  } 
  if (key == '7') // restart
  {
    roadNetwork.clearRoads();
    agentHandler.activeCars.clear();
    globalTime = 18*3600; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
  } 
  if (key == '8') // restart
  {
    roadNetwork.clearRoads();
    agentHandler.activeCars.clear();
    globalTime = 20*3600; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
  } 
  if (key == '9') // restart
  {
    roadNetwork.clearRoads();
    agentHandler.activeCars.clear();
    globalTime = 22*3600; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
  } 
//  if (key == '2') // restart
//  {
//    println("[QueueingModel] in 2");
////    hurrCat = 1;
//    agentHandler.start7am();
////    backgroundHandler.residueRoad.clear();
////    backgroundHandler.residueOpacity.clear();
////    backgroundHandler.residueColor.clear();
////    globalTime = 0; 
//    prevResidueTime = globalTime;
//    initialized = false;
//    pause = false;
////    emptymodel = false;
//  } 
//  if (key == '3') // restart
//  {
//    println("[QueueingModel] in 3");
////    hurrCat = 3;
////    roadNetwork.clearRoads();
//    agentHandler.start8am();
////    backgroundHandler.residueRoad.clear();
////    backgroundHandler.residueOpacity.clear();
////    backgroundHandler.residueColor.clear();
////    globalTime = 0; 
//    prevResidueTime = globalTime;
//    initialized = false;
//    pause = false;
////    emptymodel = false;
//  } 
//  if (key == '4') // restart
//  {
//    println("[QueueingModel] in 4");
////    hurrCat = 1;
////    roadNetwork.clearRoads();
//    agentHandler.start9am();
////    backgroundHandler.residueRoad.clear();
////    backgroundHandler.residueOpacity.clear();
////    backgroundHandler.residueColor.clear();
////    globalTime = 0; 
//    prevResidueTime = globalTime;
//    initialized = false;
//    pause = false;
////    emptymodel = false;
//  } 
  if (key == 'f') // print the framerate
  {
    // Toggle printing out the framerate
    showFrameRate = !showFrameRate;
  } else if (key == 'd')
  {
    // To step through draw if no loop
    draw();
  } else if (key == 't') // testing
  {
//    testCar.restart();
//    globalTime = 0;
  } else if (key == 'T') // testing
  {
//    println(testCar.totalTime);
  } else if (key == 'y')
  {
//    println("[QueueingModel] time left on road: " + testCar.timeRemaining);
  }
  else if (key == 'p') // print time elapsed
  {
    println("[QueueingModel] global time (min): " + globalTime/60 + " pause: " + pause);
  }
  // Zoom
  else if (key == '+')
  {
    if (viewDistanceWidth > edgeDistanceOriginalWidth/10)
    {
      viewDistanceWidth *= 0.75;
      viewDistanceHeight *= 0.75;
      initialized = false;
    }
  }
  else if (key == '-')
  {
    if (viewDistanceWidth < edgeDistanceOriginalWidth)
    {
      viewDistanceWidth *= 1.33;
      viewDistanceHeight *= 1.33;
      // Don't zoom out past original size
      if (viewDistanceWidth > edgeDistanceOriginalWidth)
      {
        viewDistanceWidth = edgeDistanceOriginalWidth;
        viewDistanceHeight = edgeDistanceOriginalHeight;
        viewCenter = centerOriginal;
      }
      initialized = false;
    }
  }
  // Recenter
  else if (key == 'c')
  {
    viewCenter = centerOriginal;
    initialized = false;
  }
  // Pan
  if (key == CODED && keyCode == RIGHT)
  {
    viewCenter = MercatorMap.endpoint(viewCenter, viewDistanceWidth/75, 90);
    initialized = false;
  }
  if (key == CODED && keyCode == LEFT)
  {
    viewCenter = MercatorMap.endpoint(viewCenter, viewDistanceWidth/75, 270);
    initialized = false;
  }
  if (key == CODED && keyCode == UP)
  {
    viewCenter = MercatorMap.endpoint(viewCenter, viewDistanceWidth/75, 0);
    initialized = false;
  }
  if (key == CODED && keyCode == DOWN)
  {
    viewCenter = MercatorMap.endpoint(viewCenter, viewDistanceWidth/75, 180);
    initialized = false;
  }
  if (key == ' ')
  {
    pause = !pause;
    prevTime = millis();
  }

}


