import 'package:json_annotation/json_annotation.dart';

part 'item.g.dart';

@JsonSerializable()
class Item {
  final int id;
  final String code;
  final String name;
  final String unit;
  final String image;

  @JsonKey(name: 'total_item')
  final int total;

  @JsonKey(name: 'unit_price')
  final double price;

  @JsonKey(name: 'expired_date')
  final String expiredDate;

  Item({
    required this.id,
    required this.code,
    required this.name,
    required this.unit,
    required this.image,
    required this.total,
    required this.price,
    required this.expiredDate,
  });

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
  Map<String, dynamic> toJson() => _$ItemToJson(this);
}

@JsonSerializable()
class ItemResponse {
  final List<Item> items;

  ItemResponse({
    required this.items,
  });

  factory ItemResponse.fromJson(Map<String, dynamic> json) =>
      _$ItemResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ItemResponseToJson(this);
}
