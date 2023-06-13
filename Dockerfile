FROM alpine:lastest
WORKDIR /app
ADD . .
CMD [ "./autoddns.sh" ]
