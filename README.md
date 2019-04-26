A Sinatra app for displaying the status of London tube and Overground lines, as reported by the TfL API.

### How to run it locally

```
rackup
```

By default it will run on http://localhost:9292/.

### How to release a new version

First make sure you are logged into Docker Hub with `docker login`. Then build and push the image:

```
docker build . -t thedxw/tfl-dashboard
docker push thedxw/tfl-dashboard
```

### How to deploy

Within dxw, the dashboard is deployed through Dachshund. At the time of writing it is necessary to manually restart Docker on the stats.dxw.net box for it to pick up the new version.

More detailed instructions on how to login are in the [private repo for Dachshund](https://github.com/dxw/dachshund#deployment).

Once logged in and in the right folder, you need to stop the container, remove the container and the image, then download and build the latest image:

```
$ docker-compose stop tfl
$ docker-compose rm tfl
$ docker rmi thedxw/tfl-dashboard
$ docker-compose up -d tfl
```
