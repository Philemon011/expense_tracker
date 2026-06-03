// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'budget_model.dart';

class BudgetModelAdapter extends TypeAdapter<BudgetModel> {
  @override
  final int typeId = 4;

  @override
  BudgetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BudgetModel(
      id: fields[0] as String,
      categorieId: fields[1] as String,
      montantMax: fields[2] as double,
      mois: fields[3] as int,
      annee: fields[4] as int,
      estRecurrent: fields[5] as bool,
      createdAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categorieId)
      ..writeByte(2)
      ..write(obj.montantMax)
      ..writeByte(3)
      ..write(obj.mois)
      ..writeByte(4)
      ..write(obj.annee)
      ..writeByte(5)
      ..write(obj.estRecurrent)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}