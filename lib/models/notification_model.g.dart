// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'notification_model.dart';

class NotificationModelAdapter extends TypeAdapter<NotificationModel> {
  @override
  final int typeId = 6;

  @override
  NotificationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationModel(
      id: fields[0] as String,
      type: fields[1] as TypeNotification,
      titre: fields[2] as String,
      message: fields[3] as String,
      date: fields[4] as DateTime,
      estLue: fields[5] as bool,
      donneeId: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.titre)
      ..writeByte(3)
      ..write(obj.message)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.estLue)
      ..writeByte(6)
      ..write(obj.donneeId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}