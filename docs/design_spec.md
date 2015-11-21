## Design Specification

1. Develop FlightTracker application that registers every aircraft that enters the SeaTac airspace. FlightTracker is a web service. It receives service requests through its URL as HTTP GET calls.
1. The service requests come in two flavors:
 * Airplane entry (e.g. http://<your_service_ip>/entry?flight=DL342&altitude=12000). This request comes when a new airplane enters the Seattle airspace. The following information comes with this request:
    * Flight number (e.g. DL342)
    * Altitude in meters (e.g. 12000)
    * The time when receives the request is entered as the Time of Entry (TOE)
 * Flight tracking request (e.g. http://<your_service_ip>/tracking_info)
1. FlightTracker service returns information on all airborne flights plus flights landed in the last 2 minutes
1. For each aircraft it should calculate x, y position in relation to the Final Approach starting point (coordinates x=0, y = 0)
   <img src="https://raw.githubusercontent.com/jmodjeska/flighttracker/master/docs/images/trajectory.png" width=500px>
1. When receiving data on a new flight entering the airspace, FlightTracker has to check whether at the given speed this aircraft will always be at least 30 seconds behind the previous flight. If this condition cannot be met, this aircraft shall be diverted and removed from the arriving traffic.
1. Trajectory equations describe X, Y as functions of the distance flown from the point of entry:
 * X = `2.8E-11 * distance^3 - 6.4E-6 * distance^2+0.048 * distance + 16000`
 * Y = `2.48E-14 * distance^4 - 2.5E-9 * distance^3 + 1.09E-4 * distance^2 - 0.4019 * distance + 47000`
1. Flight statuses “descent”, “final_approach”, “landed”, “diverted”
1. Aircrafts enter the airspace at the speed in the range of 120 – 130 m/s. Their descent speed should be adjusted as needed to ensure that at no time aircrafts are closer than 5200 m to each other. The allowable speed range is 105 – 128 m/s.
1. Expected output in JSON format: 

 ```
 {
   "aircrafts":[
     {"flight":"AA876, "x":4200, “y”: 23004, “altitude”: 8000, “status”: “descent”},
     {"flight":"DL234, "x":8200, “y”: 1000, “altitude”: 8000, “status”: “final_approach”},
     {"flight":"AF133, "x":0, “y”: 15000, “altitude”: 8000, “status”: “landed”},
    ]
 }
 ```
