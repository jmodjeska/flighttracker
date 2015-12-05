# <img src="https://github.com/jmodjeska/flighttracker/blob/master/docs/images/plane.png" width=50px> FlightTracker
Air traffic control simulator project for my Ruby class. Calculates X, Y coordinates and altitude for incoming flights; regulates descent speed and diversions; and tracks planes in flight with a web interface.

<div style="text-align:center">
<img src="https://github.com/jmodjeska/flighttracker/blob/master/docs/images/tracker_screenshot.png" width=900px>
<img src="https://github.com/jmodjeska/flighttracker/blob/master/docs/images/plane_info_screenshot.png" width=400px>
</div>

## Installation
```
bundle install
```

## Usage
Start the webserver:
```
cd lib/controllers
ruby server.rb
```
Start the flight simulator:
```
cd lib
ruby simulator.rb realtime
```

#### JSON methods
* The flight simulator will submit flights at random in the format `http://localhost:8080/entry?flight=YY1234`. The `entry` endpoint is also exposed for ad hoc flight submission. The server will respond with JSON indicating your flight was accepted or diverted, based on current air traffic.
* The server reports tracking info upon request at `http://localhost:8080/tracking_info`. Include the optional `?timeframe` param to specify how many seconds of history you want to see.

#### Web interface
Browse to [http://localhost:8080/](http://localhost:8080/) to view the web interface.

## Project Description
Build a web service that provides tracking service to subscribers.
* It contains a properly operating simulator that simulates flights entering SeaTac airspace;
* It has a method that takes requests for registration of an aircraft entering the airspace, and makes registration records in the application database;
* It has a method that responds to requests for traffic information, returning data on all registered flights as indicated in the design specification;
* Its responses should contain data on flight names, coordinates (X, Y as relative to the Final Approach start point), its speed and altitude;
*  It has a Web server that responds to external HTTP GET requests with the specified data, and accepts HTTP GET calls to register aircrafts entering the airspace.

See the [docs](https://github.com/jmodjeska/flighttracker/tree/master/docs) for further details.
