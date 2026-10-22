// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CatalogItem {

 int get tmdbId; MediaType get mediaType; String get title; int? get year; String? get posterPath; bool get isAnime;
/// Create a copy of CatalogItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogItemCopyWith<CatalogItem> get copyWith => _$CatalogItemCopyWithImpl<CatalogItem>(this as CatalogItem, _$identity);

  /// Serializes this CatalogItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogItem&&(identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.title, title) || other.title == title)&&(identical(other.year, year) || other.year == year)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.isAnime, isAnime) || other.isAnime == isAnime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tmdbId,mediaType,title,year,posterPath,isAnime);

@override
String toString() {
  return 'CatalogItem(tmdbId: $tmdbId, mediaType: $mediaType, title: $title, year: $year, posterPath: $posterPath, isAnime: $isAnime)';
}


}

/// @nodoc
abstract mixin class $CatalogItemCopyWith<$Res>  {
  factory $CatalogItemCopyWith(CatalogItem value, $Res Function(CatalogItem) _then) = _$CatalogItemCopyWithImpl;
@useResult
$Res call({
 int tmdbId, MediaType mediaType, String title, int? year, String? posterPath, bool isAnime
});




}
/// @nodoc
class _$CatalogItemCopyWithImpl<$Res>
    implements $CatalogItemCopyWith<$Res> {
  _$CatalogItemCopyWithImpl(this._self, this._then);

  final CatalogItem _self;
  final $Res Function(CatalogItem) _then;

/// Create a copy of CatalogItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tmdbId = null,Object? mediaType = null,Object? title = null,Object? year = freezed,Object? posterPath = freezed,Object? isAnime = null,}) {
  return _then(CatalogItem(
tmdbId: null == tmdbId ? _self.tmdbId : tmdbId // ignore: cast_nullable_to_non_nullable
as int,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,isAnime: null == isAnime ? _self.isAnime : isAnime // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogItem].
extension CatalogItemPatterns on CatalogItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogItem value)  $default,){
final _that = this;
switch (_that) {
case _CatalogItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogItem value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int tmdbId,  MediaType mediaType,  String title,  int? year,  String? posterPath,  bool isAnime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogItem() when $default != null:
return $default(_that.tmdbId,_that.mediaType,_that.title,_that.year,_that.posterPath,_that.isAnime);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int tmdbId,  MediaType mediaType,  String title,  int? year,  String? posterPath,  bool isAnime)  $default,) {final _that = this;
switch (_that) {
case _CatalogItem():
return $default(_that.tmdbId,_that.mediaType,_that.title,_that.year,_that.posterPath,_that.isAnime);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int tmdbId,  MediaType mediaType,  String title,  int? year,  String? posterPath,  bool isAnime)?  $default,) {final _that = this;
switch (_that) {
case _CatalogItem() when $default != null:
return $default(_that.tmdbId,_that.mediaType,_that.title,_that.year,_that.posterPath,_that.isAnime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CatalogItem implements CatalogItem {
  const _CatalogItem({required this.tmdbId, required this.mediaType, required this.title, this.year, this.posterPath, this.isAnime = false});
  factory _CatalogItem.fromJson(Map<String, dynamic> json) => _$CatalogItemFromJson(json);

@override final  int tmdbId;
@override final  MediaType mediaType;
@override final  String title;
@override final  int? year;
@override final  String? posterPath;
@override@JsonKey() final  bool isAnime;

/// Create a copy of CatalogItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogItemCopyWith<_CatalogItem> get copyWith => __$CatalogItemCopyWithImpl<_CatalogItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CatalogItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogItem&&(identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.title, title) || other.title == title)&&(identical(other.year, year) || other.year == year)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.isAnime, isAnime) || other.isAnime == isAnime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tmdbId,mediaType,title,year,posterPath,isAnime);

@override
String toString() {
  return 'CatalogItem(tmdbId: $tmdbId, mediaType: $mediaType, title: $title, year: $year, posterPath: $posterPath, isAnime: $isAnime)';
}


}

/// @nodoc
abstract mixin class _$CatalogItemCopyWith<$Res> implements $CatalogItemCopyWith<$Res> {
  factory _$CatalogItemCopyWith(_CatalogItem value, $Res Function(_CatalogItem) _then) = __$CatalogItemCopyWithImpl;
@override @useResult
$Res call({
 int tmdbId, MediaType mediaType, String title, int? year, String? posterPath, bool isAnime
});




}
/// @nodoc
class __$CatalogItemCopyWithImpl<$Res>
    implements _$CatalogItemCopyWith<$Res> {
  __$CatalogItemCopyWithImpl(this._self, this._then);

  final _CatalogItem _self;
  final $Res Function(_CatalogItem) _then;

/// Create a copy of CatalogItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tmdbId = null,Object? mediaType = null,Object? title = null,Object? year = freezed,Object? posterPath = freezed,Object? isAnime = null,}) {
  return _then(_CatalogItem(
tmdbId: null == tmdbId ? _self.tmdbId : tmdbId // ignore: cast_nullable_to_non_nullable
as int,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,isAnime: null == isAnime ? _self.isAnime : isAnime // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$SearchPage {

 List<CatalogItem> get results; int get page; int get totalPages;
/// Create a copy of SearchPage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchPageCopyWith<SearchPage> get copyWith => _$SearchPageCopyWithImpl<SearchPage>(this as SearchPage, _$identity);

  /// Serializes this SearchPage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchPage&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.page, page) || other.page == page)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(results),page,totalPages);

@override
String toString() {
  return 'SearchPage(results: $results, page: $page, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class $SearchPageCopyWith<$Res>  {
  factory $SearchPageCopyWith(SearchPage value, $Res Function(SearchPage) _then) = _$SearchPageCopyWithImpl;
@useResult
$Res call({
 List<CatalogItem> results, int page, int totalPages
});




}
/// @nodoc
class _$SearchPageCopyWithImpl<$Res>
    implements $SearchPageCopyWith<$Res> {
  _$SearchPageCopyWithImpl(this._self, this._then);

  final SearchPage _self;
  final $Res Function(SearchPage) _then;

/// Create a copy of SearchPage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? results = null,Object? page = null,Object? totalPages = null,}) {
  return _then(SearchPage(
results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<CatalogItem>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchPage].
extension SearchPagePatterns on SearchPage {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchPage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchPage() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchPage value)  $default,){
final _that = this;
switch (_that) {
case _SearchPage():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchPage value)?  $default,){
final _that = this;
switch (_that) {
case _SearchPage() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CatalogItem> results,  int page,  int totalPages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchPage() when $default != null:
return $default(_that.results,_that.page,_that.totalPages);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CatalogItem> results,  int page,  int totalPages)  $default,) {final _that = this;
switch (_that) {
case _SearchPage():
return $default(_that.results,_that.page,_that.totalPages);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CatalogItem> results,  int page,  int totalPages)?  $default,) {final _that = this;
switch (_that) {
case _SearchPage() when $default != null:
return $default(_that.results,_that.page,_that.totalPages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchPage implements SearchPage {
  const _SearchPage({required  List<CatalogItem> results, this.page = 1, this.totalPages = 1}): _results = results;
  factory _SearchPage.fromJson(Map<String, dynamic> json) => _$SearchPageFromJson(json);

 final  List<CatalogItem> _results;
@override List<CatalogItem> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override@JsonKey() final  int page;
@override@JsonKey() final  int totalPages;

/// Create a copy of SearchPage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchPageCopyWith<_SearchPage> get copyWith => __$SearchPageCopyWithImpl<_SearchPage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchPageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchPage&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.page, page) || other.page == page)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_results),page,totalPages);

@override
String toString() {
  return 'SearchPage(results: $results, page: $page, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class _$SearchPageCopyWith<$Res> implements $SearchPageCopyWith<$Res> {
  factory _$SearchPageCopyWith(_SearchPage value, $Res Function(_SearchPage) _then) = __$SearchPageCopyWithImpl;
@override @useResult
$Res call({
 List<CatalogItem> results, int page, int totalPages
});




}
/// @nodoc
class __$SearchPageCopyWithImpl<$Res>
    implements _$SearchPageCopyWith<$Res> {
  __$SearchPageCopyWithImpl(this._self, this._then);

  final _SearchPage _self;
  final $Res Function(_SearchPage) _then;

/// Create a copy of SearchPage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? results = null,Object? page = null,Object? totalPages = null,}) {
  return _then(_SearchPage(
results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<CatalogItem>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$HomeSection {

 String get key; String get title; List<CatalogItem> get items;
/// Create a copy of HomeSection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeSectionCopyWith<HomeSection> get copyWith => _$HomeSectionCopyWithImpl<HomeSection>(this as HomeSection, _$identity);

  /// Serializes this HomeSection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeSection&&(identical(other.key, key) || other.key == key)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,title,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'HomeSection(key: $key, title: $title, items: $items)';
}


}

/// @nodoc
abstract mixin class $HomeSectionCopyWith<$Res>  {
  factory $HomeSectionCopyWith(HomeSection value, $Res Function(HomeSection) _then) = _$HomeSectionCopyWithImpl;
@useResult
$Res call({
 String key, String title, List<CatalogItem> items
});




}
/// @nodoc
class _$HomeSectionCopyWithImpl<$Res>
    implements $HomeSectionCopyWith<$Res> {
  _$HomeSectionCopyWithImpl(this._self, this._then);

  final HomeSection _self;
  final $Res Function(HomeSection) _then;

/// Create a copy of HomeSection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? title = null,Object? items = null,}) {
  return _then(HomeSection(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CatalogItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeSection].
extension HomeSectionPatterns on HomeSection {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeSection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeSection() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeSection value)  $default,){
final _that = this;
switch (_that) {
case _HomeSection():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeSection value)?  $default,){
final _that = this;
switch (_that) {
case _HomeSection() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String title,  List<CatalogItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeSection() when $default != null:
return $default(_that.key,_that.title,_that.items);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String title,  List<CatalogItem> items)  $default,) {final _that = this;
switch (_that) {
case _HomeSection():
return $default(_that.key,_that.title,_that.items);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String title,  List<CatalogItem> items)?  $default,) {final _that = this;
switch (_that) {
case _HomeSection() when $default != null:
return $default(_that.key,_that.title,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeSection implements HomeSection {
  const _HomeSection({required this.key, required this.title, required  List<CatalogItem> items}): _items = items;
  factory _HomeSection.fromJson(Map<String, dynamic> json) => _$HomeSectionFromJson(json);

@override final  String key;
@override final  String title;
 final  List<CatalogItem> _items;
@override List<CatalogItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of HomeSection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeSectionCopyWith<_HomeSection> get copyWith => __$HomeSectionCopyWithImpl<_HomeSection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeSectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeSection&&(identical(other.key, key) || other.key == key)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,title,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'HomeSection(key: $key, title: $title, items: $items)';
}


}

/// @nodoc
abstract mixin class _$HomeSectionCopyWith<$Res> implements $HomeSectionCopyWith<$Res> {
  factory _$HomeSectionCopyWith(_HomeSection value, $Res Function(_HomeSection) _then) = __$HomeSectionCopyWithImpl;
@override @useResult
$Res call({
 String key, String title, List<CatalogItem> items
});




}
/// @nodoc
class __$HomeSectionCopyWithImpl<$Res>
    implements _$HomeSectionCopyWith<$Res> {
  __$HomeSectionCopyWithImpl(this._self, this._then);

  final _HomeSection _self;
  final $Res Function(_HomeSection) _then;

/// Create a copy of HomeSection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? title = null,Object? items = null,}) {
  return _then(_HomeSection(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CatalogItem>,
  ));
}


}


/// @nodoc
mixin _$HomeSections {

 List<HomeSection> get sections; DateTime get fetchedAt;
/// Create a copy of HomeSections
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeSectionsCopyWith<HomeSections> get copyWith => _$HomeSectionsCopyWithImpl<HomeSections>(this as HomeSections, _$identity);

  /// Serializes this HomeSections to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeSections&&const DeepCollectionEquality().equals(other.sections, sections)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(sections),fetchedAt);

@override
String toString() {
  return 'HomeSections(sections: $sections, fetchedAt: $fetchedAt)';
}


}

/// @nodoc
abstract mixin class $HomeSectionsCopyWith<$Res>  {
  factory $HomeSectionsCopyWith(HomeSections value, $Res Function(HomeSections) _then) = _$HomeSectionsCopyWithImpl;
@useResult
$Res call({
 List<HomeSection> sections, DateTime fetchedAt
});




}
/// @nodoc
class _$HomeSectionsCopyWithImpl<$Res>
    implements $HomeSectionsCopyWith<$Res> {
  _$HomeSectionsCopyWithImpl(this._self, this._then);

  final HomeSections _self;
  final $Res Function(HomeSections) _then;

/// Create a copy of HomeSections
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sections = null,Object? fetchedAt = null,}) {
  return _then(HomeSections(
sections: null == sections ? _self.sections : sections // ignore: cast_nullable_to_non_nullable
as List<HomeSection>,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeSections].
extension HomeSectionsPatterns on HomeSections {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeSections value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeSections() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeSections value)  $default,){
final _that = this;
switch (_that) {
case _HomeSections():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeSections value)?  $default,){
final _that = this;
switch (_that) {
case _HomeSections() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<HomeSection> sections,  DateTime fetchedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeSections() when $default != null:
return $default(_that.sections,_that.fetchedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<HomeSection> sections,  DateTime fetchedAt)  $default,) {final _that = this;
switch (_that) {
case _HomeSections():
return $default(_that.sections,_that.fetchedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<HomeSection> sections,  DateTime fetchedAt)?  $default,) {final _that = this;
switch (_that) {
case _HomeSections() when $default != null:
return $default(_that.sections,_that.fetchedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeSections implements HomeSections {
  const _HomeSections({required  List<HomeSection> sections, required this.fetchedAt}): _sections = sections;
  factory _HomeSections.fromJson(Map<String, dynamic> json) => _$HomeSectionsFromJson(json);

 final  List<HomeSection> _sections;
@override List<HomeSection> get sections {
  if (_sections is EqualUnmodifiableListView) return _sections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sections);
}

@override final  DateTime fetchedAt;

/// Create a copy of HomeSections
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeSectionsCopyWith<_HomeSections> get copyWith => __$HomeSectionsCopyWithImpl<_HomeSections>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeSectionsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeSections&&const DeepCollectionEquality().equals(other._sections, _sections)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_sections),fetchedAt);

@override
String toString() {
  return 'HomeSections(sections: $sections, fetchedAt: $fetchedAt)';
}


}

/// @nodoc
abstract mixin class _$HomeSectionsCopyWith<$Res> implements $HomeSectionsCopyWith<$Res> {
  factory _$HomeSectionsCopyWith(_HomeSections value, $Res Function(_HomeSections) _then) = __$HomeSectionsCopyWithImpl;
@override @useResult
$Res call({
 List<HomeSection> sections, DateTime fetchedAt
});




}
/// @nodoc
class __$HomeSectionsCopyWithImpl<$Res>
    implements _$HomeSectionsCopyWith<$Res> {
  __$HomeSectionsCopyWithImpl(this._self, this._then);

  final _HomeSections _self;
  final $Res Function(_HomeSections) _then;

/// Create a copy of HomeSections
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sections = null,Object? fetchedAt = null,}) {
  return _then(_HomeSections(
sections: null == sections ? _self._sections : sections // ignore: cast_nullable_to_non_nullable
as List<HomeSection>,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$Title {

 String get id; int get tmdbId; MediaType get mediaType; String get title; String? get originalTitle; String? get overview; String? get posterPath; String? get backdropPath; DateTime? get releaseDate; int? get year; List<String> get genres; bool get isAnime; int? get runtimeMinutes; int? get episodeRunTime; int? get numberOfSeasons; int? get numberOfEpisodes; List<Season> get seasons; List<CastMember> get castTop; String? get status; double? get voteAverage; DateTime get fetchedAt;
/// Create a copy of Title
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TitleCopyWith<Title> get copyWith => _$TitleCopyWithImpl<Title>(this as Title, _$identity);

  /// Serializes this Title to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Title&&(identical(other.id, id) || other.id == id)&&(identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.title, title) || other.title == title)&&(identical(other.originalTitle, originalTitle) || other.originalTitle == originalTitle)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.isAnime, isAnime) || other.isAnime == isAnime)&&(identical(other.runtimeMinutes, runtimeMinutes) || other.runtimeMinutes == runtimeMinutes)&&(identical(other.episodeRunTime, episodeRunTime) || other.episodeRunTime == episodeRunTime)&&(identical(other.numberOfSeasons, numberOfSeasons) || other.numberOfSeasons == numberOfSeasons)&&(identical(other.numberOfEpisodes, numberOfEpisodes) || other.numberOfEpisodes == numberOfEpisodes)&&const DeepCollectionEquality().equals(other.seasons, seasons)&&const DeepCollectionEquality().equals(other.castTop, castTop)&&(identical(other.status, status) || other.status == status)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,tmdbId,mediaType,title,originalTitle,overview,posterPath,backdropPath,releaseDate,year,const DeepCollectionEquality().hash(genres),isAnime,runtimeMinutes,episodeRunTime,numberOfSeasons,numberOfEpisodes,const DeepCollectionEquality().hash(seasons),const DeepCollectionEquality().hash(castTop),status,voteAverage,fetchedAt]);

@override
String toString() {
  return 'Title(id: $id, tmdbId: $tmdbId, mediaType: $mediaType, title: $title, originalTitle: $originalTitle, overview: $overview, posterPath: $posterPath, backdropPath: $backdropPath, releaseDate: $releaseDate, year: $year, genres: $genres, isAnime: $isAnime, runtimeMinutes: $runtimeMinutes, episodeRunTime: $episodeRunTime, numberOfSeasons: $numberOfSeasons, numberOfEpisodes: $numberOfEpisodes, seasons: $seasons, castTop: $castTop, status: $status, voteAverage: $voteAverage, fetchedAt: $fetchedAt)';
}


}

/// @nodoc
abstract mixin class $TitleCopyWith<$Res>  {
  factory $TitleCopyWith(Title value, $Res Function(Title) _then) = _$TitleCopyWithImpl;
@useResult
$Res call({
 String id, int tmdbId, MediaType mediaType, String title, String? originalTitle, String? overview, String? posterPath, String? backdropPath, DateTime? releaseDate, int? year, List<String> genres, bool isAnime, int? runtimeMinutes, int? episodeRunTime, int? numberOfSeasons, int? numberOfEpisodes, List<Season> seasons, List<CastMember> castTop, String? status, double? voteAverage, DateTime fetchedAt
});




}
/// @nodoc
class _$TitleCopyWithImpl<$Res>
    implements $TitleCopyWith<$Res> {
  _$TitleCopyWithImpl(this._self, this._then);

  final Title _self;
  final $Res Function(Title) _then;

/// Create a copy of Title
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? tmdbId = null,Object? mediaType = null,Object? title = null,Object? originalTitle = freezed,Object? overview = freezed,Object? posterPath = freezed,Object? backdropPath = freezed,Object? releaseDate = freezed,Object? year = freezed,Object? genres = null,Object? isAnime = null,Object? runtimeMinutes = freezed,Object? episodeRunTime = freezed,Object? numberOfSeasons = freezed,Object? numberOfEpisodes = freezed,Object? seasons = null,Object? castTop = null,Object? status = freezed,Object? voteAverage = freezed,Object? fetchedAt = null,}) {
  return _then(Title(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tmdbId: null == tmdbId ? _self.tmdbId : tmdbId // ignore: cast_nullable_to_non_nullable
as int,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,originalTitle: freezed == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,isAnime: null == isAnime ? _self.isAnime : isAnime // ignore: cast_nullable_to_non_nullable
as bool,runtimeMinutes: freezed == runtimeMinutes ? _self.runtimeMinutes : runtimeMinutes // ignore: cast_nullable_to_non_nullable
as int?,episodeRunTime: freezed == episodeRunTime ? _self.episodeRunTime : episodeRunTime // ignore: cast_nullable_to_non_nullable
as int?,numberOfSeasons: freezed == numberOfSeasons ? _self.numberOfSeasons : numberOfSeasons // ignore: cast_nullable_to_non_nullable
as int?,numberOfEpisodes: freezed == numberOfEpisodes ? _self.numberOfEpisodes : numberOfEpisodes // ignore: cast_nullable_to_non_nullable
as int?,seasons: null == seasons ? _self.seasons : seasons // ignore: cast_nullable_to_non_nullable
as List<Season>,castTop: null == castTop ? _self.castTop : castTop // ignore: cast_nullable_to_non_nullable
as List<CastMember>,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,voteAverage: freezed == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double?,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Title].
extension TitlePatterns on Title {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Title value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Title() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Title value)  $default,){
final _that = this;
switch (_that) {
case _Title():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Title value)?  $default,){
final _that = this;
switch (_that) {
case _Title() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int tmdbId,  MediaType mediaType,  String title,  String? originalTitle,  String? overview,  String? posterPath,  String? backdropPath,  DateTime? releaseDate,  int? year,  List<String> genres,  bool isAnime,  int? runtimeMinutes,  int? episodeRunTime,  int? numberOfSeasons,  int? numberOfEpisodes,  List<Season> seasons,  List<CastMember> castTop,  String? status,  double? voteAverage,  DateTime fetchedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Title() when $default != null:
return $default(_that.id,_that.tmdbId,_that.mediaType,_that.title,_that.originalTitle,_that.overview,_that.posterPath,_that.backdropPath,_that.releaseDate,_that.year,_that.genres,_that.isAnime,_that.runtimeMinutes,_that.episodeRunTime,_that.numberOfSeasons,_that.numberOfEpisodes,_that.seasons,_that.castTop,_that.status,_that.voteAverage,_that.fetchedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int tmdbId,  MediaType mediaType,  String title,  String? originalTitle,  String? overview,  String? posterPath,  String? backdropPath,  DateTime? releaseDate,  int? year,  List<String> genres,  bool isAnime,  int? runtimeMinutes,  int? episodeRunTime,  int? numberOfSeasons,  int? numberOfEpisodes,  List<Season> seasons,  List<CastMember> castTop,  String? status,  double? voteAverage,  DateTime fetchedAt)  $default,) {final _that = this;
switch (_that) {
case _Title():
return $default(_that.id,_that.tmdbId,_that.mediaType,_that.title,_that.originalTitle,_that.overview,_that.posterPath,_that.backdropPath,_that.releaseDate,_that.year,_that.genres,_that.isAnime,_that.runtimeMinutes,_that.episodeRunTime,_that.numberOfSeasons,_that.numberOfEpisodes,_that.seasons,_that.castTop,_that.status,_that.voteAverage,_that.fetchedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int tmdbId,  MediaType mediaType,  String title,  String? originalTitle,  String? overview,  String? posterPath,  String? backdropPath,  DateTime? releaseDate,  int? year,  List<String> genres,  bool isAnime,  int? runtimeMinutes,  int? episodeRunTime,  int? numberOfSeasons,  int? numberOfEpisodes,  List<Season> seasons,  List<CastMember> castTop,  String? status,  double? voteAverage,  DateTime fetchedAt)?  $default,) {final _that = this;
switch (_that) {
case _Title() when $default != null:
return $default(_that.id,_that.tmdbId,_that.mediaType,_that.title,_that.originalTitle,_that.overview,_that.posterPath,_that.backdropPath,_that.releaseDate,_that.year,_that.genres,_that.isAnime,_that.runtimeMinutes,_that.episodeRunTime,_that.numberOfSeasons,_that.numberOfEpisodes,_that.seasons,_that.castTop,_that.status,_that.voteAverage,_that.fetchedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Title implements Title {
  const _Title({required this.id, required this.tmdbId, required this.mediaType, required this.title, this.originalTitle, this.overview, this.posterPath, this.backdropPath, this.releaseDate, this.year,  List<String> genres = const <String>[], this.isAnime = false, this.runtimeMinutes, this.episodeRunTime, this.numberOfSeasons, this.numberOfEpisodes,  List<Season> seasons = const <Season>[],  List<CastMember> castTop = const <CastMember>[], this.status, this.voteAverage, required this.fetchedAt}): _genres = genres,_seasons = seasons,_castTop = castTop;
  factory _Title.fromJson(Map<String, dynamic> json) => _$TitleFromJson(json);

@override final  String id;
@override final  int tmdbId;
@override final  MediaType mediaType;
@override final  String title;
@override final  String? originalTitle;
@override final  String? overview;
@override final  String? posterPath;
@override final  String? backdropPath;
@override final  DateTime? releaseDate;
@override final  int? year;
 final  List<String> _genres;
@override@JsonKey() List<String> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

@override@JsonKey() final  bool isAnime;
@override final  int? runtimeMinutes;
@override final  int? episodeRunTime;
@override final  int? numberOfSeasons;
@override final  int? numberOfEpisodes;
 final  List<Season> _seasons;
@override@JsonKey() List<Season> get seasons {
  if (_seasons is EqualUnmodifiableListView) return _seasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_seasons);
}

 final  List<CastMember> _castTop;
@override@JsonKey() List<CastMember> get castTop {
  if (_castTop is EqualUnmodifiableListView) return _castTop;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_castTop);
}

@override final  String? status;
@override final  double? voteAverage;
@override final  DateTime fetchedAt;

/// Create a copy of Title
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TitleCopyWith<_Title> get copyWith => __$TitleCopyWithImpl<_Title>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TitleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Title&&(identical(other.id, id) || other.id == id)&&(identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.title, title) || other.title == title)&&(identical(other.originalTitle, originalTitle) || other.originalTitle == originalTitle)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.backdropPath, backdropPath) || other.backdropPath == backdropPath)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.isAnime, isAnime) || other.isAnime == isAnime)&&(identical(other.runtimeMinutes, runtimeMinutes) || other.runtimeMinutes == runtimeMinutes)&&(identical(other.episodeRunTime, episodeRunTime) || other.episodeRunTime == episodeRunTime)&&(identical(other.numberOfSeasons, numberOfSeasons) || other.numberOfSeasons == numberOfSeasons)&&(identical(other.numberOfEpisodes, numberOfEpisodes) || other.numberOfEpisodes == numberOfEpisodes)&&const DeepCollectionEquality().equals(other._seasons, _seasons)&&const DeepCollectionEquality().equals(other._castTop, _castTop)&&(identical(other.status, status) || other.status == status)&&(identical(other.voteAverage, voteAverage) || other.voteAverage == voteAverage)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,tmdbId,mediaType,title,originalTitle,overview,posterPath,backdropPath,releaseDate,year,const DeepCollectionEquality().hash(_genres),isAnime,runtimeMinutes,episodeRunTime,numberOfSeasons,numberOfEpisodes,const DeepCollectionEquality().hash(_seasons),const DeepCollectionEquality().hash(_castTop),status,voteAverage,fetchedAt]);

@override
String toString() {
  return 'Title(id: $id, tmdbId: $tmdbId, mediaType: $mediaType, title: $title, originalTitle: $originalTitle, overview: $overview, posterPath: $posterPath, backdropPath: $backdropPath, releaseDate: $releaseDate, year: $year, genres: $genres, isAnime: $isAnime, runtimeMinutes: $runtimeMinutes, episodeRunTime: $episodeRunTime, numberOfSeasons: $numberOfSeasons, numberOfEpisodes: $numberOfEpisodes, seasons: $seasons, castTop: $castTop, status: $status, voteAverage: $voteAverage, fetchedAt: $fetchedAt)';
}


}

/// @nodoc
abstract mixin class _$TitleCopyWith<$Res> implements $TitleCopyWith<$Res> {
  factory _$TitleCopyWith(_Title value, $Res Function(_Title) _then) = __$TitleCopyWithImpl;
@override @useResult
$Res call({
 String id, int tmdbId, MediaType mediaType, String title, String? originalTitle, String? overview, String? posterPath, String? backdropPath, DateTime? releaseDate, int? year, List<String> genres, bool isAnime, int? runtimeMinutes, int? episodeRunTime, int? numberOfSeasons, int? numberOfEpisodes, List<Season> seasons, List<CastMember> castTop, String? status, double? voteAverage, DateTime fetchedAt
});




}
/// @nodoc
class __$TitleCopyWithImpl<$Res>
    implements _$TitleCopyWith<$Res> {
  __$TitleCopyWithImpl(this._self, this._then);

  final _Title _self;
  final $Res Function(_Title) _then;

/// Create a copy of Title
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? tmdbId = null,Object? mediaType = null,Object? title = null,Object? originalTitle = freezed,Object? overview = freezed,Object? posterPath = freezed,Object? backdropPath = freezed,Object? releaseDate = freezed,Object? year = freezed,Object? genres = null,Object? isAnime = null,Object? runtimeMinutes = freezed,Object? episodeRunTime = freezed,Object? numberOfSeasons = freezed,Object? numberOfEpisodes = freezed,Object? seasons = null,Object? castTop = null,Object? status = freezed,Object? voteAverage = freezed,Object? fetchedAt = null,}) {
  return _then(_Title(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,tmdbId: null == tmdbId ? _self.tmdbId : tmdbId // ignore: cast_nullable_to_non_nullable
as int,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,originalTitle: freezed == originalTitle ? _self.originalTitle : originalTitle // ignore: cast_nullable_to_non_nullable
as String?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,backdropPath: freezed == backdropPath ? _self.backdropPath : backdropPath // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,isAnime: null == isAnime ? _self.isAnime : isAnime // ignore: cast_nullable_to_non_nullable
as bool,runtimeMinutes: freezed == runtimeMinutes ? _self.runtimeMinutes : runtimeMinutes // ignore: cast_nullable_to_non_nullable
as int?,episodeRunTime: freezed == episodeRunTime ? _self.episodeRunTime : episodeRunTime // ignore: cast_nullable_to_non_nullable
as int?,numberOfSeasons: freezed == numberOfSeasons ? _self.numberOfSeasons : numberOfSeasons // ignore: cast_nullable_to_non_nullable
as int?,numberOfEpisodes: freezed == numberOfEpisodes ? _self.numberOfEpisodes : numberOfEpisodes // ignore: cast_nullable_to_non_nullable
as int?,seasons: null == seasons ? _self._seasons : seasons // ignore: cast_nullable_to_non_nullable
as List<Season>,castTop: null == castTop ? _self._castTop : castTop // ignore: cast_nullable_to_non_nullable
as List<CastMember>,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,voteAverage: freezed == voteAverage ? _self.voteAverage : voteAverage // ignore: cast_nullable_to_non_nullable
as double?,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$Season {

 int get seasonNumber; String get name; int get episodeCount; DateTime? get airDate; String? get posterPath;
/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SeasonCopyWith<Season> get copyWith => _$SeasonCopyWithImpl<Season>(this as Season, _$identity);

  /// Serializes this Season to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Season&&(identical(other.seasonNumber, seasonNumber) || other.seasonNumber == seasonNumber)&&(identical(other.name, name) || other.name == name)&&(identical(other.episodeCount, episodeCount) || other.episodeCount == episodeCount)&&(identical(other.airDate, airDate) || other.airDate == airDate)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,seasonNumber,name,episodeCount,airDate,posterPath);

@override
String toString() {
  return 'Season(seasonNumber: $seasonNumber, name: $name, episodeCount: $episodeCount, airDate: $airDate, posterPath: $posterPath)';
}


}

/// @nodoc
abstract mixin class $SeasonCopyWith<$Res>  {
  factory $SeasonCopyWith(Season value, $Res Function(Season) _then) = _$SeasonCopyWithImpl;
@useResult
$Res call({
 int seasonNumber, String name, int episodeCount, DateTime? airDate, String? posterPath
});




}
/// @nodoc
class _$SeasonCopyWithImpl<$Res>
    implements $SeasonCopyWith<$Res> {
  _$SeasonCopyWithImpl(this._self, this._then);

  final Season _self;
  final $Res Function(Season) _then;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? seasonNumber = null,Object? name = null,Object? episodeCount = null,Object? airDate = freezed,Object? posterPath = freezed,}) {
  return _then(Season(
seasonNumber: null == seasonNumber ? _self.seasonNumber : seasonNumber // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,episodeCount: null == episodeCount ? _self.episodeCount : episodeCount // ignore: cast_nullable_to_non_nullable
as int,airDate: freezed == airDate ? _self.airDate : airDate // ignore: cast_nullable_to_non_nullable
as DateTime?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Season].
extension SeasonPatterns on Season {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Season value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Season value)  $default,){
final _that = this;
switch (_that) {
case _Season():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Season value)?  $default,){
final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int seasonNumber,  String name,  int episodeCount,  DateTime? airDate,  String? posterPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that.seasonNumber,_that.name,_that.episodeCount,_that.airDate,_that.posterPath);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int seasonNumber,  String name,  int episodeCount,  DateTime? airDate,  String? posterPath)  $default,) {final _that = this;
switch (_that) {
case _Season():
return $default(_that.seasonNumber,_that.name,_that.episodeCount,_that.airDate,_that.posterPath);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int seasonNumber,  String name,  int episodeCount,  DateTime? airDate,  String? posterPath)?  $default,) {final _that = this;
switch (_that) {
case _Season() when $default != null:
return $default(_that.seasonNumber,_that.name,_that.episodeCount,_that.airDate,_that.posterPath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Season implements Season {
  const _Season({required this.seasonNumber, required this.name, this.episodeCount = 0, this.airDate, this.posterPath});
  factory _Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);

@override final  int seasonNumber;
@override final  String name;
@override@JsonKey() final  int episodeCount;
@override final  DateTime? airDate;
@override final  String? posterPath;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeasonCopyWith<_Season> get copyWith => __$SeasonCopyWithImpl<_Season>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SeasonToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Season&&(identical(other.seasonNumber, seasonNumber) || other.seasonNumber == seasonNumber)&&(identical(other.name, name) || other.name == name)&&(identical(other.episodeCount, episodeCount) || other.episodeCount == episodeCount)&&(identical(other.airDate, airDate) || other.airDate == airDate)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,seasonNumber,name,episodeCount,airDate,posterPath);

@override
String toString() {
  return 'Season(seasonNumber: $seasonNumber, name: $name, episodeCount: $episodeCount, airDate: $airDate, posterPath: $posterPath)';
}


}

/// @nodoc
abstract mixin class _$SeasonCopyWith<$Res> implements $SeasonCopyWith<$Res> {
  factory _$SeasonCopyWith(_Season value, $Res Function(_Season) _then) = __$SeasonCopyWithImpl;
@override @useResult
$Res call({
 int seasonNumber, String name, int episodeCount, DateTime? airDate, String? posterPath
});




}
/// @nodoc
class __$SeasonCopyWithImpl<$Res>
    implements _$SeasonCopyWith<$Res> {
  __$SeasonCopyWithImpl(this._self, this._then);

  final _Season _self;
  final $Res Function(_Season) _then;

/// Create a copy of Season
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? seasonNumber = null,Object? name = null,Object? episodeCount = null,Object? airDate = freezed,Object? posterPath = freezed,}) {
  return _then(_Season(
seasonNumber: null == seasonNumber ? _self.seasonNumber : seasonNumber // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,episodeCount: null == episodeCount ? _self.episodeCount : episodeCount // ignore: cast_nullable_to_non_nullable
as int,airDate: freezed == airDate ? _self.airDate : airDate // ignore: cast_nullable_to_non_nullable
as DateTime?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CastMember {

 String get name; String? get character; String? get profilePath;
/// Create a copy of CastMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CastMemberCopyWith<CastMember> get copyWith => _$CastMemberCopyWithImpl<CastMember>(this as CastMember, _$identity);

  /// Serializes this CastMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CastMember&&(identical(other.name, name) || other.name == name)&&(identical(other.character, character) || other.character == character)&&(identical(other.profilePath, profilePath) || other.profilePath == profilePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,character,profilePath);

@override
String toString() {
  return 'CastMember(name: $name, character: $character, profilePath: $profilePath)';
}


}

/// @nodoc
abstract mixin class $CastMemberCopyWith<$Res>  {
  factory $CastMemberCopyWith(CastMember value, $Res Function(CastMember) _then) = _$CastMemberCopyWithImpl;
@useResult
$Res call({
 String name, String? character, String? profilePath
});




}
/// @nodoc
class _$CastMemberCopyWithImpl<$Res>
    implements $CastMemberCopyWith<$Res> {
  _$CastMemberCopyWithImpl(this._self, this._then);

  final CastMember _self;
  final $Res Function(CastMember) _then;

/// Create a copy of CastMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? character = freezed,Object? profilePath = freezed,}) {
  return _then(CastMember(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,character: freezed == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String?,profilePath: freezed == profilePath ? _self.profilePath : profilePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CastMember].
extension CastMemberPatterns on CastMember {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CastMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CastMember() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CastMember value)  $default,){
final _that = this;
switch (_that) {
case _CastMember():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CastMember value)?  $default,){
final _that = this;
switch (_that) {
case _CastMember() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? character,  String? profilePath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CastMember() when $default != null:
return $default(_that.name,_that.character,_that.profilePath);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? character,  String? profilePath)  $default,) {final _that = this;
switch (_that) {
case _CastMember():
return $default(_that.name,_that.character,_that.profilePath);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? character,  String? profilePath)?  $default,) {final _that = this;
switch (_that) {
case _CastMember() when $default != null:
return $default(_that.name,_that.character,_that.profilePath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CastMember implements CastMember {
  const _CastMember({required this.name, this.character, this.profilePath});
  factory _CastMember.fromJson(Map<String, dynamic> json) => _$CastMemberFromJson(json);

@override final  String name;
@override final  String? character;
@override final  String? profilePath;

/// Create a copy of CastMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CastMemberCopyWith<_CastMember> get copyWith => __$CastMemberCopyWithImpl<_CastMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CastMemberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CastMember&&(identical(other.name, name) || other.name == name)&&(identical(other.character, character) || other.character == character)&&(identical(other.profilePath, profilePath) || other.profilePath == profilePath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,character,profilePath);

@override
String toString() {
  return 'CastMember(name: $name, character: $character, profilePath: $profilePath)';
}


}

/// @nodoc
abstract mixin class _$CastMemberCopyWith<$Res> implements $CastMemberCopyWith<$Res> {
  factory _$CastMemberCopyWith(_CastMember value, $Res Function(_CastMember) _then) = __$CastMemberCopyWithImpl;
@override @useResult
$Res call({
 String name, String? character, String? profilePath
});




}
/// @nodoc
class __$CastMemberCopyWithImpl<$Res>
    implements _$CastMemberCopyWith<$Res> {
  __$CastMemberCopyWithImpl(this._self, this._then);

  final _CastMember _self;
  final $Res Function(_CastMember) _then;

/// Create a copy of CastMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? character = freezed,Object? profilePath = freezed,}) {
  return _then(_CastMember(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,character: freezed == character ? _self.character : character // ignore: cast_nullable_to_non_nullable
as String?,profilePath: freezed == profilePath ? _self.profilePath : profilePath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$StreamingProvider {

 int get id; String? get slug; String get name; String? get logoPath; String? get androidPackage; String? get webDomain; String? get searchUrlTemplate; bool get isFeatured; int? get displayOrder; int? get parentId;
/// Create a copy of StreamingProvider
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreamingProviderCopyWith<StreamingProvider> get copyWith => _$StreamingProviderCopyWithImpl<StreamingProvider>(this as StreamingProvider, _$identity);

  /// Serializes this StreamingProvider to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreamingProvider&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath)&&(identical(other.androidPackage, androidPackage) || other.androidPackage == androidPackage)&&(identical(other.webDomain, webDomain) || other.webDomain == webDomain)&&(identical(other.searchUrlTemplate, searchUrlTemplate) || other.searchUrlTemplate == searchUrlTemplate)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,logoPath,androidPackage,webDomain,searchUrlTemplate,isFeatured,displayOrder,parentId);

@override
String toString() {
  return 'StreamingProvider(id: $id, slug: $slug, name: $name, logoPath: $logoPath, androidPackage: $androidPackage, webDomain: $webDomain, searchUrlTemplate: $searchUrlTemplate, isFeatured: $isFeatured, displayOrder: $displayOrder, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class $StreamingProviderCopyWith<$Res>  {
  factory $StreamingProviderCopyWith(StreamingProvider value, $Res Function(StreamingProvider) _then) = _$StreamingProviderCopyWithImpl;
@useResult
$Res call({
 int id, String? slug, String name, String? logoPath, String? androidPackage, String? webDomain, String? searchUrlTemplate, bool isFeatured, int? displayOrder, int? parentId
});




}
/// @nodoc
class _$StreamingProviderCopyWithImpl<$Res>
    implements $StreamingProviderCopyWith<$Res> {
  _$StreamingProviderCopyWithImpl(this._self, this._then);

  final StreamingProvider _self;
  final $Res Function(StreamingProvider) _then;

/// Create a copy of StreamingProvider
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? slug = freezed,Object? name = null,Object? logoPath = freezed,Object? androidPackage = freezed,Object? webDomain = freezed,Object? searchUrlTemplate = freezed,Object? isFeatured = null,Object? displayOrder = freezed,Object? parentId = freezed,}) {
  return _then(StreamingProvider(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,androidPackage: freezed == androidPackage ? _self.androidPackage : androidPackage // ignore: cast_nullable_to_non_nullable
as String?,webDomain: freezed == webDomain ? _self.webDomain : webDomain // ignore: cast_nullable_to_non_nullable
as String?,searchUrlTemplate: freezed == searchUrlTemplate ? _self.searchUrlTemplate : searchUrlTemplate // ignore: cast_nullable_to_non_nullable
as String?,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,displayOrder: freezed == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [StreamingProvider].
extension StreamingProviderPatterns on StreamingProvider {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreamingProvider value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreamingProvider() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreamingProvider value)  $default,){
final _that = this;
switch (_that) {
case _StreamingProvider():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreamingProvider value)?  $default,){
final _that = this;
switch (_that) {
case _StreamingProvider() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? slug,  String name,  String? logoPath,  String? androidPackage,  String? webDomain,  String? searchUrlTemplate,  bool isFeatured,  int? displayOrder,  int? parentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreamingProvider() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.logoPath,_that.androidPackage,_that.webDomain,_that.searchUrlTemplate,_that.isFeatured,_that.displayOrder,_that.parentId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? slug,  String name,  String? logoPath,  String? androidPackage,  String? webDomain,  String? searchUrlTemplate,  bool isFeatured,  int? displayOrder,  int? parentId)  $default,) {final _that = this;
switch (_that) {
case _StreamingProvider():
return $default(_that.id,_that.slug,_that.name,_that.logoPath,_that.androidPackage,_that.webDomain,_that.searchUrlTemplate,_that.isFeatured,_that.displayOrder,_that.parentId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? slug,  String name,  String? logoPath,  String? androidPackage,  String? webDomain,  String? searchUrlTemplate,  bool isFeatured,  int? displayOrder,  int? parentId)?  $default,) {final _that = this;
switch (_that) {
case _StreamingProvider() when $default != null:
return $default(_that.id,_that.slug,_that.name,_that.logoPath,_that.androidPackage,_that.webDomain,_that.searchUrlTemplate,_that.isFeatured,_that.displayOrder,_that.parentId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StreamingProvider implements StreamingProvider {
  const _StreamingProvider({required this.id, this.slug, required this.name, this.logoPath, this.androidPackage, this.webDomain, this.searchUrlTemplate, this.isFeatured = false, this.displayOrder, this.parentId});
  factory _StreamingProvider.fromJson(Map<String, dynamic> json) => _$StreamingProviderFromJson(json);

@override final  int id;
@override final  String? slug;
@override final  String name;
@override final  String? logoPath;
@override final  String? androidPackage;
@override final  String? webDomain;
@override final  String? searchUrlTemplate;
@override@JsonKey() final  bool isFeatured;
@override final  int? displayOrder;
@override final  int? parentId;

/// Create a copy of StreamingProvider
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreamingProviderCopyWith<_StreamingProvider> get copyWith => __$StreamingProviderCopyWithImpl<_StreamingProvider>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StreamingProviderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreamingProvider&&(identical(other.id, id) || other.id == id)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath)&&(identical(other.androidPackage, androidPackage) || other.androidPackage == androidPackage)&&(identical(other.webDomain, webDomain) || other.webDomain == webDomain)&&(identical(other.searchUrlTemplate, searchUrlTemplate) || other.searchUrlTemplate == searchUrlTemplate)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.displayOrder, displayOrder) || other.displayOrder == displayOrder)&&(identical(other.parentId, parentId) || other.parentId == parentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,slug,name,logoPath,androidPackage,webDomain,searchUrlTemplate,isFeatured,displayOrder,parentId);

@override
String toString() {
  return 'StreamingProvider(id: $id, slug: $slug, name: $name, logoPath: $logoPath, androidPackage: $androidPackage, webDomain: $webDomain, searchUrlTemplate: $searchUrlTemplate, isFeatured: $isFeatured, displayOrder: $displayOrder, parentId: $parentId)';
}


}

/// @nodoc
abstract mixin class _$StreamingProviderCopyWith<$Res> implements $StreamingProviderCopyWith<$Res> {
  factory _$StreamingProviderCopyWith(_StreamingProvider value, $Res Function(_StreamingProvider) _then) = __$StreamingProviderCopyWithImpl;
@override @useResult
$Res call({
 int id, String? slug, String name, String? logoPath, String? androidPackage, String? webDomain, String? searchUrlTemplate, bool isFeatured, int? displayOrder, int? parentId
});




}
/// @nodoc
class __$StreamingProviderCopyWithImpl<$Res>
    implements _$StreamingProviderCopyWith<$Res> {
  __$StreamingProviderCopyWithImpl(this._self, this._then);

  final _StreamingProvider _self;
  final $Res Function(_StreamingProvider) _then;

/// Create a copy of StreamingProvider
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? slug = freezed,Object? name = null,Object? logoPath = freezed,Object? androidPackage = freezed,Object? webDomain = freezed,Object? searchUrlTemplate = freezed,Object? isFeatured = null,Object? displayOrder = freezed,Object? parentId = freezed,}) {
  return _then(_StreamingProvider(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,androidPackage: freezed == androidPackage ? _self.androidPackage : androidPackage // ignore: cast_nullable_to_non_nullable
as String?,webDomain: freezed == webDomain ? _self.webDomain : webDomain // ignore: cast_nullable_to_non_nullable
as String?,searchUrlTemplate: freezed == searchUrlTemplate ? _self.searchUrlTemplate : searchUrlTemplate // ignore: cast_nullable_to_non_nullable
as String?,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,displayOrder: freezed == displayOrder ? _self.displayOrder : displayOrder // ignore: cast_nullable_to_non_nullable
as int?,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$Availability {

 int get providerId; OfferType get offerType; String? get deepLink; String? get deepLinkSource; int? get priceCents; DateTime get fetchedAt; DateTime? get linkFetchedAt; StreamingProvider get provider;
/// Create a copy of Availability
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AvailabilityCopyWith<Availability> get copyWith => _$AvailabilityCopyWithImpl<Availability>(this as Availability, _$identity);

  /// Serializes this Availability to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Availability&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.offerType, offerType) || other.offerType == offerType)&&(identical(other.deepLink, deepLink) || other.deepLink == deepLink)&&(identical(other.deepLinkSource, deepLinkSource) || other.deepLinkSource == deepLinkSource)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt)&&(identical(other.linkFetchedAt, linkFetchedAt) || other.linkFetchedAt == linkFetchedAt)&&(identical(other.provider, provider) || other.provider == provider));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,providerId,offerType,deepLink,deepLinkSource,priceCents,fetchedAt,linkFetchedAt,provider);

@override
String toString() {
  return 'Availability(providerId: $providerId, offerType: $offerType, deepLink: $deepLink, deepLinkSource: $deepLinkSource, priceCents: $priceCents, fetchedAt: $fetchedAt, linkFetchedAt: $linkFetchedAt, provider: $provider)';
}


}

/// @nodoc
abstract mixin class $AvailabilityCopyWith<$Res>  {
  factory $AvailabilityCopyWith(Availability value, $Res Function(Availability) _then) = _$AvailabilityCopyWithImpl;
@useResult
$Res call({
 int providerId, OfferType offerType, String? deepLink, String? deepLinkSource, int? priceCents, DateTime fetchedAt, DateTime? linkFetchedAt, StreamingProvider provider
});


$StreamingProviderCopyWith<$Res> get provider;

}
/// @nodoc
class _$AvailabilityCopyWithImpl<$Res>
    implements $AvailabilityCopyWith<$Res> {
  _$AvailabilityCopyWithImpl(this._self, this._then);

  final Availability _self;
  final $Res Function(Availability) _then;

/// Create a copy of Availability
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? providerId = null,Object? offerType = null,Object? deepLink = freezed,Object? deepLinkSource = freezed,Object? priceCents = freezed,Object? fetchedAt = null,Object? linkFetchedAt = freezed,Object? provider = null,}) {
  return _then(Availability(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as int,offerType: null == offerType ? _self.offerType : offerType // ignore: cast_nullable_to_non_nullable
as OfferType,deepLink: freezed == deepLink ? _self.deepLink : deepLink // ignore: cast_nullable_to_non_nullable
as String?,deepLinkSource: freezed == deepLinkSource ? _self.deepLinkSource : deepLinkSource // ignore: cast_nullable_to_non_nullable
as String?,priceCents: freezed == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int?,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,linkFetchedAt: freezed == linkFetchedAt ? _self.linkFetchedAt : linkFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as StreamingProvider,
  ));
}
/// Create a copy of Availability
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreamingProviderCopyWith<$Res> get provider {
  
  return $StreamingProviderCopyWith<$Res>(_self.provider, (value) {
    return _then(_self.copyWith(provider: value));
  });
}
}


/// Adds pattern-matching-related methods to [Availability].
extension AvailabilityPatterns on Availability {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Availability value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Availability() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Availability value)  $default,){
final _that = this;
switch (_that) {
case _Availability():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Availability value)?  $default,){
final _that = this;
switch (_that) {
case _Availability() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int providerId,  OfferType offerType,  String? deepLink,  String? deepLinkSource,  int? priceCents,  DateTime fetchedAt,  DateTime? linkFetchedAt,  StreamingProvider provider)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Availability() when $default != null:
return $default(_that.providerId,_that.offerType,_that.deepLink,_that.deepLinkSource,_that.priceCents,_that.fetchedAt,_that.linkFetchedAt,_that.provider);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int providerId,  OfferType offerType,  String? deepLink,  String? deepLinkSource,  int? priceCents,  DateTime fetchedAt,  DateTime? linkFetchedAt,  StreamingProvider provider)  $default,) {final _that = this;
switch (_that) {
case _Availability():
return $default(_that.providerId,_that.offerType,_that.deepLink,_that.deepLinkSource,_that.priceCents,_that.fetchedAt,_that.linkFetchedAt,_that.provider);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int providerId,  OfferType offerType,  String? deepLink,  String? deepLinkSource,  int? priceCents,  DateTime fetchedAt,  DateTime? linkFetchedAt,  StreamingProvider provider)?  $default,) {final _that = this;
switch (_that) {
case _Availability() when $default != null:
return $default(_that.providerId,_that.offerType,_that.deepLink,_that.deepLinkSource,_that.priceCents,_that.fetchedAt,_that.linkFetchedAt,_that.provider);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Availability implements Availability {
  const _Availability({required this.providerId, required this.offerType, this.deepLink, this.deepLinkSource, this.priceCents, required this.fetchedAt, this.linkFetchedAt, required this.provider});
  factory _Availability.fromJson(Map<String, dynamic> json) => _$AvailabilityFromJson(json);

@override final  int providerId;
@override final  OfferType offerType;
@override final  String? deepLink;
@override final  String? deepLinkSource;
@override final  int? priceCents;
@override final  DateTime fetchedAt;
@override final  DateTime? linkFetchedAt;
@override final  StreamingProvider provider;

/// Create a copy of Availability
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AvailabilityCopyWith<_Availability> get copyWith => __$AvailabilityCopyWithImpl<_Availability>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AvailabilityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Availability&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.offerType, offerType) || other.offerType == offerType)&&(identical(other.deepLink, deepLink) || other.deepLink == deepLink)&&(identical(other.deepLinkSource, deepLinkSource) || other.deepLinkSource == deepLinkSource)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.fetchedAt, fetchedAt) || other.fetchedAt == fetchedAt)&&(identical(other.linkFetchedAt, linkFetchedAt) || other.linkFetchedAt == linkFetchedAt)&&(identical(other.provider, provider) || other.provider == provider));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,providerId,offerType,deepLink,deepLinkSource,priceCents,fetchedAt,linkFetchedAt,provider);

@override
String toString() {
  return 'Availability(providerId: $providerId, offerType: $offerType, deepLink: $deepLink, deepLinkSource: $deepLinkSource, priceCents: $priceCents, fetchedAt: $fetchedAt, linkFetchedAt: $linkFetchedAt, provider: $provider)';
}


}

/// @nodoc
abstract mixin class _$AvailabilityCopyWith<$Res> implements $AvailabilityCopyWith<$Res> {
  factory _$AvailabilityCopyWith(_Availability value, $Res Function(_Availability) _then) = __$AvailabilityCopyWithImpl;
@override @useResult
$Res call({
 int providerId, OfferType offerType, String? deepLink, String? deepLinkSource, int? priceCents, DateTime fetchedAt, DateTime? linkFetchedAt, StreamingProvider provider
});


@override $StreamingProviderCopyWith<$Res> get provider;

}
/// @nodoc
class __$AvailabilityCopyWithImpl<$Res>
    implements _$AvailabilityCopyWith<$Res> {
  __$AvailabilityCopyWithImpl(this._self, this._then);

  final _Availability _self;
  final $Res Function(_Availability) _then;

/// Create a copy of Availability
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? providerId = null,Object? offerType = null,Object? deepLink = freezed,Object? deepLinkSource = freezed,Object? priceCents = freezed,Object? fetchedAt = null,Object? linkFetchedAt = freezed,Object? provider = null,}) {
  return _then(_Availability(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as int,offerType: null == offerType ? _self.offerType : offerType // ignore: cast_nullable_to_non_nullable
as OfferType,deepLink: freezed == deepLink ? _self.deepLink : deepLink // ignore: cast_nullable_to_non_nullable
as String?,deepLinkSource: freezed == deepLinkSource ? _self.deepLinkSource : deepLinkSource // ignore: cast_nullable_to_non_nullable
as String?,priceCents: freezed == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int?,fetchedAt: null == fetchedAt ? _self.fetchedAt : fetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,linkFetchedAt: freezed == linkFetchedAt ? _self.linkFetchedAt : linkFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as StreamingProvider,
  ));
}

/// Create a copy of Availability
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreamingProviderCopyWith<$Res> get provider {
  
  return $StreamingProviderCopyWith<$Res>(_self.provider, (value) {
    return _then(_self.copyWith(provider: value));
  });
}
}


/// @nodoc
mixin _$TitleSync {

 DateTime? get providersFetchedAt; DateTime? get linksFetchedAt; String? get linksStatus;
/// Create a copy of TitleSync
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TitleSyncCopyWith<TitleSync> get copyWith => _$TitleSyncCopyWithImpl<TitleSync>(this as TitleSync, _$identity);

  /// Serializes this TitleSync to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TitleSync&&(identical(other.providersFetchedAt, providersFetchedAt) || other.providersFetchedAt == providersFetchedAt)&&(identical(other.linksFetchedAt, linksFetchedAt) || other.linksFetchedAt == linksFetchedAt)&&(identical(other.linksStatus, linksStatus) || other.linksStatus == linksStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,providersFetchedAt,linksFetchedAt,linksStatus);

@override
String toString() {
  return 'TitleSync(providersFetchedAt: $providersFetchedAt, linksFetchedAt: $linksFetchedAt, linksStatus: $linksStatus)';
}


}

/// @nodoc
abstract mixin class $TitleSyncCopyWith<$Res>  {
  factory $TitleSyncCopyWith(TitleSync value, $Res Function(TitleSync) _then) = _$TitleSyncCopyWithImpl;
@useResult
$Res call({
 DateTime? providersFetchedAt, DateTime? linksFetchedAt, String? linksStatus
});




}
/// @nodoc
class _$TitleSyncCopyWithImpl<$Res>
    implements $TitleSyncCopyWith<$Res> {
  _$TitleSyncCopyWithImpl(this._self, this._then);

  final TitleSync _self;
  final $Res Function(TitleSync) _then;

/// Create a copy of TitleSync
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? providersFetchedAt = freezed,Object? linksFetchedAt = freezed,Object? linksStatus = freezed,}) {
  return _then(TitleSync(
providersFetchedAt: freezed == providersFetchedAt ? _self.providersFetchedAt : providersFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,linksFetchedAt: freezed == linksFetchedAt ? _self.linksFetchedAt : linksFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,linksStatus: freezed == linksStatus ? _self.linksStatus : linksStatus // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TitleSync].
extension TitleSyncPatterns on TitleSync {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TitleSync value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TitleSync() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TitleSync value)  $default,){
final _that = this;
switch (_that) {
case _TitleSync():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TitleSync value)?  $default,){
final _that = this;
switch (_that) {
case _TitleSync() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? providersFetchedAt,  DateTime? linksFetchedAt,  String? linksStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TitleSync() when $default != null:
return $default(_that.providersFetchedAt,_that.linksFetchedAt,_that.linksStatus);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? providersFetchedAt,  DateTime? linksFetchedAt,  String? linksStatus)  $default,) {final _that = this;
switch (_that) {
case _TitleSync():
return $default(_that.providersFetchedAt,_that.linksFetchedAt,_that.linksStatus);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? providersFetchedAt,  DateTime? linksFetchedAt,  String? linksStatus)?  $default,) {final _that = this;
switch (_that) {
case _TitleSync() when $default != null:
return $default(_that.providersFetchedAt,_that.linksFetchedAt,_that.linksStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TitleSync implements TitleSync {
  const _TitleSync({this.providersFetchedAt, this.linksFetchedAt, this.linksStatus});
  factory _TitleSync.fromJson(Map<String, dynamic> json) => _$TitleSyncFromJson(json);

@override final  DateTime? providersFetchedAt;
@override final  DateTime? linksFetchedAt;
@override final  String? linksStatus;

/// Create a copy of TitleSync
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TitleSyncCopyWith<_TitleSync> get copyWith => __$TitleSyncCopyWithImpl<_TitleSync>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TitleSyncToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TitleSync&&(identical(other.providersFetchedAt, providersFetchedAt) || other.providersFetchedAt == providersFetchedAt)&&(identical(other.linksFetchedAt, linksFetchedAt) || other.linksFetchedAt == linksFetchedAt)&&(identical(other.linksStatus, linksStatus) || other.linksStatus == linksStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,providersFetchedAt,linksFetchedAt,linksStatus);

@override
String toString() {
  return 'TitleSync(providersFetchedAt: $providersFetchedAt, linksFetchedAt: $linksFetchedAt, linksStatus: $linksStatus)';
}


}

/// @nodoc
abstract mixin class _$TitleSyncCopyWith<$Res> implements $TitleSyncCopyWith<$Res> {
  factory _$TitleSyncCopyWith(_TitleSync value, $Res Function(_TitleSync) _then) = __$TitleSyncCopyWithImpl;
@override @useResult
$Res call({
 DateTime? providersFetchedAt, DateTime? linksFetchedAt, String? linksStatus
});




}
/// @nodoc
class __$TitleSyncCopyWithImpl<$Res>
    implements _$TitleSyncCopyWith<$Res> {
  __$TitleSyncCopyWithImpl(this._self, this._then);

  final _TitleSync _self;
  final $Res Function(_TitleSync) _then;

/// Create a copy of TitleSync
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? providersFetchedAt = freezed,Object? linksFetchedAt = freezed,Object? linksStatus = freezed,}) {
  return _then(_TitleSync(
providersFetchedAt: freezed == providersFetchedAt ? _self.providersFetchedAt : providersFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,linksFetchedAt: freezed == linksFetchedAt ? _self.linksFetchedAt : linksFetchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,linksStatus: freezed == linksStatus ? _self.linksStatus : linksStatus // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TitleDetail {

 Title get title; List<Availability> get availability; TitleSync get sync;
/// Create a copy of TitleDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TitleDetailCopyWith<TitleDetail> get copyWith => _$TitleDetailCopyWithImpl<TitleDetail>(this as TitleDetail, _$identity);

  /// Serializes this TitleDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TitleDetail&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.availability, availability)&&(identical(other.sync, sync) || other.sync == sync));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(availability),sync);

@override
String toString() {
  return 'TitleDetail(title: $title, availability: $availability, sync: $sync)';
}


}

/// @nodoc
abstract mixin class $TitleDetailCopyWith<$Res>  {
  factory $TitleDetailCopyWith(TitleDetail value, $Res Function(TitleDetail) _then) = _$TitleDetailCopyWithImpl;
@useResult
$Res call({
 Title title, List<Availability> availability, TitleSync sync
});


$TitleCopyWith<$Res> get title;$TitleSyncCopyWith<$Res> get sync;

}
/// @nodoc
class _$TitleDetailCopyWithImpl<$Res>
    implements $TitleDetailCopyWith<$Res> {
  _$TitleDetailCopyWithImpl(this._self, this._then);

  final TitleDetail _self;
  final $Res Function(TitleDetail) _then;

/// Create a copy of TitleDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? availability = null,Object? sync = null,}) {
  return _then(TitleDetail(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as Title,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as List<Availability>,sync: null == sync ? _self.sync : sync // ignore: cast_nullable_to_non_nullable
as TitleSync,
  ));
}
/// Create a copy of TitleDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TitleCopyWith<$Res> get title {
  
  return $TitleCopyWith<$Res>(_self.title, (value) {
    return _then(_self.copyWith(title: value));
  });
}/// Create a copy of TitleDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TitleSyncCopyWith<$Res> get sync {
  
  return $TitleSyncCopyWith<$Res>(_self.sync, (value) {
    return _then(_self.copyWith(sync: value));
  });
}
}


/// Adds pattern-matching-related methods to [TitleDetail].
extension TitleDetailPatterns on TitleDetail {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TitleDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TitleDetail() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TitleDetail value)  $default,){
final _that = this;
switch (_that) {
case _TitleDetail():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TitleDetail value)?  $default,){
final _that = this;
switch (_that) {
case _TitleDetail() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Title title,  List<Availability> availability,  TitleSync sync)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TitleDetail() when $default != null:
return $default(_that.title,_that.availability,_that.sync);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Title title,  List<Availability> availability,  TitleSync sync)  $default,) {final _that = this;
switch (_that) {
case _TitleDetail():
return $default(_that.title,_that.availability,_that.sync);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Title title,  List<Availability> availability,  TitleSync sync)?  $default,) {final _that = this;
switch (_that) {
case _TitleDetail() when $default != null:
return $default(_that.title,_that.availability,_that.sync);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TitleDetail implements TitleDetail {
  const _TitleDetail({required this.title,  List<Availability> availability = const <Availability>[], this.sync = const TitleSync()}): _availability = availability;
  factory _TitleDetail.fromJson(Map<String, dynamic> json) => _$TitleDetailFromJson(json);

@override final  Title title;
 final  List<Availability> _availability;
@override@JsonKey() List<Availability> get availability {
  if (_availability is EqualUnmodifiableListView) return _availability;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availability);
}

@override@JsonKey() final  TitleSync sync;

/// Create a copy of TitleDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TitleDetailCopyWith<_TitleDetail> get copyWith => __$TitleDetailCopyWithImpl<_TitleDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TitleDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TitleDetail&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._availability, _availability)&&(identical(other.sync, sync) || other.sync == sync));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,const DeepCollectionEquality().hash(_availability),sync);

@override
String toString() {
  return 'TitleDetail(title: $title, availability: $availability, sync: $sync)';
}


}

/// @nodoc
abstract mixin class _$TitleDetailCopyWith<$Res> implements $TitleDetailCopyWith<$Res> {
  factory _$TitleDetailCopyWith(_TitleDetail value, $Res Function(_TitleDetail) _then) = __$TitleDetailCopyWithImpl;
@override @useResult
$Res call({
 Title title, List<Availability> availability, TitleSync sync
});


@override $TitleCopyWith<$Res> get title;@override $TitleSyncCopyWith<$Res> get sync;

}
/// @nodoc
class __$TitleDetailCopyWithImpl<$Res>
    implements _$TitleDetailCopyWith<$Res> {
  __$TitleDetailCopyWithImpl(this._self, this._then);

  final _TitleDetail _self;
  final $Res Function(_TitleDetail) _then;

/// Create a copy of TitleDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? availability = null,Object? sync = null,}) {
  return _then(_TitleDetail(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as Title,availability: null == availability ? _self._availability : availability // ignore: cast_nullable_to_non_nullable
as List<Availability>,sync: null == sync ? _self.sync : sync // ignore: cast_nullable_to_non_nullable
as TitleSync,
  ));
}

/// Create a copy of TitleDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TitleCopyWith<$Res> get title {
  
  return $TitleCopyWith<$Res>(_self.title, (value) {
    return _then(_self.copyWith(title: value));
  });
}/// Create a copy of TitleDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TitleSyncCopyWith<$Res> get sync {
  
  return $TitleSyncCopyWith<$Res>(_self.sync, (value) {
    return _then(_self.copyWith(sync: value));
  });
}
}

// dart format on
