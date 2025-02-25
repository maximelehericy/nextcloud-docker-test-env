# Run OpenProject

- Copy the `openproject.env.example` file and rename it to `openproject.env`.
- Change the `YOURDOMAIN` according to your domain.
- Run the following command:

```sh
docker run -d --name openproject \
  --env-file apps/openproject/openproject.env \
  -v openproject_pgdata:/var/openproject/pgdata \
  -v openproject_assets:/var/openproject/assets \
  --network apps \
  --restart unless-stopped \
  openproject/openproject:15.0.2
```

To stop the container:

```sh
docker stop openproject && docker rm openproject
```

To remove the persistent data:
```sh
docker volume rm openproject_pgdata openproject_assets
```

Then install and configure the OpenProject integration app from the Nextcloud app store.
