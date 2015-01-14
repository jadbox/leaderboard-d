**Clone, get dependencies and run:**  
```
git clone git@github.com:jadbox/leaderboard-d.git 
cd leaderboard-d  
dub  
```
  
**Test case:**  
With [HTTPie](https://github.com/jakubroztocil/httpie), run the client test script: [./test.sh](https://github.com/jadbox/leaderboard-d/blob/master/test.sh)
  
**Notes:**  
* Registering a new user only requires a name, as a playerID will be generated.
  * Example: ```http POST localhost:3000 name=Don event:=1```  
  * Reponse: ```{
    "name": "Don", 
    "playerID": 1, 
    "status": "Success: registered player"
    }```
* Deleting users, requires event id 5:
  * Example: ```http DELETE localhost:3000 playerID="1" event = 5``` 
  * Reponse: ```{
    "playerID": 1, 
    "status": "Success: deleted player"
}```
* All event actions use the (form) POST HTTP method
* New event ID route handlers can be added in the app.d file
* Server port is 3000 by default
  
_See project files for documentation._
