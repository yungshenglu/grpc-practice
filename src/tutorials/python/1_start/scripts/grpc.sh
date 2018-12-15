# Update the gRPC code used by our application to use the new service definition.
python -m grpc_tools.protoc -I./protos --python_out=. --grpc_python_out=. ./protos/helloworld.proto