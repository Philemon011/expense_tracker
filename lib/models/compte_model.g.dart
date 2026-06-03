// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'compte_model.dart';

class CompteModelAdapter extends TypeAdapter<CompteModel> {
  @override
  final int typeId = 3;

  @override
  CompteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompteModel(
      id: fields[0] as String,
      nom: fields[1] as String,
      type: fields[2] as TypeCompte,
      soldeInitial: fields[3] as double,
      couleurValue: fields[4] as int,
      iconeCode: fields[5] as int,
      devise: fields[6] as String,
      estPrincipal: fields[7] as bool,
      estArchive: fields[8] as bool,
      createdAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CompteModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nom)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.soldeInitial)
      ..writeByte(4)
      ..write(obj.couleurValue)
      ..writeByte(5)
      ..write(obj.iconeCode)
      ..writeByte(6)
      ..write(obj.devise)
      ..writeByte(7)
      ..write(obj.estPrincipal)
      ..writeByte(8)
      ..write(obj.estArchive)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}