---
title: Add they lived happily ever after
teaching: 99
exercises: 99
---

::::::::::::::::::::::::::::::::::::::::::::::::::: objectives
- Learn how combinations of microservices can achieve complex tasks with no or low code.
- Disect a real world example of a microservices architecture.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::: questions
- How do I get the most out of Docker Compose?
- What is a microservices architecture?
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

So far in our exploration of Docker Compose we have focused on making our run commands more robust and on the orchestration of a stack.
In this lesson we will explore how to extend Docker Compose to create a true microservices architecture.

Much of the power of Docker is not just the ability to package your own tools but to use *off the shelf* tools to create powerful solutions.
Which we will demonstrate in this lesson!

## Microservices

First, we should explain what we mean by a microservices architecture.
The philosophy of microservices is to break down what could be a monolithic application into smaller, more manageable services.

For example, a monoloithic application might have a database, a web server, front and back ends, an API, a caching layer, a message queue, a search engine, etc etc, all contained in the same codebase!

By breaking down your application into smaller services, you can take advantage of the best tools available for each part of your application, maintained by an enthusiastic and expert community.

In a microservices architecture, each tool runs as its own service, and communicates with other services over a network.
Now, your database, your web server, your front and back ends and all the other services are genuinely separate, and can be best in class for their particular task.

For individual developers, it means less time writing code which has already been written, and more time focusing on the unique, and fun, parts of your application.

## A Real World Example

Let's take a look at this approach in the context of a real world example.

The [Apperture](https://github.com/UoMResearchIT/apperture) project is a stack of microservices which combine to provide a log in secure web portal with built in user-mangement. It is maintained by the University of Manchester's Research IT team and can easily be combined with other stacks to provide them with a log in portal.

`Apperture` is comprised primarily of a `docker-compose.yml` file. Just like we have been looking at!

The full `docker-compose.yml` file is available [here](https://raw.githubusercontent.com/UoMResearchIT/apperture/refs/heads/main/docker-compose.yml). It is quite long so we will reproduce a slimmed down version here.

```yaml
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

This `docker-compose.yml` file is a little more complex than the ones we have been looking at so far, but it is still just a list of services and their configurations.

You'll see some familiar things, like `image`, `ports`, `depends_on` (and `healthchecks`), `volumes`, and `environment`.

Notice the `image` field in the `services` section of the `docker-compose.yml` file. Every service is using a pre-built Docker image from Docker Hub. This is the power of Docker Compose and microservices!

To get an idea of what is going on, let's draw a diagram of the services in the `docker-compose.yml` file.

![Apperture Services: Showing a user accessing WhoAmI via the web portal, which is protected by Authelia, which authenticates against an LDAP server, which pulls user data from a Postgres database.](fig/docker_compose_apperture.png)

In short:
**Without writing a single line of code, we have a fully functioning, secure web portal!**

## Combining Stacks

One of the most powerful features of Docker Compose is the ability to combine stacks.
There is no reason we cannot combine the Apperture stack with the SPUC stack we have been working with in previous lessons!

This would allow us to protect our SPUC interface with the Apperture portal.
An important addition! We need to ensure poachers cannot falsely record sightings of the rare yet valuable unicorns!

This can be achieved by making a couple of changes to the SPUC `docker-compose.yml` file.

In our previous lesson, we learned about networks, which allow services to communicate with each other.
Now we want join the networks of the SPUC and Apperture stacks so that they can communicate with each other.

```yaml
# SPUC docker-compose.yml

+ networks:
+   apperture:
+     external: true
+     name: apperture_default
```

Couple this change with appropriate configuration of the proxy service and you have a secure SPUC portal!

![SPUC and Apperture Services: Showing a user accessing the SPUC interface via the web portal.](fig/docker_compose_spuc.png)

By combining the SPUC and Apperture stacks, we have created a powerful, secure web portal with no code!
But why stop there?

## Rapid extension

There are some improvments we can make very quickly!

We can:

* Add a proper database to SPUC using `Postgres`
* Add support for sensors using `RabbitMQ` and `Telegraf`
* Allow users to record images of unicorns using `MinIO`

![SPUC and Apperture Services: Showing a user accessing the SPUC interface via the web portal, which is protected by Authelia, which authenticates against an LDAP server, which pulls user data from a Postgres database. The SPUC interface communicates with a Postgres database, a RabbitMQ message queue, a Telegraf sensor, and a MinIO object store.](fig/docker_compose_full.png)

This is the true strength of Docker Compose and microservices. By combining off the shelf tools, we can create powerful solutions with no or low code and in a fraction of the time it would take to write everything from scratch.

## They Lived Happily Ever After

In this lesson we have explored how to extend Docker Compose to create a true microservices architecture.

This has helped us to support the SPUA in their mission to protect the rare and valuable unicorns!

![Thank you for supporting the SPUA!](fig/space_purple_unicorn_2.png)
