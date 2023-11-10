FROM python:3.9-alpine3.13
#we use alpine because it is a lightweight linux distro
LABEL maintainer="Andrei N."

ENV PYTHONUNBUFFERED 1
#this is a recommended setting for python in docker
#it tells python to run in unbuffered mode which is recommended when running python in docker containers

COPY ./requirements.txt /tmp/requirements.txt
#copy the requirements.txt file from the local machine to the docker image
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
#copy the app folder which contain django app from the local machine to the docker image
WORKDIR /app
#set the working directory to /app
#when we run django commands, we will be running them from the /app directory
EXPOSE 8000
#expose port 8000
#this is the port that django runs on
#we need to expose it so that we can access it from the local machine

ARG DEV=false
#this gets overwritten by docker-compose.yml when we run docker-compose up
RUN python -m venv /py && \
#we set up a virtual environment to avoid edge case issues
#in some cases there are some python dependencies on the base image that might conflict with the dependencies for our django app
#overhead is small so there is no reason not to use it
    /py/bin/pip install --upgrade pip && \
#we specify /py/bin/pip because we want to use the pip that is installed in the virtual environment
#we upgrade pip from the venv to the latest version
    /py/bin/pip install -r /tmp/requirements.txt &&\
    if [ "$DEV" = "true" ] ;\
        then /py/bin/pip install -r /tmp/requirements.dev.txt ;\ 
    fi &&\
#we install the requirements.txt file
    rm -rf /tmp &&\
#we remove the requirements.txt file
#we do this because we don't want extra dependencies in our docker image
#best practice to keep docker images as small as possible
#any file we need temporarily, should be remove after we are done with it
    adduser \
    --disabled-password \
    --no-create-home \
    django-user
#we create a user called django-user
#we do this because it is a good security practice to not run the container using the root user
#we want to run the container using a user that has the least amount of permissions possible
#if our app gets compromised, we don't want the attacker to have root access to the container
#we want to limit the damage that can be done by the attacker if our app gets compromised

ENV PATH="/py/bin:$PATH"
#we update the PATH environment variable to include the path to the python virtual environment
#this is so that when we run python commands
#it will use the python from the virtual environment
#now we don't need to specify /py/bin/python when we run python commands
#we can just run python commands directly from our venv

USER django-user
#we switch to the django-user
#everytime we run a command, it will be run as the django-user
#this is a good security practice



