# Tutorial 1 - Quick Start

We are going to install gRPC in this tutorial.

---
## 1.1 Before you begin

**gRPC Python** is supported for use Python 2.7 or Python 3.4 or higher. 

1. Prerequisite
    * Make sure you have `pip` version 9.0.1 or higher
        ```bash
        # Show the version of pip
        $ pip --version
        # Upgrade pip
        $ pip install --upgrade pip
        ```
    * If you cannot upgrade `pip` due to a system-owned installation, you can run the example in a `virtualenv`
        ```bash
        # Install virtualenv
        $ [sudo] pip install virtualenv
        # Create virtualenv
        $ virtualenv venv
        # Activte virtualenv
        $ source venv/bin/activate
        # Upgrade pip
        (venv) $ pip install --upgrade pip
        ```
2. Installation
    * Install gRPC with `pip`
        ```bash
        $ [sudo] pip install grpcio
        ```
        * **Troubleshooting:** On El Capitan OSX, you may get the following error:
            ```bash
            OSError: [Errno 1] Operation not permitted: '/tmp/pip-qwTLbI-uninstall/System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/six-1.4.1-py2.7.egg-info'
            ```
            You can work around this using:
            ```bash
            $ pip install grpcio --ignore-installed
            ```
    * Install gRPC tools with `pip`
        ```bash
        $ [sudo] pip install grpcio-tools
        ```

---
## 1.2 Download the example code (optional)

You will need a local copy of the example code to work through this quickstart. However, we have already prepared in this directory ([`helloworld/`](helloworld/)). If you want to do it by yourself, you can run the commands as follow.

1. Clone the repository to get the example code
    ```bash
    # Make sure your directory is you want to place the repository
    $ git clone -b v.17.1 https://github.com/grpc/grpc
    ```
2. Change the current directory as follow:
    ```bash
    $ cd ./grpc/examples/python/helloworld/
    ```

---
## 1.3 Run a gRPC application

Make sure your current directory is in [`./helloworld/`](helloworld/) or in your downloaded repository.

1. Run the server in one terminal
    ```bash
    $ python greeter_server.py
    ```
2. Run the client in another terminal
    ```bash
    $ python greeter_client.py
    ```
3. If succeed, you will see the message in the client's terminal as follow:
    ```bash
    Greeter client received: Hello, you!
    ```

---
## 1.4 Update a gRPC service

> The following tutorials will introduce [gRPC Basics in Python]().

For now all you need to know is that both the server and the client **"stub"** have a `SayHello` RPC method that takes a `HelloRequest` parameter from the client and returns a `HelloResponse` from the server, and that this method is defined like this:

```cpp
// The greeting service definition.
service Greeter {
    // Sends a greeting
    rpc SayHello (HelloRequest) returns (HelloReply) {}
}

// The request message containing the user's name.
message HelloRequest {
    string name = 1;
}

// The response message containing the greetings
message HelloReply {
    string message = 1;
}
```

1. Copy the file [`./protos/helloworld.proto`](protos/helloworld.proto) to `./protos/helloworld2.proto`
    ```bash
    # Make sure your current directory is "./1_start/protos/"
    $ cp helloworld.proto helloworld2.proto
    ```
2. Update the file `./protos/helloworld2.proto` with a new `SayHelloAgain` method as follow:
    ```cpp
    // The greeting service definition.
    service Greeter {
        // Sends a greeting
        rpc SayHello (HelloRequest) returns (HelloReply) {}
        // Sends another greeting here!
        rpc SayHelloAgain (HelloRequest) returns (HelloReply) {}
    }

    // The request message containing the user's name.
    message HelloRequest {
        string name = 1;
    }

    // The response message containing the greetings
    message HelloReply {
        string message = 1;
    }
    ```

---
## 1.5 Generate gRPC code

Next we need to update the gRPC code used by our application to use the new service definition.

