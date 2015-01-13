#! /bin/bash
# Requires HTTPie.
# Description: Scenario test script for the leaderboard server
#
# If using the Redis server, del uniqueID and scores_list table between runs.

echo "Creating users"

http --print=bB -f POST localhost:3000 name=Don event:=1 &&
http --print=bB -f POST localhost:3000 name=Bill event:=1 &&

echo "Assigning points to users" &&

http --print=bB -f POST localhost:3000 playerID="1" score:=10 event:=2 &&
http --print=bB -f POST localhost:3000 playerID="2" score:=20 event:=2 &&

echo "Getting current range" &&

http --print=bB -f POST localhost:3000 event:=3 range:=[0,1] &&

echo "Updating player's 1 score to outdo player 2" &&

http --print=bB -f POST localhost:3000 playerID="1" score:=30 event:=2 &&

echo "Getting update range" &&

http --print=bB -f POST localhost:3000 event:=3 range:=[0,1] &&

echo "Getting score by user ID" &&

http --print=bB -f POST localhost:3000 playerID="1" event:=4 &&

echo "Delete a user" &&

http --print=bB -f POST localhost:3000 playerID="1" event=5 &&

echo "Getting update range after a user removed" &&

http --print=bB -f POST localhost:3000 event:=3 range:=[0,1] &&

echo "Cleaning up, removing other created user by script." &&

http --print=bB -f POST localhost:3000 playerID="2" event=5
