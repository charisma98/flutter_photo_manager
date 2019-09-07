part of '../photo_manager.dart';

/// asset entity, for entity info.
class AssetPathEntity {
  /// id
  ///
  /// in ios is localIdentifier
  ///
  /// in android is content provider database _id column
  String id;

  /// name
  ///
  /// in android is path name
  ///
  /// in ios is photos gallery name
  String name;

  /// gallery asset count
  int assetCount;

  RequestType _type;

  /// The value used internally by the user.
  /// Used to indicate the value that should be available inside the path.
  RequestType get type => _type;

  set type(RequestType type) {
    _type = type;
    typeInt = type.index;
  }

  /// Users should not edit this value.
  ///
  /// This is a field used internally by the library.
  int typeInt = 0;

  bool isAll = false;

  AssetPathEntity({this.id, this.name});

  /// the image entity list with pagination
  ///
  /// Doesn't support AssetPathEntity with only(Video/Image) flag.
  /// Throws UnsupportedError
  ///
  /// [page] is starting 0.
  ///
  /// [pageSize] is item count of page.
  ///
  Future<List<AssetEntity>> getAssetListPaged(int page, int pageSize) =>
      PhotoManager._getAssetListPaged(this, page, pageSize);

  Future<List<AssetEntity>> get assetList =>
      PhotoManager._getAssetListPaged(this, 0, assetCount);

  @override
  bool operator ==(other) {
    if (other is! AssetPathEntity) {
      return false;
    }
    return this.id == other.id;
  }

  @override
  int get hashCode {
    return this.id.hashCode;
  }

  @override
  String toString() {
    return "AssetPathEntity{ name: $name id:$id , length = $assetCount}";
  }
}

/// Used to describe a picture or video
class AssetEntity {
  /// in android is full path
  ///
  /// in ios is local id
  String id;

  /// see [id]
  AssetEntity({this.id});

  /// the asset type
  ///
  /// see [AssetType]
  AssetType get type {
    switch (typeInt) {
      case 1:
        return AssetType.image;
      case 2:
        return AssetType.video;
      default:
        return AssetType.other;
    }
  }

  /// Asset type int value.
  ///
  /// see [type]
  int typeInt;

  /// Duration of video, unit is second.
  ///
  /// If [type] is [AssetType.image], then it's value is 0.
  int duration;

  /// width of asset.
  int width;

  /// height of asset.
  int height;

  /// if you need upload file ,then you can use the file, nullable.
  Future<File> get file async => PhotoManager._getFileWithId(this.id);

  /// This contains all the EXIF information, but in contrast, `Image` widget may not be able to display pictures.
  ///
  /// Usually, you can use the [file] attribute
  Future<File> get originFile async =>
      PhotoManager._getFileWithId(id, isOrigin: true);

  /// the image's bytes ,
  Future<Uint8List> get fullData => PhotoManager._getFullDataWithId(id);

  /// thumb data , for display
  Future<Uint8List> get thumbData => PhotoManager._getThumbDataWithId(id);

  /// get thumb with size
  Future<Uint8List> thumbDataWithSize(int width, int height) {
    return PhotoManager._getThumbDataWithId(id, width: width, height: height);
  }

  /// if not video ,duration is null
  Duration get videoDuration => Duration(seconds: duration);

  /// nullable, if the manager is null.
  Size get size => Size(width.toDouble(), height.toDouble());

  /// unix timestamp of asset, milliseconds
  int createTime;

  /// create time of asset
  DateTime get createDateTime {
    return DateTime.fromMillisecondsSinceEpoch(createTime ?? 0);
  }

  /// If the asset is deleted, return false.
  Future<bool> get exists => PhotoManager._assetExistsWithId(id);

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(other) {
    if (other is! AssetEntity) {
      return false;
    }
    return this.id == other.id;
  }

  @override
  String toString() {
    return "AssetEntity{id:$id}";
  }
}
