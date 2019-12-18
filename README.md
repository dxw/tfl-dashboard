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

### Generic deployment instructions

Once logged in and in the right folder, you need to stop the container, remove the container and the image, then download and build the latest image:

```
$ docker-compose stop tfl
$ docker-compose rm tfl
$ docker rmi thedxw/tfl-dashboard
$ docker-compose up -d tfl
```

### dxw specific deployment instructions

Within dxw, the dashboard is deployed through Dalmatian. Up to date [global Dalmatian configuration](https://github.com/dxw/dalmatian-config) (private repo).