1. Update the gRPC code as follow:
    ```bash
    # Make sure your current directory is "./1_start/"
    $ python -m grpc_tools.protoc -I./protos --python_out=./helloworld/ --grpc_python_out=./helloworld/ ./protos/helloworld2.proto
    ```
2. It will regenerate `helloworld_pb2.py` and `helloworld_pb2_grpc.py` in directory `./helloworld/`
    * `helloworld_pb2.py` contains our generated request and response classes
    * `helloworld_pb2_grpc.py` contains out generated client and server classes
  
---
## 1.6 Update and run the application

We now have new generated server and client code, but we still need to implement and call the new method in the human-written parts of our example application.

1. Copy the file [`./helloworld/greeter_server.py`](helloworld/greeter_server.py) to `./helloworld/greeter_server2.py`
    ```bash
    # Make sure your current directory is "./1_start/helloworld/"
    $ cp greeter_server.py greeter_server2.py
    ```
2. Update the server `./helloworld/greeter_server2.py` as follow:
    ```python
    import helloworld2_pb2
    import helloworld2_pb2_grpc
    ```
    ```python
    class Greeter(helloworld_pb2_grpc.GreeterServicer):

        def SayHello(self, request, context):
            return helloworld2_pb2.HelloReply(message='Hello, %s!' % request.name)

        # Update the server here!
        def SayHelloAgain(self, request, context):
            return helloworld2_pb2.HelloReply(message='Hello again, %s!' % request.name)
    ```
    ```python
    def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    helloworld2_pb2_grpc.add_GreeterServicer_to_server(Greeter(), server)
    server.add_insecure_port('[::]:50051')
    server.start()
    try:
        while True:
            time.sleep(_ONE_DAY_IN_SECONDS)
    except KeyboardInterrupt:
        server.stop(0)
    ```
3. Copy the file [`./helloworld/greeter_client.py`](helloworld/greeter_client.py) to `./helloworld/greeter_client2.py`
    ```bash
    # Make sure your current directory is "./1_start/helloworld/"
    $ cp greeter_client.py greeter_client2.py
    ```
4. Update the server `./helloworld/greeter_client2.py` as follow:
    ```python
    import helloworld2_pb2
    import helloworld2_pb2_grpc
    ```
    ```python
    def run():
    # NOTE(gRPC Python Team): .close() is possible on a channel and should be
    # used in circumstances in which the with statement does not fit the needs
    # of the code.
    with grpc.insecure_channel('localhost:50051') as channel:
        stub = helloworld2_pb2_grpc.GreeterStub(channel)
        response = stub.SayHello(helloworld2_pb2.HelloRequest(name='NSS'))
        print("Greeter client received: " + response.message)
        # Update the client here!
        response = stub.SayHelloAgain(helloworld2_pb2.HelloRequest(name='NSS'))
        print("Greeter client received: " + response.message)
    ```
5. Run the server `greeter_server2.py` in one terminal
    ```bash
    $ python greeter_server2.py
    ```
6. Run the client `greeter_client2.py` in another terminal
    ```bash
    $ python greeter_client2.py
    ```
7. If succeed, you will see the message in the client's terminal as follow:
    ```bash
    Greeter client received: Hello, you!
    Greeter client received: Hello again, you!
    ```

---
## References

* [gRPC Official Website](https://grpc.io/)
* [Protocol Buffers Documentation](https://developers.google.com/protocol-buffers/docs/overview)
* [Protocol Buffers 3 Language Guide](https://developers.google.com/protocol-buffers/docs/proto3)
* [GitHub - grpc/grpc](https://github.com/grpc/grpc)
* [GitHub - google/protobuf](https://github.com/google/protobuf/releases)

---
## Contributor

In order to protect both you and ourselves, you will need to sign the [Contributor License Agreement](https://identity.linuxfoundation.org/projects/cncf).

* [David Lu](https://github.com/yungshenglu)

---
## License

Apache License 2.0