import 'package:hive/hive.dart';
import 'notification.dart';

class NotificationAdapter extends TypeAdapter<Notifications> {
  @override
  final typeId = 1;

  @override
  Notifications read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Notifications(
      id: fields[0] as String,
      title: fields[1] as String,
      body: fields[2] as String,
      viewed: fields[3] as bool,
      media: fields[4] as String
    );
  }

  @override
  void write(BinaryWriter writer, Notifications obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.viewed)
      ..writeByte(4)
      ..write(obj.media);
  }
}