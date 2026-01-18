class CreateComplaintRequest {
  final String title;
  final String description;

  CreateComplaintRequest({
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
      };
}

