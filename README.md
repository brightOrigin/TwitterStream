TwitterStream
=============

TwitterStream is a demo app demonstrating how to use Twitter's Streaming API to display the top 10 retweeted tweets over a user defined rolling window. Due to time constraints I have implemented a fairly simple solution to the task that should nevertheless satisfy all requirements.

## Usage ##
- Build and run the app.
- Grant access to the Twitter account(s) on your device.
- Tap "Start" in the upper right corner.
- Enter the size of the cache in mins and you're off.
- Tap "Stop" to suspend streaming

## Limitations ##
- Cache is based in memory so performance/resource usage degrades quickly as the window size increases. A more robust solution could persist parts of the cache to disk using Core Data or something similar and optimize the cache size (see [Cache Optimization][]).
- Doesn't check for duplicate tweets
- Not much error checking or user proofing

## Cache Optimization ##
Due to the fact that the sample stream seems to be restricted to a few tweets per second I didn't spend any time optimizing the cache. However one strategy which could be implemented in the scenario where hundreds/thousands of tweets would be coming in per second would be to:
- maintain a hash table with a key for each time interval being used (in this case a second) for the size of the window in minutes.
- the max bucket size for each key would then be limited to 10 as you would never need more than the top 10 for that timestamp in the worst case scenario
- this solution should scale fairly well as the number of tweets increases without the risk of losing any valid tweets.
