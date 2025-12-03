// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArticleModelAdapter extends TypeAdapter<ArticleModel> {
  @override
  final int typeId = 0;

  @override
  ArticleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ArticleModel(
      modelArticleId: fields[0] as String?,
      modelTitle: fields[1] as String,
      modelDescription: fields[2] as String?,
      modelImageUrl: fields[3] as String?,
      modelSourceUrl: fields[4] as String?,
      modelPubDate: fields[5] as DateTime,
      modelCategory: fields[6] as String?,
      cachedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ArticleModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.modelArticleId)
      ..writeByte(1)
      ..write(obj.modelTitle)
      ..writeByte(2)
      ..write(obj.modelDescription)
      ..writeByte(3)
      ..write(obj.modelImageUrl)
      ..writeByte(4)
      ..write(obj.modelSourceUrl)
      ..writeByte(5)
      ..write(obj.modelPubDate)
      ..writeByte(6)
      ..write(obj.modelCategory)
      ..writeByte(7)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
