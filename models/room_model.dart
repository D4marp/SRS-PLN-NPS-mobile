class RoomModel {
  final String id;
  final String name;
  final String description;
  final String location;
  final String city;
  final String roomClass; // Room category: Meeting Room, Class Room, Conference Room, etc.
  final List<String> imageUrls;
  final List<String> amenities;
  final bool hasAC;
  final bool isAvailable;
  final int maxGuests;
  final String contactNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? floor; // Floor number or location
  final String? building; // Building name

  RoomModel({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.city,
    required this.roomClass,
    required this.imageUrls,
    required this.amenities,
    required this.hasAC,
    required this.isAvailable,
    required this.maxGuests,
    required this.contactNumber,
    required this.createdAt,
    this.updatedAt,
    this.floor,
    this.building,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      roomClass: json['roomClass'] ?? 'Meeting Room',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      hasAC: json['hasAC'] ?? false,
      isAvailable: json['isAvailable'] ?? true,
      maxGuests: json['maxGuests'] ?? 10,
      contactNumber: json['contactNumber'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : null,
      floor: json['floor'],
      building: json['building'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'city': city,
      'roomClass': roomClass,
      'imageUrls': imageUrls,
      'amenities': amenities,
      'hasAC': hasAC,
      'isAvailable': isAvailable,
      'maxGuests': maxGuests,
      'contactNumber': contactNumber,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'floor': floor,
      'building': building,
    };
  }

  RoomModel copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    String? city,
    String? roomClass,
    List<String>? imageUrls,
    List<String>? amenities,
    bool? hasAC,
    bool? isAvailable,
    int? maxGuests,
    String? contactNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? floor,
    String? building,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      city: city ?? this.city,
      roomClass: roomClass ?? this.roomClass,
      imageUrls: imageUrls ?? this.imageUrls,
      amenities: amenities ?? this.amenities,
      hasAC: hasAC ?? this.hasAC,
      isAvailable: isAvailable ?? this.isAvailable,
      maxGuests: maxGuests ?? this.maxGuests,
      contactNumber: contactNumber ?? this.contactNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      floor: floor ?? this.floor,
      building: building ?? this.building,
    );
  }

  String get capacityInfo => 'Capacity: $maxGuests people';

  String get locationInfo {
    final parts = <String>[];
    if (building != null && building!.isNotEmpty) parts.add(building!);
    if (floor != null && floor!.isNotEmpty) parts.add('Floor $floor');
    if (parts.isEmpty) return location;
    return '${parts.join(', ')} - $location';
  }

  String get primaryImageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  bool get hasImages => imageUrls.isNotEmpty;
}
