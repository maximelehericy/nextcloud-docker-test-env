cd ${PWD}/apps/talkrecording/nextcloud-talk-recording-0.1
docker build -f "docker-compose/Dockerfile" -t talkrecording:v0.1 .
cd ../
docker build -f "Dockerfile" -t talkrecording:v0.1.8000 .
