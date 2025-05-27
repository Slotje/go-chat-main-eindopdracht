FROM golang:1.22-alpine AS builder

RUN apk add --no-cache git

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

FROM alpine:latest

RUN apk --no-cache add ca-certificates

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /root/

COPY --from=builder /app/main .

COPY --from=builder /app/static ./static
COPY --from=builder /app/views ./views

RUN chown -R appuser:appgroup /root/

USER appuser

EXPOSE 80

CMD ["./main"]