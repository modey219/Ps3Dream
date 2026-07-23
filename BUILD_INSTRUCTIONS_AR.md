# خطوات بناء Ps3Dream على iPhone
# بدون ما تحتاج Mac - باستخدام GitHub Actions المجاني

## الخطوة 1: سجّل في GitHub (مجاني)

1. افتح المتصفح وروح لـ: https://github.com
2. اضغط "Sign up" (سجّل)
3. سجّل بريدك الإلكتروني وكلمة المرور
4. خلص التسجيل

## الخطوة 2: أنشئ مستودع جديد

1. بعد تسجيل الدخول اضغط علا +" أعلى اليمين
2. اختر "New repository"
3. اكتب اسم المستودع: Ps3Dream
4. اختر "Public"
5. اضغط "Create repository"

## الخطوة 3: حمّل GitHub Desktop (أسهل طريقة)

1. روح لـ: https://desktop.github.com
2. حمّل GitHub Desktop وثبّته
3. افتحه وسجّل دخول بحسابك

## الخطوة 4: حمّل ملفات المشروع

1. اضغط Clone repository في GitHub Desktop
2. اختر المستودع اللي سويته (Ps3Dream)
3. اضغط Clone

## الخطوة 5: انسخ ملفات المشروع

انسخ كل ملفات من مجلد ps3dream-ios到المستودع:
- CMakeLists.txt
- build_ios.sh
- Ps3Dream/ (المجلد كامل)
- aps3e-extracted/ (مجلد الكود الأصلي)
- .github/workflows/build.yml

## الخطوة 6: ارفع الكود

1. في GitHub Desktop اضغط "Commit to main"
2. اضغط "Push origin"
3. انتظر شوي

## الخطوة 7: شغّل البناء

1. روح لموقع مستودعك على GitHub
2. اضغط عل تبويب "Actions"
3. بناء تلقائياً يشتغل!
4. انتظر 30-60 دقيقة

## الخطوة 8: حمّل ملف IPA

1. بعد ما يخلص البناء اضغط على "Build Ps3Dream iOS"
2. تحت "Artifacts" بتلقى ملف Ps3Dream.ipa
3. اضغط عليه وحمّله

## الخطوة 9: ثبّت على iPhone

1. حمّل AltStore على الكمبيوتر: https://altstore.io
2. وصّل الآيفون بالكمبيوتر
3. افتح AltStore واضغط "My Apps"
4. اضغط + واختر ملف Ps3Dream.ipa
5. التطبيق يتثبت على جهازك!

ملاحظة: AltStore يحتاجك تسجّل بريد Apple ID عشان يشتغل
