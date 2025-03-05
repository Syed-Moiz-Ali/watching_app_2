class CategoryModel {
  final String title;
  final String id;
  final String image;

  CategoryModel({
    required this.title,
    required this.id,
    required this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      title: json['title'],
      id: json['id'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'id': id,
      'image': image,
    };
  }
}
