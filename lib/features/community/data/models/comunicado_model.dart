import '../../domain/entities/comunicado.dart';

class ComunicadoModel extends Comunicado {
  const ComunicadoModel({
    required super.id,
    required super.title,
    required super.content,
    required super.authorId,
    required super.publishDate,
    required super.expirationDate,
  });

  factory ComunicadoModel.fromJson(Map<String, dynamic> json) {
    return ComunicadoModel(
      id: json['id_comunicado'] as String,
      title: json['titulo'] as String,
      content: json['contenido'] as String,
      authorId: json['id_autor'] as String,
      publishDate: DateTime.parse(json['fecha_publicacion'] as String),
      expirationDate: DateTime.parse(json['fecha_vigencia'] as String),
    );
  }
}
