enum MassageType {
  text,
  image,
  video,
  audio,
  file,
  sticker,
}

extension MassageTypeExtension on String {
  MassageType get massageTypeFromString {
    switch (this) {
      case 'text':
        return MassageType.text;
      case 'image':
        return MassageType.image;
      case 'video':
        return MassageType.video;
      case 'audio':
        return MassageType.audio;
      case 'file':
        return MassageType.file;
      case 'sticker':
        return MassageType.sticker;
      default:
        return MassageType.text;
    }
  }
}