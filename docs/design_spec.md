## Design Specification

Units of Measure  | meters, seconds
------------- | -------------
Airspace Entry coordinates | x=16000, y = 47000
Length of standard descent trajectory | 65291 m
Landing speed | 70 m/sec
Entry speed (normal) | 128 m/s
Entry altitude | 10000 m
Final Approach starting point coordinates | x=0, y=0
Final Approach length | 15021 m
Final Approach starting altitude | 800 m
Final Approach duration | 58 s
Descent speed max | 128 m/s
Descent speed min | 105 m/s
Minimum distance between aircrafts | 5200 m
Entry speed range | 120 – 130 m/s

* Trajectory equations describe X, Y as functions of the distance flown from the point of entry:
 * X = 2.8E-11 * distance^3 - 6.4E-6 * distance^2+0.048 * distance + 16000
 * Y = 2.48E-14 * distance^4 - 2.5E-9 * distance^3 + 1.09E-4 * distance^2 - 0.4019 * distance + 47000
* Flight statuses “descent”, “final_approach”, “landed”, “diverted”
* Expected output in JSON format:

 ```
{
  "aircrafts":[
    {"flight":"AA876, "x":4200, “y”: 23004, “altitude”: 8000, “status”: “descent”},
    {"flight":"DL234, "x":8200, “y”: 1000, “altitude”: 8000, “status”: “final_approach”},
    {"flight":"AF133, "x":0, “y”: 15000, “altitude”: 8000, “status”: “landed”},
  ]
}
 ```
