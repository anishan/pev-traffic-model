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

PVector viewCenter = centerOriginal;
float viewDistanceWidth = edgeDistanceOriginalWidth;
float viewDistanceHeight = edgeDistanceOriginalHeight;

boolean showFrameRate = false;
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
// nodes within specified number of meters will be combined
int simplification = 5;

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

      backgroundHandler.createRoads(mercatorMap);
      backgroundHandler.createResidue(mercatorMap);
      
      agentsPGraphic = createGraphics(width, height);
      initialized = true;
      prevTime = millis();
      
//      agentHandler.startCars();
    }
    
    agentHandler.controlCars(globalTime);
  
    // Only adds residue to the graph every 10 minutes (simulation time)
    addResidue = globalTime > prevResidueTime + 10*60; // every 10 min
    float currentTime = millis();
    if (!pause)
    {  
      // Take step
      for (int i = 0; i < roadNetwork.roads.size (); i++)
      {
        
        Road r = roadNetwork.roads.get(i);
        r.moveBikes((currentTime-prevTime)*timeStep/3);
        r.moveCars((currentTime-prevTime)*timeStep/3);
        
        // Draw residue
        if (addResidue && (r.cars.size() > r.capacity*0.25))// && r.waitlist.size() > 5) // for congested roads
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
        r.bikes.get(i).drawBike(mercatorMap, agentsPGraphic);
      }
      for (int i = r.cars.size() -1; i >=0; i--)
      {
        emptyModel = false;
        // Draw car
        r.cars.get(i).drawCar(mercatorMap, agentsPGraphic);      
      }      
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
    
    agentsPGraphic.endDraw();
    
    // Draw PGraphic
    backgroundHandler.drawAll(mercatorMap);   
    image(agentsPGraphic, 0, 0, width, height);
    
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
    roadNetwork.clearRoads();
    globalTime = 0; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
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
    agentHandler.activeBikes.clear();
    globalTime = 6*3600; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
  } 
  if (key == '2') // restart
  {
    roadNetwork.clearRoads();
    agentHandler.activeCars.clear();
    agentHandler.activeBikes.clear();
    globalTime = 8*3600; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
  } 
  if (key == '3') // restart
  {
    roadNetwork.clearRoads();
    agentHandler.activeCars.clear();
    agentHandler.activeBikes.clear();
    globalTime = 10*3600; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
  } 
  if (key == '4') // restart
  {
    roadNetwork.clearRoads();
    agentHandler.activeCars.clear();
    agentHandler.activeBikes.clear();
    globalTime = 12*3600; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
  } 
  if (key == '5') // restart
  {
    roadNetwork.clearRoads();
    agentHandler.activeCars.clear();
    agentHandler.activeBikes.clear();
    globalTime = 14*3600; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
  } 
  if (key == '6') // restart
  {
    roadNetwork.clearRoads();
    agentHandler.activeCars.clear();
    agentHandler.activeBikes.clear();
    globalTime = 16*3600; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
  } 
  if (key == '7') // restart
  {
    roadNetwork.clearRoads();
    agentHandler.activeCars.clear();
    agentHandler.activeBikes.clear();
    globalTime = 18*3600; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
  } 
  if (key == '8') // restart
  {
    roadNetwork.clearRoads();
    agentHandler.activeCars.clear();
    agentHandler.activeBikes.clear();
    globalTime = 20*3600; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
  } 
  if (key == '9') // restart
  {
    roadNetwork.clearRoads();
    agentHandler.activeCars.clear();
    agentHandler.activeBikes.clear();
    globalTime = 22*3600; 
    prevResidueTime = globalTime;
    initialized = false;
    pause = false;
  } 
  if (key == 'f') // print the framerate
  {
    // Toggle printing out the framerate
    showFrameRate = !showFrameRate;
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


