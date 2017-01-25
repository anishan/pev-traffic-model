# City Traffic Model
A visualization of traffic in Kendall square based on traffic count data at specific locations. Routing and traffic congestion are modelled using queueing theory. This project can also model bicycles.

### Context
Traffic has a significant effect on people's lives. People spend a lot of time each day to commuting to work, time that could be spent more productively with better planning. Cars also produce carbon dioxide, which adds to air pollution and has health effects. Therefore, it is important to understand the impact of behavioral changes or new infrastructure developments.This project models city traffic in order to make more informed decisions about adding housing or commercial units.

This model simulates city traffic over the course of a day. This implementation looks specifically at the Kendall Square area, and models cars and bikes based on routes between home and work. Navigation is performed with Dijkstra’s algorithm, adapted to optimize for time and safe biking routes. Traffic congestion is modeling using queueing theory. Over the course of a simulation, a heat map gets built up to visually indicate areas of congestion.

![Traffic simulation gif](https://github.com/anishan/pev-traffic-model/blob/master/images/agentsgif.gif "Traffic during morning rush hour")

This visualization shows roads in blue, with cars (white) and bikes (green) moving along the roads over time. The time of day is indicated in the lower right corner. The lighter dots in the background show homes (white) and places of work (orange), which serve as the origin and destination pairs of the agents.

### Testing Interventions
This model provides a simulation with baseline conditions for traffic from people commuting to and from work. These baseline conditions can be modified to test the effect of different interventions. For example, it is possible to change the relative percentage of people who commute by bicycle or public transit.  The model can also be used to see the effect of building a new housing development or a new office building.

For each of these interventions, it is possible to compare the effect they will have on traffic congestion. As the simulation runs, it creates a heat map of congestion on roads. Red and opaque color indicate areas of higher congestion. 

By comparing the relative congestion maps, it is possible to see how different interventions will affect the relative congestion in the area.

## Implementation
### Data
The data for the trips between home and work were from the American Community Survey. One of the data sets provides information about where people live and work, based on the census block locations. Since census blocks have fairly high resolution in cities, all the people in a given block were assumed to start from the center of the block polygon.

The road data was taken from open street maps, using the speed limit and number of lanes for each road. For the bike navigation, bike routes were also weighted to favor roads with bike lanes or separate bike paths.

### Queueing Model
In this model, traffic was modeling using queueing theory, which describes waiting in line. In this case, roads are represented as a queue of cars. Cars “get in line” at the end of the road, and move forward by advancing their position in the queue. When cars get to the front of the line, they can move on to the next road. The steps are shown in the image below.

![Queueing theory steps in model](https://github.com/anishan/pev-traffic-model/blob/master/images/queueingtheory.jpg "Queueing model steps")

This inherently models congestion, because cars can only move on to other roads after all the cars in front of them have moved. Once a road reaches capacity, it no longer accepts cars from the surrounding roads. Therefore, cars are forced to remain on adjacent roads, which spreads congestion around a region.

### Class Structure
A brief overview of the classes in this model are given here:

**QueueingModel**: This is the main control class for the model, which instantiates all the other classes and contains the main control loop.
AgentHandler: This class creates agents based on where they live and work. This class also controls the agents’ mode of transportation and time of travel, based on the statistical distributions for both of these.

**Car**: Each car object represents one agent, and each object stores that individual’s origin, destination, and route.

**Bike**: Similar to the Car class, each bike stores information about the route, but has some behavior specific to bicycles.

**Pathplanner**: Each Car and Bike object stores their route, which is calculated with the Pathplanner class using Dijkstra’s algorithm. This is its own class so that previously calculated routes can be cached to save computation time.

**RoadNetwork**: The road network class stores information about all the road in the model. It is represented as a graph, where the roads are the edges, connected by links.

**Node**: Used by the RoadNetwork class, the nodes are used to connect roads and store information about which roads are linked together.

**Road**: Each road object represents road segment. This class controls the main implementation of queueing theory, by keeping track of the list of cars on the road and the waitlist of cars waiting to enter the road. In every time step, the road evaluates which cars can continue on. The road also stores a separate list of bikes because car congestion does note effect bikes, and vice versa.

**MercatorMap**: This class contains the functions that transform the latitude and longitude points into screen locations, so they can be visualized. It also performs relevant distance calculations.

### Limitations and Future Work
This model abstracts out some of the details of city traffic behavior, in order to be more computationally efficient. However, this means that the model is less accurate at smaller scales. For more accurate results, the model should be modified to include behavior form traffic lights and traffic laws.

It is also important to note that the data for this model only includes trips between home and work as reported to the American Community Survey. Therefore, it does not include the effect of other types of travel.

In the future, this model could be extended to analyze other developments of other types of behavioral changes. This model can also be applied to other cities by changing the data sources. 


### How to run
Download Processing 2.2.1 from [processing.org] (processing.org). Open the QueueingModel.pde script in processing and click run. You may need to wait briefly as the data loads.

---
Anisha Nakagawa  
MIT Media Lab, Changing Places group  
Advisor: Ira Winder  
Fall 2016