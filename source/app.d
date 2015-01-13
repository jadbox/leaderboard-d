import vibe.d;
import RedisLeaderboard;
import vibe.core.args;
static RedisLeaderboard leaderboard;

shared static this()
{
	auto settings = new HTTPServerSettings;

	// Resolve port
	ushort port = 3000;
	readOption("port", &port, "Port for server, default 3000");
	settings.port = port;

	settings.bindAddresses = ["::1", "127.0.0.1"];
	leaderboard = new RedisLeaderboard();
	listenHTTP(settings, &router);

	logInfo("Server started on http://127.0.0.1:" ~ settings.port.to!(string) ~ "/.");
}

void router(HTTPServerRequest req, HTTPServerResponse res)
{
	enforceHTTP("event" in req.form, HTTPStatus.badRequest, "Missing event field.");

	auto routes = [&leaderboard.register, &leaderboard.saveScore,
		&leaderboard.getScore, &leaderboard.getScoreByPlayer, 
		&leaderboard.deletePlayer];
		
	auto event = req.form["event"].to!int;
	event--; // start the event IDs at 0 for the handler index
	if(event < 0 || event >= routes.length) 
		enforceHTTP("event" in req.form, HTTPStatus.badRequest, "Invalid event ID.");
	else {
		req.method = HTTPMethod.POST;
		auto ret = routes[event](req.form);
		//enforceHTTP("error" in ret, HTTPStatus.badRequest, ret.error.to);

		res.writeJsonBody(ret);
	}
}
