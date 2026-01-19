import 'package:hive/hive.dart';
import 'user_model.dart';

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numFields = reader.availableBytes;

    final id = reader.readString();
    final email = reader.readString();
    final name = reader.readString();
    final phone = reader.readString();

    // Handle old cache format that doesn't have profileImageUrl
    String? profileImageUrl;
    String? resumeUrl;
    List<String> skills = [];
    String? location;
    DateTime createdAt = DateTime.now();
    DateTime? updatedAt;

    try {
      profileImageUrl = reader.readString();
      resumeUrl = reader.readString();
      skills = (reader.readList()).cast<String>();
      location = reader.readString();
      createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
      final updatedAtInt = reader.readInt();
      updatedAt = updatedAtInt == 0
          ? null
          : DateTime.fromMillisecondsSinceEpoch(updatedAtInt);
    } catch (e) {
      // Old format - set defaults
      skills = [];
      location = '';
    }

    return UserModel(
      id: id,
      email: email,
      name: name,
      phone: phone,
      profileImageUrl: profileImageUrl,
      resumeUrl: resumeUrl,
      skills: skills,
      location: location,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.email);
    writer.writeString(obj.name ?? '');
    writer.writeString(obj.phone ?? '');
    writer.writeString(obj.profileImageUrl ?? '');
    writer.writeString(obj.resumeUrl ?? '');
    writer.writeList(obj.skills);
    writer.writeString(obj.location ?? '');
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.updatedAt?.millisecondsSinceEpoch ?? 0);
  }
}
