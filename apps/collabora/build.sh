cd ${PWD}/apps/collabora
docker build -f "Dockerfile" --no-cache --secret id=secret_key,src=secret_key --build-arg type=cool -t collabora .
