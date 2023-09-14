#! /usr/bin/env python3
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#

import os
from opensearchpy import OpenSearch, RequestsHttpConnection, AWSV4SignerAuth
import boto3
import json
from datetime import datetime, timedelta
import logging
import argparse
import time

logger = logging.getLogger(os.path.basename(__file__))


def main():
    parser = argparse.ArgumentParser(description="OpenSearch query")
    parser.add_argument("-l", "--live", action="store_true", help="live mode")
    parser.add_argument("-d", "--date", type=str, default="today", help="date")
    parser.add_argument(
        "-s",
        "--service",
        choices=os.getenv("OPENSEARCH_PY_SERVICES", "").split(","),
        type=str,
        default=None,
        help="docker-compose service name",
    )
    parser.add_argument(
        "-i", "--index", type=str, default="logstash", help="index name"
    )
    parser.add_argument("-v", "--verbose", action="store_true", help="verbose")

    args = parser.parse_args()

    logging.basicConfig(
        level=logging.ERROR, format="%(asctime)s %(module)s %(message)s"
    )

    logger.setLevel(logging.INFO)

    if args.verbose:
        logger.setLevel(logging.DEBUG)

    host = os.getenv("OPENSEARCH_PY_HOST")
    region = os.getenv("OPENSEARCH_PY_REGION")
    service = "es"
    credentials = boto3.Session().get_credentials()
    auth = AWSV4SignerAuth(credentials, region, service)

    client = OpenSearch(
        hosts=[{"host": host, "port": 443}],
        http_auth=auth,
        use_ssl=True,
        verify_certs=True,
        connection_class=RequestsHttpConnection,
        pool_maxsize=20,
    )

    if args.date == "today":
        args.date = datetime.strftime(datetime.now(), "%Y-%m-%d")

    match = {"match_all": {}}

    if args.service is not None:
        match = {
            "container.labels.com_docker_compose_service": args.service,
        }

    timestamp = {
        "gte": f"{args.date}T00:00:00Z",
        "lte": f"{args.date}T23:59:59Z",
    }

    if args.live:
        timestamp = {
            "gte": f"now-3m",
            "lte": f"now",
        }

    query = {
        "size": 10000,
        "query": {
            "bool": {
                "must": [
                    {
                        "range": {
                            "@timestamp": timestamp,
                        },
                    },
                    {
                        "match": match,
                    },
                ],
            }
        },
        "sort": [{"@timestamp": "asc"}],
    }

    logger.debug(json.dumps(query, indent=2))

    index = f"{args.index}-{args.date.replace('-', '.')}"
    logger.debug(f"index: {index}")

    mid = [set(), set()]

    while True:
        response = client.search(body=query, index=index)

        if response["hits"]["total"] == {"value": 0, "relation": "eq"}:
            if args.live:
                time.sleep(1)

                continue

            logger.info(f"no data for date: {args.date} match: {match}")

            break

        try:
            start = query["query"]["bool"]["must"][0]["range"]["@timestamp"]["gte"]
        except KeyError:
            start = query["query"]["bool"]["must"][0]["range"]["@timestamp"]["gt"]

        stop = query["query"]["bool"]["must"][0]["range"]["@timestamp"]["lte"]
        hits = response["hits"]["total"]["value"]
        relation = response["hits"]["total"]["relation"]

        if response["hits"]["total"] == {"value": 1, "relation": "eq"}:
            if args.live:
                logger.debug("live mode, sleep 1s")
                time.sleep(1)

                continue

            break

        logger.debug(f"time: [%s, %s] hits: %s (%s)", start, stop, hits, relation)

        dup = 0

        last_hit = None

        for hit in response["hits"]["hits"]:
            if hit["_id"] in mid[0]:
                dup += 1

                continue

            line = [hit["_source"]["@timestamp"]]

            try:
                line += [
                    hit["_source"]["container"]["labels"]["com_docker_compose_service"]
                ]
            except KeyError:
                pass

            line += [hit["_source"].get("message", "")]
            logger.info(" ".join(line))
            mid[1].add(hit["_id"])
            last_hit = hit

        logger.debug("dup: %s", dup)

        if last_hit is None and args.live:
            time.sleep(1)

            continue

        if last_hit is None:
            break

        query["query"]["bool"]["must"][0]["range"]["@timestamp"]["gte"] = last_hit[
            "_source"
        ]["@timestamp"]

        mid[0] = mid[1]


if __name__ == "__main__":
    main()
