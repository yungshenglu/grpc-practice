# gRPC Practice

This repository is used to practice some basic operations in **gRPC** and the original repository is [here](https://github.com/grpc/grpc).

> The following opreations are used in **Ubuntu Linux 16.04 LTS**.

---
## Introduction

> The following descriptions are from [here](https://grpc.io/docs/guides/index.html).

### What is "gRPC"?

In **gRPC** a client application can directly call methods on a server application on a different machine as if it was a local object, making it easier for you to create distributed applications and services. 

As in many RPC systems, gRPC is based around the idea of defining a service, specifying the methods that can be called remotely with their parameters and return types. 
* The server implements this interface and runs a gRPC server to handle client calls. 
* The client has a **stub** (referred to as just a client in some languages) that provides the same methods as the server.

![](https://grpc.io/img/landing-2.svg)

gRPC clients and servers can run and talk to each other in a variety of environments and can be written in any of gRPC’s supported languages.

### Working with Protocol Buffers

By default gRPC uses "[Protocol Buffers](https://developers.google.com/protocol-buffers/docs/overview)", Google’s mature open source mechanism for serializing structured data. Here’s a quick intro to how it works.
1. **Define the structure for the data**
    * The first step when working with protocol buffers is to **define the structure for the data** you want to serialize in a *proto file* (`.proto`). 
    * Protocol buffer data is structured as messages, where each message contains a series of name-value pairs called **fields**.
    ```cpp
    message Person {
        string name = 1;
        int32 id = 2;
        bool has_ponycopter = 3;
    }
    ```
2. **Compile the proto file**
    * You use the protocol buffer compiler `protoc` to generate data access classes in your preferred language(s) from your *proto* definition.
    * These provide simple accessors for each field (like `name()` and `set_name()`) as well as methods to serialize/parse the whole structure to/from raw bytes.
        * If your chosen language is C++, running the compiler on the above example will generate a class called `Person`.
        * You can then use this class in your application to populate, serialize, and retrieve Person protocol buffer messages.
    * As you’ll see in more detail in our examples, you define gRPC services in ordinary *proto* files, with RPC method parameters and return types specified as protocol buffer messages:
    ```cpp
    // The greeter service definition.
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

---
## Contents

* [Tutorials](src/tutorials)
  
---
## Contributing

To know how to contribute this repository, please refer to this [document](CONTRIBUTING.md) first. Thanks for your cooperation.

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

[Apache License 2.0](LICENSE)