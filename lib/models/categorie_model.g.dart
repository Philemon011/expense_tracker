// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'categorie_model.dart';

class CategorieModelAdapter extends TypeAdapter<CategorieModel> {
  @override
  final int typeId = 2;

  @override
  CategorieModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategorieModel(
      id: fields[0] as String,
      nom: fields[1] as String,
      iconeCode: fields[2] as int,
      couleurValue: fields[3] as int,
      typeOperation: fields[4] as String,
      estParDefaut: fields[5] as bool,
      ordre: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CategorieModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.iconeCode)
      ..writeByte(3)
      ..write(obj.couleurValue)
      ..writeByte(4)
      ..write(obj.typeOperation)
      ..writeByte(5)
      ..write(obj.estParDefaut)
      ..writeByte(6)
      ..write(obj.ordre);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategorieModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}