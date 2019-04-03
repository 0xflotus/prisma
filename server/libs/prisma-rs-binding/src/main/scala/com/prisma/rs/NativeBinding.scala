package com.prisma.rs

import com.prisma.gc_values._
import com.prisma.rs.jna.{JnaRustBridge, ProtobufEnvelope}
import com.sun.jna.{Memory, Native, Pointer}
import play.api.libs.json.{JsValue, Json}
import prisma.protocol._
import scalapb.GeneratedMessage

case class NodeResult(id: IdGCValue, data: RootGCValue)

object NativeBinding {
  val library: JnaRustBridge = {
    System.setProperty("jna.debug_load.jna", "true")
    System.setProperty("jna.debug_load", "true")
    System.setProperty("jna.library.path", sys.env.get("SERVER_ROOT").map(path => s"$path/prisma-rs/build").getOrElse("/lib"))

    Native.loadLibrary("native_bridge", classOf[JnaRustBridge])
  }

  def get_node_by_where(getNodeByWhere: GetNodeByWhereInput): Option[(Node, Vector[String])] = {
    val (pointer, length) = writeBuffer(getNodeByWhere)

    handleProtoResult(library.get_node_by_where(pointer, length)) { nodesAndFields: (Seq[Node], Seq[String]) =>
      nodesAndFields._1.headOption.map((_, nodesAndFields._2.toVector))
    }
  }

  def get_nodes(getNodes: GetNodesInput): (Vector[Node], Vector[String]) = {
    val (pointer, length) = writeBuffer(getNodes)

    handleProtoResult(library.get_nodes(pointer, length)) { nodesAndFields: (Vector[Node], Vector[String]) =>
      nodesAndFields
    }
  }

  def get_related_nodes(getRelatedNodesInput: GetRelatedNodesInput): (Vector[Node], Vector[String]) = {
    val (pointer, length) = writeBuffer(getRelatedNodesInput)

    handleProtoResult(library.get_related_nodes(pointer, length)) { nodesAndFields: (Vector[Node], Vector[String]) =>
      nodesAndFields
    }
  }

  def get_scalar_list_values_by_node_ids(input: GetScalarListValuesByNodeIds): Seq[ScalarListValues] = {
    val (pointer, length) = writeBuffer(input)
    handleProtoResult(library.get_scalar_list_values_by_node_ids(pointer, length)) { values: Seq[ScalarListValues] =>
      values
    }
  }

  def execute_raw(input: ExecuteRawInput): JsValue = {
    val (pointer, length) = writeBuffer(input)
    handleProtoResult(library.execute_raw(pointer, length)) { json: JsValue =>
      json
    }
  }

  def count_by_model(input: CountByModelInput): Int = {
    val (pointer, length) = writeBuffer(input)

    handleProtoResult(library.count_by_model(pointer, length)) { i: Int =>
      i
    }
  }

  def count_by_table(input: CountByTableInput): Int = {
    val (pointer, length) = writeBuffer(input)

    handleProtoResult(library.count_by_table(pointer, length)) { i: Int =>
      i
    }
  }

  def execute_mutaction(
      input: DatabaseMutaction,
      errorHandler: PartialFunction[prisma.protocol.Error.Value, Throwable]
  ): DatabaseMutactionResult = {
    val (pointer, length) = writeBuffer(input)
    // FIXME: this must return proper result intead of this int
    handleProtoResult(library.execute_mutaction(pointer, length), errorHandler) { x: DatabaseMutactionResult =>
      x
    }
  }

  def handleProtoResult[T, U](
      envelope: ProtobufEnvelope.ByReference,
      errorHandler: PartialFunction[prisma.protocol.Error.Value, Throwable] = PartialFunction.empty
  )(processMessage: T => U): U = {
    val messageContent = envelope.data.getByteArray(0, envelope.len.intValue())
    library.destroy(envelope)

    val decodedMessage = RpcResponse.parseFrom(messageContent)
    decodedMessage.response match {
      // Success cases
      case RpcResponse.Response.Result(Result(value: Result.Value)) =>
        value match {
          case Result.Value.NodesResult(NodesResult(nodes: Seq[Node], fields: Seq[String])) =>
            processMessage((nodes, fields).asInstanceOf[T])

          case Result.Value.ScalarListResults(value) =>
            processMessage(value.values.asInstanceOf[T])

          case Result.Value.ExecuteRawResult(result) =>
            val json = Json.parse(result.json)
            processMessage(json.asInstanceOf[T])

          case Result.Value.Integer(value) =>
            processMessage(value.asInstanceOf[T])

          case Result.Value.MutactionResult(value) =>
            processMessage(value.asInstanceOf[T])

          case Result.Value.Empty =>
            processMessage((Seq.empty[Node], Seq.empty[String]).asInstanceOf[T])
        }

      // Error cases
      case RpcResponse.Response.Error(error: Error) =>
        def defaultHandler(error: Error.Value): Throwable = error match {
          case Error.Value.ConnectionError(str)            => ConnectionError(str)
          case Error.Value.InvalidInputError(str)          => InvalidInputError(str)
          case Error.Value.JsonDecodeError(str)            => JsonDecodeError(str)
          case Error.Value.NoResultsError(str)             => NoResultError(str)
          case Error.Value.ProtobufDecodeError(str)        => ProtobufDecodeError(str)
          case Error.Value.QueryError(str)                 => QueryError(str)
          case Error.Value.InvalidConnectionArguments(str) => InvalidConnectionArguments(str)
          case Error.Value.UniqueConstraintViolation(str)  => UniqueConstraintViolation(str)
          case Error.Value.InternalServerError(msg)        => new NativeError(msg)
          case Error.Value.Empty                           => sys.error("Empty RPC response error value")
          case x                                           => sys.error(s"unhandled error: $x")
        }

        val exception = errorHandler.applyOrElse(error.value, defaultHandler)
        throw exception

      case RpcResponse.Response.Empty => sys.error("Empty RPC response value")
    }
  }

  def writeBuffer[T](msg: GeneratedMessage): (Pointer, Int) = {
    val length       = msg.serializedSize
    val serialized   = msg.toByteArray
    val nativeMemory = new Memory(length)

    nativeMemory.write(0, serialized, 0, length)
    (nativeMemory, length)
  }
}
