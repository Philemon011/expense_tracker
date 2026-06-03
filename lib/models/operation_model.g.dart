// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'operation_model.dart';

/// TypeAdapter généré pour OperationModel.
/// Permet à Hive de lire et écrire des objets OperationModel.
class OperationModelAdapter extends TypeAdapter<OperationModel> {
  @override
  final int typeId = 0;

  @override
  OperationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OperationModel(
      id: fields[0] as String,
      montant: fields[1] as double,
      type: fields[2] as TypeOperation,
      categorieId: fields[3] as String,
      compteId: fields[4] as String,
      date: fields[5] as DateTime,
      note: fields[6] as String?,
      createdAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, OperationModel obj) {
    writer
      ..writeByte(8) // nombre de champs
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.montant)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.categorieId)
      ..writeByte(4)
      ..write(obj.compteId)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}