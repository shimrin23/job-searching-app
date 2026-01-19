import 'package:hive/hive.dart';
import 'job_model.dart';

class JobModelAdapter extends TypeAdapter<JobModel> {
  @override
  final int typeId = 1;

  @override
  JobModel read(BinaryReader reader) {
    return JobModel(
      id: reader.readString(),
      title: reader.readString(),
      company: reader.readString(),
      companyLogoUrl: reader.readString(),
      location: reader.readString(),
      workLocation: reader.readString(),
      jobType: reader.readString(),
      description: reader.readString(),
      responsibilities: (reader.readList()).cast<String>(),
      requirements: (reader.readList()).cast<String>(),
      benefits: (reader.readList()).cast<String>(),
      salaryRange: reader.readString(),
      experienceLevel: reader.readString(),
      skills: (reader.readList()).cast<String>(),
      applyUrl: reader.readString(),
      postedDate: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      deadline: reader.readInt() == 0
          ? null
          : DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      isSaved: reader.readBool(),
      isApplied: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, JobModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.company);
    writer.writeString(obj.companyLogoUrl ?? '');
    writer.writeString(obj.location);
    writer.writeString(obj.workLocation);
    writer.writeString(obj.jobType);
    writer.writeString(obj.description);
    writer.writeList(obj.responsibilities);
    writer.writeList(obj.requirements);
    writer.writeList(obj.benefits);
    writer.writeString(obj.salaryRange ?? '');
    writer.writeString(obj.experienceLevel ?? '');
    writer.writeList(obj.skills);
    writer.writeString(obj.applyUrl ?? '');
    writer.writeInt(obj.postedDate.millisecondsSinceEpoch);
    writer.writeInt(obj.deadline?.millisecondsSinceEpoch ?? 0);
    writer.writeBool(obj.isSaved);
    writer.writeBool(obj.isApplied);
  }
}
