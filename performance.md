➜  http_load-09Mar2016 boom http://genius.internal.worksap.com -c 10000 -n 100000


-------- Results --------
Successful calls		55655
Total time        		407.1786 s
Average           		49.3297 s
Fastest           		18.0385 s
Slowest           		58.3390 s
Amplitude         		40.3005 s
Standard deviation		7.806260
RPS               		136
BSI              		Pretty good

-------- Status codes --------
Code 200          		53597 times.
Code 500          		2058 times.

-------- Legend --------
RPS: Request Per Second
BSI: Boom Speed Index


➜  http_load-09Mar2016 boom http://genius.internal.worksap.com -c 100 -n 1000
Server Software: nginx/1.10.0 (Ubuntu)
Running GET http://172.26.138.181:80
	Host: genius.internal.worksap.com
Running 1000 queries - concurrency 100
[================================================================>.] 99% Done

-------- Results --------
Successful calls		1000
Total time        		4.6282 s
Average           		0.4219 s
Fastest           		0.1918 s
Slowest           		0.6154 s
Amplitude         		0.4236 s
Standard deviation		0.093329
RPS               		216
BSI              		Pretty good

-------- Status codes --------
Code 200          		1000 times.

-------- Legend --------
RPS: Request Per Second
BSI: Boom Speed Index


➜  http_load-09Mar2016 boom http://genius.internal.worksap.com -c 1000 -n 10000
Server Software: nginx/1.10.0 (Ubuntu)
Running GET http://172.26.138.181:80
	Host: genius.internal.worksap.com
Running 10000 queries - concurrency 1000
[=================================================================>] 100% Done

-------- Results --------
Successful calls		10000
Total time        		43.2174 s
Average           		4.1037 s
Fastest           		2.1989 s
Slowest           		4.7117 s
Amplitude         		2.5128 s
Standard deviation		0.446504
RPS               		231
BSI              		Pretty good

-------- Status codes --------
Code 200          		9964 times.
Code 500          		36 times.

-------- Legend --------
RPS: Request Per Second
BSI: Boom Speed Index

check status
/rails/info/properties
/rails/info/routes
/sidekiq

