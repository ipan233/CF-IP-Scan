# Use the latest version of Alpine Linux as the base image
FROM alpine:latest

ENV TZ=UTC+8
# Set the working directory for the image to /app
WORKDIR /app

# Copy all files in the current directory to /app in the image
ADD . /app

# Install Bash and Curl without caching the package index
RUN apk add --no-cache bash curl jq tzdata masscan screen libpcap-dev

# Set the execute permission on the autoddns.sh script
RUN chmod +x /app/autoddns.sh
RUN chmod +x /app/entrypoint.sh
RUN chmod +x /app/asscan.sh

# Specify that the autoddns.sh script should be run when the container is started
CMD [ "./entrypoint.sh" ]
ENTRYPOINT [ "/bin/bash" ]