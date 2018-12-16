# Make sure your current directory is "./1_start/"
# Update the gRPC code used by our application to use the new service definition.
python -m grpc_tools.protoc -I./protos --python_out=./helloworld/ --grpc_python_out=./helloworld/ ./protos/helloworld2.proto
