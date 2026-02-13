/// تنسيق السعر بذكاء — إزالة .00 إذا كان الرقم صحيحاً
String formatPrice(double price) {
  if (price == price.roundToDouble()) {
    return price.toInt().toString();
  }
  return price.toStringAsFixed(2);
}

/// تحويل اسم طريقة الدفع من API إلى الاسم المعروض بالعربي
String getPaymentMethodDisplayName(String method) {
  switch (method.toLowerCase()) {
    case 'cash':
      return 'الدفع عند الاستلام';
    case 'jeeb':
      return 'جيب';
    case 'mobile_money':
      return 'موبايل موني';
    case 'jawali':
      return 'جوالي';
    default:
      return method;
  }
}
