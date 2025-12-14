// HERE YOU CAN MANAGE THE EMAIL TEMPLATES AND EDIT THEM AS YOU LIKE
class EmailTemplates {
  // Stock Decretion Verification Email
  static const String stockDecretionSubject =
      'TeWo Service: Stock Transfer o Deleting';
  static String stockDecretionBody({
    required String userAlias,
    required String productId,
    required String reasonText,
    required int currentStock,
    required int stockToDecrease,
    required int newStock,
    required String verificationCode,
  }) {
    return '''
The $userAlias requested a stock decretion of the product $productId.
The reason that $userAlias have provided was:
$reasonText.

The current stock is $currentStock and the user wants to delete $stockToDecrease if you grant permission the new stock will be $newStock.
SUMMARY:
Current Stock: $currentStock
Stock to Decrease: $stockToDecrease
Total (If you grant permission): $newStock

Your verification code to grant permission is: $verificationCode

If you won't authorize to make changes, ignore this message.
''';
  }

  // Business Settings Verification Email (from older code, refactoring here for consistency)
  static const String businessSettingsSubject = 'Verification Code Request';
  static String businessSettingsBody({required String generatedCode}) {
    return 'Your verification code is: $generatedCode';
  }

  // Setup Login Verification
  static const String setupLoginSubject = 'TeWo Security: Login Verification';
  static String setupLoginBody({
    required String generatedCode,
    String? location, // Optional context
  }) {
    return '''
A login/setup action requires verification.
Your verification code is: $generatedCode

If you did not perform this action, ignore this message.
''';
  }

  // Edit Stock (General Modification)
  static const String editStockSubject =
      'TeWo Service: Stock Item Modification';
  static String editStockBody({
    required String userAlias,
    required String productId,
    required String changesSummary,
    required String verificationCode,
  }) {
    return '''
User $userAlias requested to modify details for product $productId.

Proposed Changes:
$changesSummary

Verification code to authorize this change: $verificationCode
''';
  }

  // User Deletion
  static const String deleteUserSubject = 'TeWo Admin: User Deletion Request';
  static String deleteUserBody({
    required String requestorAlias,
    required String targetUserAlias,
    required String targetUserId,
    required String verificationCode,
  }) {
    return '''
Admin $requestorAlias has requested to DELETE the following user:
User: $targetUserAlias
ID: $targetUserId

This action usually cannot be undone.

Verification code to confirm deletion: $verificationCode
''';
  }
}
