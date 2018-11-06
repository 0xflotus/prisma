package com.prisma.deploy.migration.validation

import com.prisma.deploy.connector.FieldRequirementsInterface
import com.prisma.deploy.specutils.DeploySpecBase
import com.prisma.gc_values.StringGCValue
import com.prisma.shared.models.ApiConnectorCapability.{EmbeddedScalarListsCapability, NonEmbeddedScalarListCapability}
import com.prisma.shared.models.ConnectorCapability
import com.prisma.shared.models.FieldBehaviour._
import org.scalactic.{Bad, Good, Or}
import org.scalatest.{Matchers, WordSpecLike}

class DataModelValidatorSpec extends WordSpecLike with Matchers with DeploySpecBase {
  "@id without explicit strategy should work" in {
    val dataModelString =
      """
        |type Model {
        |  id: ID! @id
        |}
      """.stripMargin
    val dataModel = validate(dataModelString)
    dataModel.type_!("Model").scalarField_!("id").behaviour should be(Some(IdBehaviour(IdStrategy.Auto)))
  }

  "@id should work with explicit default strategy" in {
    val dataModelString =
      """
        |type Model {
        |  id: ID! @id(strategy: AUTO)
        |}
      """.stripMargin

    val dataModel = validate(dataModelString)
    dataModel.type_!("Model").scalarField_!("id").behaviour should be(Some(IdBehaviour(IdStrategy.Auto)))
  }

  "@id should work with NONE strategy" in {
    val dataModelString =
      """
        |type Model {
        |  id: ID! @id(strategy: NONE)
        |}
      """.stripMargin
    val dataModel = validate(dataModelString)
    dataModel.type_!("Model").scalarField_!("id").behaviour should be(Some(IdBehaviour(IdStrategy.None)))
  }

  "@id should error on embedded types" in {
    val dataModelString =
      """
        |type Model @embedded {
        |  id: ID! @id(strategy: NONE)
        |}
      """.stripMargin
    val error = validateThatMustError(dataModelString).head
    error.`type` should equal("Model")
    error.field should equal(Some("id"))
    error.description should equal("The `@id` directive is not allowed on embedded types.")
  }

  "a type without @id should error" in {
    val dataModelString =
      """
        |type Model {
        |  id: ID!
        |}
      """.stripMargin
    val error = validateThatMustError(dataModelString).head
    error.`type` should equal("Model")
    error.field should equal(None)
    error.description should equal("One field of the type `Model` must be marked as the id field with the `@id` directive.")
  }

  "@createdAt should be detected" in {
    val dataModelString =
      """
        |type Model {
        |  id: ID! @id
        |  myCreatedAt: DateTime! @createdAt
        |}
      """.stripMargin
    val dataModel = validate(dataModelString)
    dataModel.type_!("Model").scalarField_!("myCreatedAt").behaviour should be(Some(CreatedAtBehaviour))
  }

  "@createdAt should error if the type of the field is not correct" in {
    val dataModelString =
      """
        |type Model {
        |  id: ID! @id
        |  createdAt: String! @createdAt
        |}
      """.stripMargin
    val error = validateThatMustError(dataModelString).head
    error.`type` should equal("Model")
    error.field should equal(Some("createdAt"))
    error.description should equal("Fields that are marked as @createdAt must be of type `DateTime!`.")
  }

  "@createdAt should error if the type of the field is not required" in {
    val dataModelString =
      """
        |type Model {
        |  id: ID! @id
        |  createdAt: DateTime @createdAt
        |}
      """.stripMargin
    val error = validateThatMustError(dataModelString).head
    error.`type` should equal("Model")
    error.field should equal(Some("createdAt"))
    error.description should equal("Fields that are marked as @createdAt must be of type `DateTime!`.")
  }

  "@updatedAt should be detected" in {
    val dataModelString =
      """
        |type Model {
        |  id: ID! @id
        |  myUpdatedAt: DateTime! @updatedAt
        |}
      """.stripMargin
    val dataModel = validate(dataModelString)
    dataModel.type_!("Model").scalarField_!("myUpdatedAt").behaviour should be(Some(UpdatedAtBehaviour))
  }

