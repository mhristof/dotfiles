#! /usr/bin/env python3

import os
import re
from kubernetes import client, config


def match(command):
    ret = command.output.strip("\n").endswith('not found')
    if "pods" in command.output.split():
        return ret
    return False

def get_new_command(command):
    m = re.search('.* pods "(.*)" not found', command.output)

    pod = m.group(1)
    namespace = 'foo'

    config.load_kube_config()
    v1 = client.CoreV1Api()

    ret = v1.list_pod_for_all_namespaces(watch=False)
    for i in ret.items:
        if i.metadata.name == pod:
            namespace = i.metadata.namespace

    return f'k get pods {pod} --namespace {namespace}'

priority = 100
