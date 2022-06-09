// ignore_for_file: file_names
class SongInfo {
  final int? id;
  final String songName;
  final String songPath;
  final String imagePath;

  const SongInfo(
      {this.id,
      required this.songName,
      required this.songPath,
      required this.imagePath});

  factory SongInfo.fromJson(Map<String, dynamic> json) => SongInfo(
        songName: json['songName'],
        imagePath: json['imagePath'],
        songPath: json['songPath'],
      );

  Map<String, dynamic> toJson() => {
        'songName': songName,
        'imagePath': imagePath,
        'songPath': songPath,
      };
}
