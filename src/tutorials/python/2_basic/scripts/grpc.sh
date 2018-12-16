# Make sure your current directory is "./2_basic/"
# Update the gRPC code used by our application to use the new service definition.
python -m grpc_tools.protoc -I./protos --python_out=./route_guide/ --grpc_python_out=./route_guide/ ./protos/route_guide.proto
