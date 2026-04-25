class AppValidator {
  static bool hasEmoji(String text) {
    final RegExp emojiRegex = RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
    );
    return emojiRegex.hasMatch(text);
  }
}
