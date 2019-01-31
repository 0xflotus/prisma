import NormalizerGroup from './normalizerGroup'
import ModelNameAndDirectiveNormalizer from './modelNameAndDirectiveNormalizer'
import ModelOrderNormalizer from './modelOrderNormalizer'
import { ISDL, DatabaseType } from 'prisma-datamodel'
import { SpecialFieldNormalizer } from './specialFieldNormalizer'

export default abstract class DefaultNormalizer {
  public static create(databaseType: DatabaseType, baseModel: ISDL | null) {
    if(baseModel === null) {
      return this.createWithoutBaseModel(databaseType)
    } else {
      return this.createWithBaseModel(databaseType, baseModel)
    }
  }

  public static createWithoutBaseModel(databaseType: DatabaseType) {
    if(databaseType === DatabaseType.mongo) {
      return new NormalizerGroup([
        new ModelNameAndDirectiveNormalizer(null)
      ])
    } else {
      return new NormalizerGroup([
        new ModelNameAndDirectiveNormalizer(null)
      ])
    }
  }

  public static createWithBaseModel(databaseType: DatabaseType, baseModel: ISDL) {
    if(databaseType === DatabaseType.mongo) {
      return new NormalizerGroup([
        new ModelNameAndDirectiveNormalizer(baseModel),
        new ModelOrderNormalizer(baseModel)
      ])
    } else {
      return new NormalizerGroup([
        new ModelNameAndDirectiveNormalizer(baseModel),
        new ModelOrderNormalizer(baseModel),
        new SpecialFieldNormalizer(baseModel)
      ])
    }
  }
}