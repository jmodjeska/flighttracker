# <img src="https://github.com/jmodjeska/flighttracker/blob/master/docs/images/plane.png" width=50px> FlightTracker
Air traffic control simulator project for my Ruby class.

## Project Description
Build a web service that provides tracking service to subscribers. 
* It contains a properly operating simulator that simulates flights entering SeaTac airspace;
* It has a method that takes requests for registration of an aircraft entering the airspace, and makes registration records in the application database;
* It has a method that responds to requests for traffic information, returning data on all registered flights as indicated in the design specification;
* Its responses should contain data on flight names, coordinates (X, Y as relative to the Final Approach start point), its speed and altitude;
*  It has a Web server that responds to external HTTP GET requests with the specified data, and accepts HTTP GET calls to register aircrafts entering the airspace.

See the [docs](https://github.com/jmodjeska/flighttracker/tree/master/docs) for further details.
