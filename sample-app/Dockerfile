FROM golang:latest

WORKDIR /app

COPY . .

RUN go build

EXPOSE 8080

CMD ["./sample-app"]
