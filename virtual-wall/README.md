## Setting up Kubernetes

Create an experiment on the Virtual Wall via jFed and 
the espec in `espec.tar.gz`.
This archive is created by doing `tar -zcvf ../espec.tar.gz *` in the folder `espec`.

## Before running

The following is executed on the master node of Kubernetes.
This node is called `master` in the jFed experiment.

- Verify health of Kubernetes via `kubectl get cs`.
Everything should be `Healthy`.
- Verify status of all nodes via `kubectl get nodes`.
All nodes, including `master`, should have status `Ready`.
- Copy the current folder to the master node.
- The following makes it possible to pull the Docker images from our Gitlab:

```
kubectl create secret generic regcred \
    --from-file=.dockerconfigjson=docker-config.json \
    --type=kubernetes.io/dockerconfigjson
```

Where `docker-config.json` is a copy of 
`~/.docker/config.json` which is on your local machine normally.

- Add Nextcloud password via 
`kubectl create secret generic nextcloud --from-literal=password=YOUR_PASSWORD`
where `YOUR_PASSWORD` is replaced with your password.

## Running

- Execute `run-single-test.sh -e [engine] -d [directory]`,
where `[engine]` is `triplewave` or `rmlstreamer` (in the near future) and
`[directory]` is the output directory on Nextcloud.
Use `-h` for more information.
- A message is printed when the test is done and 
the script exists.


## Tips and tricks

- Get Docker image used of pod via `kubectl get pods $YOUR_POD_NAME -o jsonpath="{..imageID}"`.
Unfortunately, the hashes of the images on Kubernetes do not match the hashes on the Gitlab container registry.
- Delete all Kubernetes deployments, services, and jobs via `kubectl delete deployment,svc,job --all &> /dev/null`
