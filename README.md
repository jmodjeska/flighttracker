# <img src="https://github.com/jmodjeska/flighttracker/blob/master/docs/images/plane.png" width=50px> FlightTracker
Air traffic control simulator project for my Ruby class.

## Project Description
This project is aimed at building a web service that provides tracking service to subscribers. 
* It contains a properly operating simulator that simulates flights entering SeaTac airspace
* It has a method that takes request for registration of an aircraft entering the airspace and makes registration records in the application database
* It has a method that responds to request for traffic information, returning data on all registered flights as indicated in the design specification
* The FlighTracker response should contain data on flight name, coordinates (X, Y as relative to the Final Approach Start point), its speed and altitude.
*  Web server that responds to external HTTP requests (GET) with the data as shown above and accepts HTTP GET calls to register aircrafts entering the airspace
* See the [docs](https://github.com/jmodjeska/flighttracker/tree/master/docs) for further details
