abstract class CustomTagRepository {
  Future<List<String>> getAllCustomTags();
  Future<void> addCustomTag(String tag);
  Future<void> deleteCustomTag(String tag);
}