  "@updatedAt should error if the type of the field is not correct" in {
    val dataModelString =
      """
        |type Model {
        |  id: ID! @id
        |  updatedAt: String! @updatedAt
        |}
      """.stripMargin
    val error = validateThatMustError(dataModelString).head
    error.`type` should equal("Model")
    error.field should equal(Some("updatedAt"))
    error.description should equal("Fields that are marked as @updatedAt must be of type `DateTime!`.")
  }

  "@updatedAt should error if the type of the field is not required" in {
    val dataModelString =
      """
        |type Model {
        |  id: ID! @id
        |  updatedAt: DateTime @updatedAt
        |}
      """.stripMargin
    val error = validateThatMustError(dataModelString).head
    error.`type` should equal("Model")
    error.field should equal(Some("updatedAt"))
    error.description should equal("Fields that are marked as @updatedAt must be of type `DateTime!`.")
  }

  "@scalarList should be optional" in {
    val dataModelString =
      """
        |type Model {
        |  id: ID! @id
        |  tags: [String!]
        |}
      """.stripMargin
    val dataModel = validate(dataModelString, Set(NonEmbeddedScalarListCapability))
    dataModel.type_!("Model").scalarField_!("tags").behaviour should be(Some(ScalarListBehaviour(ScalarListStrategy.Relation)))

    val dataModel2 = validate(dataModelString, Set(EmbeddedScalarListsCapability))
    dataModel2.type_!("Model").scalarField_!("tags").behaviour should be(Some(ScalarListBehaviour(ScalarListStrategy.Embedded)))
  }

  "@scalarList must fail if an invalid argument is provided" in {
    val dataModelString =
      """
        |type Model {
        |  id: ID! @id
        |  tags: [String!] @scalarList(strategy: FOOBAR)
        |}
      """.stripMargin
    val error = validateThatMustError(dataModelString).head
    error.`type` should equal("Model")
    error.field should equal(Some("tags"))
    error.description should include("Valid values for the strategy argument of `@scalarList` are:")
  }

  "@default should work" in {
    val dataModelString =
      """
        |type Model {
        |  id: ID! @id
        |  field: String! @default(value: "my_value")
        |}
      """.stripMargin

    val dataModel = validate(dataModelString)
    val field     = dataModel.type_!("Model").scalarField_!("field")
    field.defaultValue should be(Some(StringGCValue("some_columns")))
  }

  "@default should error if the provided value does not match the field type" in {
    val dataModelString =
      """
        |type Model {
        |  id: ID! @id
        |  field: String! @default(value: true)
        |}
      """.stripMargin

    val error = validateThatMustError(dataModelString).head
    error.`type` should equal("Model")
    error.field should equal(Some("field"))
    error.description should include("asjdfk")
  }

  "@db should work" in {
    val dataModelString =
      """
        |type Model {
        |  id: ID! @id
        |  field: String @db(name: "some_columns")
        |}
      """.stripMargin

    val dataModel = validate(dataModelString)
    val field     = dataModel.type_!("Model").scalarField_!("field")
    field.columnName should be(Some("some_columns"))
  }

  def validateThatMustError(dataModel: String, capabilities: Set[ConnectorCapability] = Set.empty): Vector[DeployError] = {
    val result = validateInternal(dataModel, capabilities)
    result match {
      case Good(dm)    => sys.error("The validation did not produce an error, which was expected.")
      case Bad(errors) => errors
    }
  }

  def validate(dataModel: String, capabilities: Set[ConnectorCapability] = Set.empty) = {
    val result = validateInternal(dataModel, capabilities)
    result match {
      case Good(dm) => dm
      case Bad(errors) =>
        sys.error {
          s"""The validation returned the following unexpected errors:
          |   ${errors.mkString("\n")}
        """.stripMargin
        }
    }
  }

  def validateInternal(dataModel: String, capabilities: Set[ConnectorCapability]): Or[PrismaSdl, Vector[DeployError]] = {
    val requirements = new FieldRequirementsInterface {
      override val requiredReservedFields    = Vector.empty
      override val hiddenReservedField       = Vector.empty
      override val reservedFieldRequirements = Vector.empty
      override val isAutogenerated           = false
    }
    DataModelValidatorImpl.validate(dataModel, requirements, capabilities)
  }
}