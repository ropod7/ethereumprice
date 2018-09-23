#import os, sys
from urllib import request
import json

def handle(market):
    url = "https://api.cryptowat.ch/markets/%s/%s/price"
    currs = ["usd", "eur", "btc"]
    result = {}

    for curr in currs:
        try:
            data = request.urlopen(url % (market, "eth" + curr))
            result[curr] = json.loads(data.read().decode("utf8")).get("result").get("price")
            data.close()
        except:
            return "none"

    return json.dumps(result)
