FROM golang:alpine

# Copy the code into the container
COPY mtls.go .

# Build the application
RUN go build mtls.go

# Export necessary port
EXPOSE 443

# Command to run when starting the container
CMD ["./mtls"]
