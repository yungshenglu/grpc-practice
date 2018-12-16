# Tutorial 2 - gRPC Basics in Python

We are going to learn how to working with gRPC in Python in this tutorial.

By walking through this example we will learn how to:
* Define a service in a .proto file.
* Generate server and client code using the protocol buffer compiler.
* Use the Python gRPC API to write a simple client and server for your service.

---
## 2.1 Download the example code (optional)

You will need a local copy of the example code to work through this quickstart. However, we have already prepared in this directory ([`route_guide/`](route_guide/)). If you want to do it by yourself, you can run the commands as follow.

1. Clone the repository to get the example code
    ```bash
    # Make sure your directory is you want to place the repository
    $ git clone -b v.17.1 https://github.com/grpc/grpc
    ```
2. Change the current directory as follow:
    ```bash
    $ cd ./grpc/examples/python/route_guide/
    ```

---
## 2.2  Define the service

You can see the complete `.proto` file in [`./protos/route_guide.proto`](protos/route_guide.proto).

1. Define the gRPC *service* and the method *request* and *response* types using [Protocol Buffers](https://developers.google.com/protocol-buffers/docs/overview)
    ```cpp
    service RouteGuide {
        // (Method definitions not shown)
    }
    ```
2. Define `rpc` methods inside your service definition and specify their *request* and *response* types
    
    gRPC allows you define the following four kinds of service method.
    * **Simple RPC**
        ```cpp
        // Obtains the Feature at a given Point
        rpc GetFeature(Point) returns (Feature) {}
        ```
        * The client sends request to the server using the stub and waits for a response to come back, just like a normal function call
        
    * **Response-streaming RPC**
        ```cpp
        // Obtains the Features available within the given Rectangle Results are
        // streamed rather than returned at once (e.g. in a response message with a
        // repeated field), as the rectangle may cover a large area and contain a
        // huge number of features.
        rpc ListFeatures(Rectangle) returns (stream Feature)
        ```
        * The client sends a request to the server and gets a stream to read a sequence of message back
        * The client reads from the returned stream until there are no more messages
        * Need to specify a response-streaming method by placing the `stream` keyword before the *response* type
    * **Request-streaming RPC**
        ```cpp
        // Accepts a stream of Points on a route being traversed, returning a
        // RouteSummary when traversal is completed.
        rpc RecordRoute(stream Point) returns (RouteSummary) {}
        ```
        * The client writes a sequence of messages and sends them to the server, again using a provided stream
        * Once the client has finished writing the messages, it wait for the server to read them all and return its response
        * Need to sepcify a request-streaming method by placing the `stream` keyword before the *request* type
    * **Bidirectionally-streaming RPC**
        ```cpp
        // Accepts a stream of RouteNotes sent while a route is being traversed,
        // while receiving other RouteNotes (e.g. from other users).
        rpc RouteChat(stream RouteNote) returns (stream RouteNote) {}
        ```
        * Both sides send a sequence of messages using a read-write stream.
        * The two streams oprerate independently, so clients and servers can read and write in whatever order thry like:
        * The order of messages in each stream is preserved
        * Need to specify this type of method by placing the `stream` keyword before both the request and the response
3. Define the types of protcol buffer message for all the request and reponse types
    ```cpp
    message Point {
        int32 latitude = 1;
        int32 longitude = 2;
    }

    message Rectangle {
        Point lo = 1;
        Point hi = 2;
    }

    message Feature {
        string name = 1;
        Point location = 2;
    }

    message RouteNote {
        Point location = 1;
        string message = 2;
    }

    message RouteSummary {
        int32 point_count = 1;
        int32 feature_count = 2;
        int32 distane = 3;
        int32 elapsed_time = 4;
    }
    ```

---
## 2.3 Generate client and server code

Next you need to generate the gRPC client and server interfaces from your `.proto` service definition. Make sure you have already installed `grpcio` and `grpcio-tools` with `pip`.

1. How to install `grpcio` and `grpcio-tools` with `pip`? [Here!](../1_start/)
2. Generate the client's and the server's gRPC code
    ```bash
    # Make sure your current directory is "./2_basic/"
    $ python -m grpc_tools.protoc -I./protos --python_out=./route_guide/ --grpc_python_out=./route_guide/ ./protos/route_guide.proto
    ```
3. It will regenerate `route_guide_pb2.py` and `route_guide_pb2_grpc.py` in directory `./route_guide/`
    * `route_guide_pb2.py` contains our generated request and response classes
    * `route_guide_pb2_grpc.py` contains out generated client and server classes
        * `RouteGuideStub`, which can be used by clients to invoke `RouteGuide` RPCs
        * `RouteGuideServicer`, which defines the interface for implementations of the `RouteGuide` service
        * `add_RouteGuideServicer_to_server`, which adds a `RouteGuideServicer` to a `grpc.Server`
  
> **Notes:** The `2` in `pb2` indicates that the generated code is following Protocol Buffers Python API version 2. It has no relation to the Protocol Buffers Language version, which is the one indicated by `syntax = "proto3"` or `syntax = "proto2"` in a `.proto` file.

---
## 2.4 Create the server

First let's look at how you create a `RouteGuide` server. Creating and running a `RouteGuide` server breaks down into two work items:
* Implement the servicer interface generated from our service definition with functions that performs the actual "work" of the service
* Run a gRPC server to listen for requests from clients and transmit responses

You can see the complete example `RouteGuide` server in [`./route_guide/route_guide_server.py`](route_guide/route_guide_server.py).

1. Implement `RouteGuide`
    * **Simple RPC**
        * Get a `Point` from the client and returns the corresponding feature information from its databasae in a `Feature`
            ```python
            def GetFeature(self, request, context):
                feature = get_feature(self.db, request)
                if feature is None:
                    return route_guide_pb2.Feature(name="", location=request)
                else:
                    return feature
            ```
            ```python
            def get_feature(feature_db, point):
            """Returns Feature at given location or None."""
            for feature in feature_db:
                if feature.location == point:
                    return feature
            return None
            ```
        * The method is passed a `route_guide_pb2.Point` request for the gRPC, and a `grpc.ServicerContext` object that provides RPC-specific information such as timeout limit
        * It returns a `route_guide_pb2.Feature` response
    * **Response-streaming RPC**
        * Send multiple `Feature`s to the client
            ```python
            def ListFeatures(self, request, context):
                left = min(request.lo.longitude, request.hi.longitude)
                right = max(request.lo.longitude, request.hi.longitude)
                top = max(request.lo.latitude, request.hi.latitude)
                bottom = min(request.lo.latitude, request.hi.latitude)
                for feature in self.db:
                    if (feature.location.longitude >= left and
                        feature.location.longitude <= right and
                        feature.location.latitude >= bottom and
                        feature.location.latitude <= top):
                        yield feature
            ```
        * The request message is a `route_guide_pb2.Rectangle` within which the client wants to find `Feature`s
        * The method yields zero of more responses
    * **Request-streaming RPC**
        ```python
        def RecordRoute(self, request_iterator, context):
            point_count = 0
            feature_count = 0
            distance = 0.0
            prev_point = None

            start_time = time.time()
            for point in request_iterator:
                point_count += 1
                if get_feature(self.db, point):
                    feature_count += 1
                if prev_point:
                    distance += get_distance(prev_point, point)
                prev_point = point
            elapsed_time = time.time() - start_time

            return route_guide_pb2.RouteSummary(point_count=point_count,
                                                feature_count=feature_count,
                                                distance=int(distance),
                                                elapsed_time=int(elapsed_time))
        ```
        ```python
        def get_distance(start, end):
            """Distance between two points."""
            coord_factor = 10000000.0
            lat_1 = start.latitude / coord_factor
            lat_2 = end.latitude / coord_factor
            lon_1 = start.longitude / coord_factor
            lon_2 = end.longitude / coord_factor
            lat_rad_1 = math.radians(lat_1)
            lat_rad_2 = math.radians(lat_2)
            delta_lat_rad = math.radians(lat_2 - lat_1)
            delta_lon_rad = math.radians(lon_2 - lon_1)

            # Formula is based on http://mathforum.org/library/drmath/view/51879.html
            a = (pow(math.sin(delta_lat_rad / 2), 2) +
                (math.cos(lat_rad_1) * math.cos(lat_rad_2) * pow(
                    math.sin(delta_lon_rad / 2), 2)))
            c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
            R = 6371000
            # metres
            return R * c
        ```
    * **Bidirectional streaming RPC**
        ```python
        def RouteChat(self, request_iterator, context):
            prev_notes = []
            for new_note in request_iterator:
                for prev_note in prev_notes:
                    if prev_note.location == new_note.location:
                        yield prev_note
                prev_notes.append(new_note)
        ```
        * This method `RouteChat` semantics are a combination of those of the request-streaming method and the response-streaming method
2. Start the gRPC server so that clients can actually use your service
    ```python
    def serve():
        server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
        route_guide_pb2_grpc.add_RouteGuideServicer_to_server(RouteGuideServicer(), server)
        server.add_insecure_port('[::]:50051')
        server.start()
        try:
            while True:
                time.sleep(_ONE_DAY_IN_SECONDS)
        except KeyboardInterrupt:
            server.stop(0)
    ```
    * Because `start()` does not block you may need to sleep-loop if there is nothing else for your code to do while serving
  
---
## 2.5 Create the client

You can see the complete example client in [`./route_guide/route_guide_client.py`](route_guide/route_guide_client.py).

1. Create a stub
    ```python
    def run():
        with grpc.insecure_channel('localhost:50051') as channel:
            stub = route_guide_pb2_grpc.RouteGuideStub(channel)
    ```
    * Instantiate the `RouteGuideStub` class of the `route_guide_pb2_grpc` module, generated from our `.proto`
2. Call service methods
    * **Simple RPC**
        * A *synchronous* call to the simple RPC `GetFeature` is nearly as straightforward as calling a local method
            ```python
            # Refer to the method "guide_get_one_feature(stub, point)" in route_guide_client.py
            feature = stub.GetFeature(point)
            ```
        * An *asynchronous* call to GetFeature is similar, but like calling a local method asynchronously in a thread pool
            ```python
            feature_future = stub.GetFeature.future(point)
            feature = feature_future.result()
            ```
    * **Response-streaming RPC**
        ```python
        # Refer to the method "guide_list_features(stub)" in route_guide_client.py
        for feature in stub.ListFeatures(rectangle):
        ```
    * **Request-streaming RPC**
        ```python
        # Refer to the method "guide_record_route(stub)" in route_guide_client.py
        route_summary = stub.RecordRoute(route_iterator)
        ```
    * **Bidirectional streaming RPC**
        ```python
        # Refer to the method "guide_route_chat(stub)" in route_guide_client.py
        for received_route_note in stub.RouteChat(sent_route_note_iterator):
        ```
        
---
## 2.7 Try it out!

1. Run the gRPC server, which will listen on port `50051`
    ```bash
    $ python route_guide_server.py
    ```
2. Run the client in another terminal
    ```bash
    $ python route_guide_client.py
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