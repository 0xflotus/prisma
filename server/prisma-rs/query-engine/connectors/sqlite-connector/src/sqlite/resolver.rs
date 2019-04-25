use crate::{query_builder::QueryBuilder, Sqlite, Transactional};
use connector::{error::ConnectorError, filter::NodeSelector, *};
use itertools::Itertools;
use prisma_models::*;
use std::convert::TryFrom;

impl DataResolver for Sqlite {
    fn get_node_by_where(
        &self,
        node_selector: &NodeSelector,
        selected_fields: &SelectedFields,
    ) -> ConnectorResult<Option<SingleNode>> {
        let db_name = &node_selector.field.model().schema().db_name;
        let query = QueryBuilder::get_nodes(node_selector.field.model(), selected_fields, node_selector);
        let field_names = selected_fields.names();
        let idents = selected_fields.type_identifiers();

        let node = self
            .with_transaction(db_name, |conn| match conn.find(query, idents.as_slice()) {
                Ok(result) => Ok(Some(result)),
                Err(_e @ ConnectorError::NodeNotFoundForWhere(_)) => Ok(None),
                Err(e) => Err(e),
            })?
            .map(Node::from)
            .map(|node| SingleNode { node, field_names });

        Ok(node)
    }

    fn get_nodes(
        &self,
        model: ModelRef,
        query_arguments: QueryArguments,
        selected_fields: &SelectedFields,
    ) -> ConnectorResult<ManyNodes> {
        let db_name = &model.schema().db_name;
        let field_names = selected_fields.names();
        let idents = selected_fields.type_identifiers();
        let query = QueryBuilder::get_nodes(model, selected_fields, query_arguments);

        let nodes = self
            .with_transaction(db_name, |conn| conn.filter(query, idents.as_slice()))?
            .into_iter()
            .map(Node::from)
            .collect();

        Ok(ManyNodes { nodes, field_names })
    }

    fn get_related_nodes(
        &self,
        from_field: RelationFieldRef,
        from_node_ids: &[GraphqlId],
        query_arguments: QueryArguments,
        selected_fields: &SelectedFields,
    ) -> ConnectorResult<ManyNodes> {
        let db_name = &from_field.model().schema().db_name;
        let idents = selected_fields.type_identifiers();
        let field_names = selected_fields.names();
        let query = QueryBuilder::get_related_nodes(from_field, from_node_ids, query_arguments, selected_fields);

        let nodes: ConnectorResult<Vec<Node>> = self
            .with_transaction(db_name, |conn| conn.filter(query, idents.as_slice()))?
            .into_iter()
            .map(|mut row| {
                // Unwrap: Parent id is always in the end.
                let parent_id = row.values.pop().ok_or()?;

                // Unwrap: Relation id is always the second last.
                // also, we don't need it here and we don't need it in the node.
                let _ = row.values.pop();

                let mut node = Node::from(row);

                node.add_parent_id(GraphqlId::try_from(parent_id)?);

                Ok(node)
            })
            .collect();

        Ok(ManyNodes {
            nodes: nodes?,
            field_names,
        })
    }

    fn count_by_model(&self, model: ModelRef, query_arguments: QueryArguments) -> ConnectorResult<usize> {
        let db_name = &model.schema().db_name;
        let table = model.table();
        let query = QueryBuilder::count_by_model(model, query_arguments);

        self.with_transaction(db_name, |conn| Self::count(conn, table, query))
    }

    fn count_by_table(&self, database: &str, table: &str) -> ConnectorResult<usize> {
        let query = QueryBuilder::count_by_table(database, table);
        self.with_transaction(database, |conn| Self::count(conn, table, query))
    }

    fn get_scalar_list_values_by_node_ids(
        &self,
        list_field: ScalarFieldRef,
        node_ids: Vec<GraphqlId>,
    ) -> ConnectorResult<Vec<ScalarListValues>> {
        let db_name = &list_field.model().schema().db_name;
        let type_identifier = list_field.type_identifier;
        let query = QueryBuilder::get_scalar_list_values_by_node_ids(list_field, node_ids);

        let results = self.with_transaction(db_name, |conn| {
            Self::query(conn, query, |row| {
                let node_id: GraphqlId = row.get(0);
                let value: PrismaValue = Sqlite::fetch_value(type_identifier, row, 2)?;

                Ok(ScalarListElement { node_id, value })
            })
        })?;

        let mut list_values = Vec::new();

        for (node_id, elements) in &results.into_iter().group_by(|ele| ele.node_id.clone()) {
            let values = ScalarListValues {
                node_id,
                values: elements.into_iter().map(|e| e.value).collect(),
            };
            list_values.push(values);
        }

        Ok(list_values)
    }
}

struct ScalarListElement {
    node_id: GraphqlId,
    value: PrismaValue,
}
