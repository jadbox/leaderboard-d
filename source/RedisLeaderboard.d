module RedisLeaderboard;
import tinyredis.redis;
import vibe.d;
import std.algorithm;

class RedisLeaderboard
{
	Redis redis;
	static string PLAYERS = "player:";
	static string UID = "uniqueID";
	static string TSCORES = "scores_list";
	static string S = " ";

	this(Redis redis = new Redis("localhost", 6379))
	{
		this.redis = redis;
		// Constructor code
	}
	
	Json register(FormFields form)
	{
		enforceHTTP("name" in form, HTTPStatus.badRequest, "Missing name field.");
	
		auto id = redis.send!(string)("INCR", "uniqueID");
		// Create the transaction to register the player into the scoreboard list and create player object
		redis.transaction([
				"HSET " ~ PLAYERS ~ id ~ " name " ~ form["name"], 
				"ZADD " ~ TSCORES ~ " 0 " ~ id
		]);

		auto res = Json.emptyObject;
		res.status = "Success: registered player";
		res.playerID = id;
		res.name = form["name"];

		return res;
	}

	Json saveScore(FormFields form) {
		enforceHTTP("playerID" in form, 
			HTTPStatus.badRequest, "Missing playerID field.");
		enforceHTTP("score" in form, 
			HTTPStatus.badRequest, "Missing score field.");

		auto id = form["playerID"].to!string;
		auto res = Json.emptyObject;

		// TODO: Check for registered playerID. Hit a minor bug with Tiny-Redis for booleon check
		/*if(redis.send("EXISTS", PLAYERS ~ id)==false) {
			res.playerID = id;
			res.status = "Player id does not exist";
			return res;
		}
		//enforceHTTP(redis.send("EXISTS", PLAYERS ~ id) == false, 
		//	HTTPStatus.badRequest, "No playerID exists.");
		*/

		auto score = form["score"].to!string;

		auto ret = 
			redis.send("ZADD " ~ TSCORES ~ S ~ score ~ S ~ id);


		res.playerID = id;
		res.score = score;
		res.status = "Success: Saved player score";
		return res;
	}

	Json getScore(FormFields form) {
		enforceHTTP("range" in form, 
					HTTPStatus.badRequest, "Missing range field.");
		string[2] scores;
		int i = 0;
		// Json arrays become dictionary objects and need to be iterated over into a proper array.
		// TODO: turn this into a utility
		foreach(k,v; form) {
			if("range"!=k) continue;
			scores[i] = v.to!string;
			i++;
		}
		// Grab the range values from the parsed array
		auto start = scores[0].to!string;
		auto end = scores[1].to!string;

		auto res = Json.emptyObject;
		auto ret = 
			redis.send("ZREVRANGE " ~ TSCORES ~ S ~ start ~ S ~ end ~ " WITHSCORES");


		auto tog = false;
		string key;
		// Create the score response
		foreach(k, f; ret) {
			if(!tog) key = f.to!string;
			else res[key] = f.to!string;
			tog = !tog;
		}
		return res;
	}

	Json getScoreByPlayer(FormFields form) {
		enforceHTTP("playerID" in form, 
			HTTPStatus.badRequest, "Missing playerID field.");

		auto id = form["playerID"].to!string;
		auto q =  redis.send!string("ZSCORE " ~ TSCORES ~ S ~ id);

		auto res = Json.emptyObject;
		res.playeriD = id;
		res.score = q;
		return res;
	}

	Json deletePlayer(FormFields form) {
		enforceHTTP("playerID" in form, 
			HTTPStatus.badRequest, "Missing playerID field.");

		auto id = form["playerID"].to!string;
		// The transaction to remove the player from the scoreboard list and the player object
		redis.transaction([
				"ZREM " ~ TSCORES ~ S ~ id, 
				"DEL " ~ PLAYERS ~ id
		]);

		auto res = Json.emptyObject;
		res.playerID = id;
		res.status = "Success: Player deleted";
		return res;
	}

}

