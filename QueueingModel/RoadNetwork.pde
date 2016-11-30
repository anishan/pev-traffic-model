/*
* Class for the graph of the roads and edges
* Stores graph information as a list of nodes and roads (edges)
*/

public class RoadNetwork
{
  
  ArrayList<Road> roads = new ArrayList<Road>();
  ArrayList<Node> nodes = new ArrayList<Node>();
  
  public RoadNetwork(Table roadTable, Table roadAttrTable, int carsPerAgent, int simplification)
  {

    boolean nodeExists;
    
    // Create first node outside of loop because this does not have to check for previous duplicate nodes
    // Also, the for loop later needs to check that the previous node has the same shapeid,
    // so create the first node here to prevent indexing errors
    Node tempNode = new Node(roadTable.getRow(0).getFloat("x"), roadTable.getRow(0).getFloat("y"));
    nodes.add(tempNode);
    Node prevNode = tempNode;
    
    // Print progress of proccessing table, formatted nicely
    print("[RoadNetwork] progress: 0%");
    for (int i = 0; i < 20 - 5; i++)
    {
      print(" ");
    }
    println("100%");
    print("[RoadNetwork] progress: ");
    
    // Loop through all rows of the csv to make roads and nodes
    // Start from 1 because we need to compare to the previous node, so starting frmo 0 would give errors
    for (int i = 1; i < roadTable.getRowCount(); i++) 
//    for (int i = 1; i < 85; i++) 
    {
      
      if (i%(roadTable.getRowCount()/20) == 0)
      {
        print("-");
      }
      
      // String because sometimes the shapeid is a float or int
      String shapeid = roadTable.getRow(i).getString("shapeid");
      
      // Coordinates of current endpoint
      float x = roadTable.getRow(i).getFloat("x");
      float y = roadTable.getRow(i).getFloat("y");
      
      // Make sure no duplicate nodes
      nodeExists = false;
      for (Node n: nodes)
      {
        // Using closeTo() instead of equals() in order to simplify the graph
        if (n.closeTo(x, y, simplification))
        {
          nodeExists = true;
          tempNode = n;
          break;
        }
      }
       
      // If the node doesn't already exist, make a new object and add it to the list
      if (!nodeExists)
      {
        tempNode = new Node(x, y);
        nodes.add(tempNode);
      }
      
      // If the current endpoint is part of the same shape as the previous endpoint,
      // then create a road object between the two points
      if (shapeid.equals(roadTable.getRow(i-1).getString("shapeid")) == true) // Check that the two shapeids are equal
      {
        
        // Make PVectors for the endpoints of the road, from this row and the prev data row
        PVector start = new PVector(roadTable.getRow(i).getFloat("x"), roadTable.getRow(i).getFloat("y"));
        PVector end = new PVector(roadTable.getRow(i-1).getFloat("x"), roadTable.getRow(i-1).getFloat("y"));
        String otherTags = roadAttrTable.findRow(shapeid + "", "shapeid").getString("other_tags");
//        println("[RoadNetwork] otherTags: " + otherTags);
        int speedLimitIndex = otherTags.indexOf("mph");
        int speedLimit = 0;
        if (speedLimitIndex >-1)
        {
          speedLimit = int(float(otherTags.substring(speedLimitIndex-3, speedLimitIndex-1))*0.44704);
//          println("[RoadNetwork] speedlimitindex: " + speedLimitIndex + " speed limit: " + speedLimit); 
        }
        
//        int speedLimit = 15;//for bikes //roadAttrTable.findRow(shapeid + "", "shapeid").getInt("SPEEDLIMIT");
//        speedLimit = int(speedLimit * 0.44704); // to convert to m/s
//        // To make up for gaps in the data
//        if (speedLimit == 0)
//        {
//          speedLimit = 15;
//        }
        int numLanes = 1;// for bikes //roadAttrTable.findRow(shapeid + "", "shapeid").getInt("NUMBEROFTR");
        
        
        
        
        
        // Restrict access to cars or bikes
        String highwayType = roadAttrTable.findRow(shapeid + "", "shapeid").getString("highway");
//        String otherTags = roadAttrTable.findRow(shapeid + "", "shapeid").getString("other_tags");
//        String  = roadAttrTable.findRow(shapeid + "", "shapeid").getString("highway");
        boolean carsAllowed = true;
        boolean bikesAllowed = true;
        if (highwayType.equals("cycleway") || highwayType.equals("footway") || highwayType.equals("steps") || highwayType.equals("bus_guideway") || highwayType.equals("bridleway") || otherTags.contains("railway"))
        {
//          println("[RoadNetwork] highway type: " + highwayType);
          carsAllowed = false;
        }
        if (highwayType.equals("footway") || highwayType.equals("steps") || highwayType.equals("bus_guideway") || highwayType.equals("bridleway") || otherTags.contains("railway"))
        {
//          println("[RoadNetwork] " + highwayType + " " + otherTags);
          bikesAllowed = false;
        }
        else if (otherTags.contains("bicycle\"=>\"no"))
        {
//          println("[RoadNetwork] otherTags: " + otherTags);
          bikesAllowed = false;
        }
        
        // Bicycle road weighting
        // Best for bikes
        float bikeWeighting = 1;
        if (highwayType.equals("cycleway") || otherTags.contains("cycleway\"=>\"track") || otherTags.contains("cycleway\"=>\"opposite_track"))
        {
//          println("[RoadNetwork] " + highwayType + " " + otherTags);
          bikeWeighting = 0.7;
        }
        else if (otherTags.contains("cycleway\"=>\"lane") || otherTags.contains("cycleway:left") || otherTags.contains("cycleway:right") || otherTags.contains("cycleway\"=>\"opposite"))
        {
          bikeWeighting = 0.8;
        }
        else if (otherTags.contains("cycleway\"=>\"shared_lane"))
        {
          bikeWeighting = 0.9;
        }
        
        
        if (otherTags.contains("oneway\"=>\"yes"))// oneway forward
        {
          Road newRoad = new Road(prevNode, tempNode, speedLimit, numLanes, carsPerAgent, carsAllowed, bikesAllowed, bikeWeighting);//last and 2nd to last nodes
          roads.add(newRoad);
          
          tempNode.adjRoads.add(newRoad);
          prevNode.adjRoads.add(newRoad);
        }
        else if (otherTags.contains("oneway\"=>\"-1"))// oneway backwards
        {
          Road newRoad2 = new Road(tempNode, prevNode, speedLimit, numLanes, carsPerAgent, carsAllowed, bikesAllowed, bikeWeighting);//last and 2nd to last nodes
          roads.add(newRoad2);
          
          tempNode.adjRoads.add(newRoad2);
          prevNode.adjRoads.add(newRoad2);
        }
        else // two-way
        {
          // Create a new road object
          Road newRoad = new Road(tempNode, prevNode, speedLimit, numLanes, carsPerAgent, carsAllowed, bikesAllowed, bikeWeighting);//last and 2nd to last nodes
          roads.add(newRoad);
          // TODO only make two roads if both directions
          Road newRoad2 = new Road(prevNode, tempNode, speedLimit, numLanes, carsPerAgent, carsAllowed, bikesAllowed, bikeWeighting);//last and 2nd to last nodes
          roads.add(newRoad2);
          
          // Give the endpoint nodes access to which roads they are connected to
          tempNode.adjRoads.add(newRoad);
          prevNode.adjRoads.add(newRoad);
          tempNode.adjRoads.add(newRoad2);
          prevNode.adjRoads.add(newRoad2);
        }
        
        
        
        
        
        
        
      }
      prevNode = tempNode;
    }    
    
    // Give nodes info about adjacent nodes
    for (int i = 0; i < nodes.size(); i++)
    {
      nodes.get(i).calcAdjNodes();
//    }
    }
    println();
    println("[RoadNetwork] Finished making road network");
  }
  
  
  public ArrayList<Road> getRoads()
  {
    return this.roads;
  }
  
  // Gets node closest to the given lat lon points
  public Node getClosestNode(float lat, float lon)
  {
    PVector currentLoc = new PVector(lat, lon);
    float closestDistance = MercatorMap.latlonToDistance(nodes.get(0).node, currentLoc);
    int closestNodeIndex = 0;
    float currDistance;
    for (int i = 0; i < nodes.size(); i++)
    {
      currDistance = MercatorMap.latlonToDistance(nodes.get(i).node, currentLoc);
      if (currDistance < closestDistance)
      {
        closestDistance = currDistance;
        closestNodeIndex = i;
      }
    }
    return nodes.get(closestNodeIndex);
  }
  
  // For a given node, finds its index in this.nodes list
//  public int getIndex(Node node)
//  {
//    for (int i = 0; i < nodes.size(); i++)
//    {
//      if (nodes.get(i).equals(node))
//      {
//        return i;
//      }
//    }
//    return -1;
//  }
  
  // Removes all cars from all roads and waitlists
  public void clearRoads()
  {
    for (int i = 0; i < roads.size(); i++)
    {
      roads.get(i).cars.clear();
      roads.get(i).waitlist.clear();
      roads.get(i).bikes.clear();
      roads.get(i).waitlistBike.clear();
    }
    
  }
  
}



