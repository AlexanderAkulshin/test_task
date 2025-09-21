FROM golang:1.25.1-alpine AS build
WORKDIR /src
COPY app/go.mod ./
RUN go mod download
COPY app/ ./
RUN --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags="-s -w -extldflags=-static" -o /out/server ./main.go

FROM gcr.io/distroless/static:nonroot
USER nonroot:nonroot
COPY --from=build /out/server /server
EXPOSE 8080
ENTRYPOINT ["/server"]
