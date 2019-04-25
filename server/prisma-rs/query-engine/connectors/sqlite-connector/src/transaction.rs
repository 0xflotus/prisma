use crate::{PrismaRow, SelectDefinition};
use connector::{
    error::*,
    filter::{Filter, NodeSelector},
    ConnectorResult,
};
use prisma_models::{GraphqlId, ModelRef, RelationFieldRef, TypeIdentifier};
use prisma_query::ast::{Query, Select};
use std::{convert::TryFrom, sync::Arc};

/// A `Transactional` presents a database able to spawn transactions, execute
/// queries in the transaction and commit the results to the database or do a
/// rollback in case of an error.
pub trait Transactional {
    /// Wrap a closure into a transaction. All actions done through the
    /// `Transaction` are commited automatically, or rolled back in case of any
    /// error.
    fn with_transaction<F, T>(&mut self, db: &str, f: F) -> ConnectorResult<T>
    where
        F: FnOnce(&mut Transaction) -> ConnectorResult<T>;
}

/// Abstraction of a database transaction. Start, commit and rollback should be
/// handled per-database basis, `Transaction` providing a minimal interface over
/// different databases.
pub trait Transaction {
    /// Write to the database, expecting no result data. On success, returns the
    /// number of rows that were changed, inserted, or deleted.
    fn write(&mut self, q: Query) -> ConnectorResult<usize>;

    /// Select multiple rows from the database.
    fn filter(&mut self, q: Select, idents: &[TypeIdentifier]) -> ConnectorResult<Vec<PrismaRow>>;

    /// Select one row from the database.
    fn find(&mut self, q: Select, idents: &[TypeIdentifier]) -> ConnectorResult<PrismaRow> {
        self.read(q.limit(1), idents)?
            .into_iter()
            .next()
            .ok_or(ConnectorError::NodeDoesNotExist)
    }

    /// Read the first column from the first row as an integer.
    fn find_int(&mut self, q: Select) -> ConnectorResult<i64> {
        // UNWRAP: A dataset will always have at least one column, even if it contains no data.
        let id = self
            .read_one(q, &[TypeIdentifier::Int])?
            .values
            .into_iter()
            .next()
            .unwrap();

        Ok(i64::try_from(id)?)
    }

    /// Read the first column from the first row as an `GraphqlId`.
    fn find_id(&mut self, node_selector: &NodeSelector) -> ConnectorResult<GraphqlId> {
        let model = node_selector.field.model();
        let q = node_selector.into_select(Arc::clone(&model));

        let id = self
            .read_ids(model, q)?
            .into_iter()
            .next()
            .ok_or_else(|| ConnectorError::NodeNotFoundForWhere(NodeSelectorInfo::from(node_selector)))?;

        Ok(id)
    }

    /// Read the all columns as an `GraphqlId`
    fn filter_ids(&mut self, model: ModelRef, filter: Filter) -> ConnectorResult<Vec<GraphqlId>> {
        let select = Select::from_table(model.table())
            .column(model.fields().id().as_column())
            .so_that(filter.aliased_cond(None));

        let mut rows = self.read(select, &[TypeIdentifier::GraphQLID])?;
        let mut result = Vec::new();

        for mut row in rows.drain(0..) {
            for value in row.values.drain(0..) {
                result.push(GraphqlId::try_from(value)?)
            }
        }

        Ok(result)
    }

    /// Find a child of a parent. Will return an error if no child found with
    /// the given parameters. A more restrictive version of `get_ids_by_parents`.
    fn find_id_by_parent(
        &mut self,
        parent_field: RelationFieldRef,
        parent_id: &GraphqlId,
        selector: &Option<NodeSelector>,
    ) -> ConnectorResult<GraphqlId> {
        let ids = self.filter_ids_by_parents(Arc::clone(&parent_field), vec![parent_id], selector.clone())?;

        let id = ids
            .into_iter()
            .next()
            .ok_or_else(|| ConnectorError::NodesNotConnected {
                relation_name: parent_field.relation().name.clone(),
                parent_name: parent_field.model().name.clone(),
                parent_where: None,
                child_name: parent_field.related_model().name.clone(),
                child_where: selector.as_ref().map(NodeSelectorInfo::from),
            })?;

        Ok(id)
    }

    /// Find all children node id's with the given parent id's, optionally given
    /// a `Filter` for extra filtering.
    fn filter_ids_by_parents(
        &mut self,
        parent_field: RelationFieldRef,
        parent_ids: Vec<&GraphqlId>,
        selector: Option<Filter>,
    ) -> ConnectorResult<Vec<GraphqlId>> {
        let related_model = parent_field.related_model();
        let relation = parent_field.relation();
        let child_id_field = relation.column_for_relation_side(parent_field.relation_side.opposite());
        let parent_id_field = relation.column_for_relation_side(parent_field.relation_side);

        let base_filter = parent_id_field.every_related(related_model.fields().id().in_selection(parent_ids));

        let filter = selector
            .into_iter()
            .fold(base_filter, |acc, filter| acc.and(vec![filter]));

        self.filter_ids(related_model, filter)
    }
}
