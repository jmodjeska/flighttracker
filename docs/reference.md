# Reference

Units of Measure  | meters, seconds
:------------- | :-------------
Airspace Entry coordinates | x = 16000, y = 47000
Length of standard descent trajectory | 65291 m
Landing speed | 70 m/sec
Entry speed (normal) | 128 m/s
Entry altitude | 10000 m
Final Approach starting point coordinates | x = 0, y = 0
Final Approach length | 15021 m
Final Approach starting altitude | 800 m
Final Approach duration | 600.8 s
Descent speed max | 128 m/s
Descent speed min | 105 m/s
Minimum distance between aircrafts | 5200 m
Entry speed range | 120 – 130 m/s

* The time to arrival (TTA), i.e., time from Entry to Landing is as follows:
 * TTA = Time_ingress + Time_descent + Time_final_approach
 * Time of Ingress is the time at the moment when the browser makes HTTP request to register a new flight
 * Time of descent is the time required for the aircraft to pass the trajectory from Ingress to Final Approach Start point. This time is
Length_of_Descent / Aircraft_speed = 64640 (m) /128 (m/sec) = 505 sec. For the sake of simplicity, we assume that the speed stays unchanged for the entire duration of the descent.
* Altitude at all descent points is 10000 – elapsed_time * 9200 / descent_duration = 1000 – elapsed_time * 9200/505
