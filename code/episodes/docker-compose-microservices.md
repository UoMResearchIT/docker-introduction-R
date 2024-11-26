



## Microservices
## Microservices in Docker Compose
```yml
services:
  proxy:
    image: 'jc21/nginx-proxy-manager:latest'
    ports:
      - '80:80'
      - '443:443'
    depends_on:
      - authelia
    healthcheck:
      test: ["CMD", "/bin/check-health"]

  whoami:
    image: docker.io/traefik/whoami

  authelia:
    image: authelia/authelia
    depends_on:
      lldap:
        condition: service_healthy
    volumes:
      - ${PWD}/config/authelia/config:/config
    environment:
      AUTHELIA_DEFAULT_REDIRECTION_URL: https://whoami.${URL}
      AUTHELIA_STORAGE_POSTGRES_HOST: authelia-postgres
      AUTHELIA_AUTHENTICATION_BACKEND_LDAP_URL: ldap://apperture-ldap:3890

  lldap:
    image: nitnelave/lldap:stable
    depends_on:
      lldap-postgres:
        condition: service_healthy
    environment:
      LLDAP_LDAP_BASE_DN: dc=example,dc=com
      LLDAP_DATABASE_URL: postgres://user:pass@lldap-postgres/dbname
    volumes:
      - lldap-data:/data

  lldap-postgres:
    image: postgres
    volumes:
      - lldap-postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U lldap"]

volumes:
  lldap-data:
  lldap-postgres-data:
```
Image: Apperture Services: Showing a user accessing WhoAmI via the web portal, which is protected by Authelia, which authenticates against an LDAP server, which pulls user data from a Postgres database.
## Combining Stacks
```yml
# SPUC docker-compose.yml

+ networks:
+   apperture:
+     external: true
+     name: apperture_default
```
Image: SPUC and Apperture Services: Showing a user accessing the SPUC interface via the web portal.
## Rapid extension
Image: SPUC and Apperture Services: Showing a user accessing the SPUC interface via the web portal, which is protected by Authelia, which authenticates against an LDAP server, which pulls user data from a Postgres database. The SPUC interface communicates with a Postgres database, a RabbitMQ message queue, a Telegraf sensor, and a MinIO object store.
## They Lived Happily Ever After
Image: Thank you for supporting the SPUA!
