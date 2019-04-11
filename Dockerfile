FROM golang:alpine as builder
RUN apk update && apk upgrade && \
    apk add --no-cache bash git
RUN go get github.com/prometheus/common/model github.com/prometheus/client_golang/api github.com/spf13/viper
RUN mkdir /go/src/build
ADD ./densify/discover.go /go/src/build
WORKDIR /go/src/build
RUN go build -o dataCollection .
FROM alpine
COPY ./densify .
COPY --from=builder /go/src/build/dataCollection .
WORKDIR .
CMD ["./Forwarder", "-c", "-n", "k8s_transfer_v2", "-l", "k8s_transfer_v2", "-o", "upload", "-r", "-C", "config"]