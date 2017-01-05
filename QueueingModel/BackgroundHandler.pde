/*
* Class to control all the things drawn in the background
 */
public class BackgroundHandler
{
  Table massTable;
  RoadNetwork roadNetwork;
  AgentHandler agentHandler;
  ArrayList<PShape> massOutline = new ArrayList<PShape>();
  PGraphics roadPGraphic;
  PGraphics popCentersPGraphic;
  ArrayList<PVector> residueLatLon = new ArrayList<PVector>();
  ArrayList<Float> residueOpacity = new ArrayList<Float>();
  ArrayList<Float> residueColor = new ArrayList<Float>(); // only storing g value
  ArrayList<Road> residueRoad = new ArrayList<Road>();
  PGraphics residuePGraphic;
  PGraphics textPGraphic;
  int prevTime;

  public BackgroundHandler(Table massOutlineTable, RoadNetwork roads, AgentHandler agents)
  {
    massTable = massOutlineTable;
    roadNetwork = roads;
    agentHandler = agents;
    prevTime = 0;
    residuePGraphic = createGraphics(width, height);
  }


  // Fill in Massachusetts and surrounding states, with Massachuseets slightly emphasized
  // Read in and process csv
  public void createMassOutline(MercatorMap mercatorMap)
  {
    massOutline.clear();
    PShape s = new PShape();
    s = createShape();
    s.beginShape();
    s.fill(#004560);
    s.noStroke();
    float x = massTable.getRow(0).getFloat("x");
    float y = massTable.getRow(0).getFloat("y");
    PVector point = mercatorMap.getScreenLocation(new PVector(x, y));
    s.vertex(point.x, point.y);

    // Read from csv
    for (int i = 1; i < massTable.getRowCount (); i++) 
    {
      // String because sometimes the shapeid is a float or int
      int shapeidMass = massTable.getRow(i).getInt("shapeid");
      String shapeid = massTable.getRow(i).getString("shapeid");

      if (shapeidMass == 0)
      {
        s.fill(#00aaff, 75); // Color MA a little more visibly
      } else
      {
        s.fill(#00aaff, 50);
      }

      x = massTable.getRow(i).getFloat("x");
      y = massTable.getRow(i).getFloat("y");

      // Add the point to the shapefile polygon
      if (shapeid.equals(massTable.getRow(i-1).getString("shapeid")) == true) // Check that the two shapeids are equal
      {
        point = mercatorMap.getScreenLocation(new PVector(x, y));
        s.vertex(point.x, point.y);
      } else
      {
        s.endShape(CLOSE);
        massOutline.add(s); // Add the shape to an arraylist to be drawn
        s = createShape();
        s.beginShape();
        s.fill(#004560);
        s.noStroke();
        s.beginShape();
        point = mercatorMap.getScreenLocation(new PVector(x, y));
        s.vertex(point.x, point.y);
      }
    }
    s.endShape(CLOSE);
    massOutline.add(s);
  }

  // Draw the roads onto a pgraphic, and save it
  // These will not change over time
  public void createRoads(MercatorMap mercatorMap)
  {
    roadPGraphic = createGraphics(width, height);
    roadPGraphic.beginDraw();

    for (int i = 0; i < roadNetwork.roads.size (); i++)
    {
      Road r = roadNetwork.roads.get(i);
      r.drawRoadPGraphic(mercatorMap, roadPGraphic, #00aaff, 255, 1);
    }

    roadPGraphic.endDraw();
  }

  // Add residue from congested roads
  // Ever time this function is called from the main loop,
  // it increases the opacity and makes the color of the road more red
  // Roads start at color(255, 240, 55), alpha = 0
  // ends at color(255, 75, 55), alpha = 255
  // Get to this point after 120 steps (or updated every 10 minutes for 20 hours)
  public void addResidue(Road r)
  {
    // If the road is already in the list, then update the color
    if (residueRoad.contains(r))
    {
      int index = residueRoad.indexOf(r);
      float prevOpacity = residueOpacity.remove(index);
      residueOpacity.add(index, prevOpacity+2.125); // Increase opacity
      float prevG = residueColor.remove(index); // Change color
      if (prevG > 75)
      {
        residueColor.add(index, prevG-1.375);
      }
      else 
      {
        residueColor.add(index, prevG);
      }
    } else // otherwise, add the road to the list
    {
      residueRoad.add(r);
      residueOpacity.add(2.125);
      residueColor.add(240.0);
    }
  }

  // Converts the residue from lists to locations on pgraphics
  public void createResidue(MercatorMap mercatorMap)
  {
    residuePGraphic.clear();
    residuePGraphic.beginDraw();

    for (int i = 0; i < residueRoad.size (); i++)
    {
      Road r = residueRoad.get(i);
      r.drawRoadPGraphic(mercatorMap, residuePGraphic, color(255, residueColor.get(i), 55), int(residueOpacity.get(i)), 10);
    }

    residuePGraphic.endDraw();
  }


  // Draws all the background pgraphics, in order
  public void drawAll(MercatorMap mercatorMap)
  {
    background(#003345);

    // Draw state boundaries
    for (PShape s : massOutline)
    {
      shape(s);
    }

    // Draw roads
    image(roadPGraphic, 0, 0, width, height);
  }
  
 
}

