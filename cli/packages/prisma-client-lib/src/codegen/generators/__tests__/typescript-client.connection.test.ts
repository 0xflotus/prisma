import * as fs from 'fs'
import * as path from 'path'
import { buildSchema } from 'graphql'
import { TypescriptGenerator } from '../typescript-client'
import { test } from 'ava'
import { fixturesPath } from './fixtures'
import { parseInternalTypes } from 'prisma-generate-schema'
import { DatabaseType } from 'prisma-datamodel'

const typeDefs = fs.readFileSync(
  path.join(fixturesPath, 'connection.graphql'),
  'utf-8',
)
test('typescript generator - connection', t => {
  const schema = buildSchema(typeDefs)
  const generator = new TypescriptGenerator({
    schema,
    internalTypes: parseInternalTypes(typeDefs, DatabaseType.mysql).types,
  })
  const result = generator.render()
  t.snapshot(result)
})
