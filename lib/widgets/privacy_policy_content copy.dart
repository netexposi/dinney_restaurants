import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PrivacyPolicyContent extends StatelessWidget {
  final int languageIndex; // 0 = English, 1 = Arabic, 2 = French

  const PrivacyPolicyContent({super.key, required this.languageIndex});

  @override
  Widget build(BuildContext context) {
    final texts = _getTexts(languageIndex);

    final titleStyle = TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.bold,
    );

    final sectionTitleStyle = TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    );

    final contentStyle = TextStyle(
      fontSize: 11.sp,
      height: 1.5,
      color: Colors.grey[800],
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: SingleChildScrollView(
        child: Directionality(
          textDirection:
              languageIndex == 1 ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(texts["title"]!, style: titleStyle),
              SizedBox(height: 1.h),
              Text(texts["last_updated"]!, style: contentStyle),
              SizedBox(height: 1.h),
              Text(texts["intro"]!, style: contentStyle),
              SizedBox(height: 2.h),

              // Sections
              for (int i = 1; i <= 10; i++) ...[
                Text(texts["section${i}_title"]!, style: sectionTitleStyle),
                SizedBox(height: 0.5.h),
                Text(texts["section${i}_content"]!, style: contentStyle),
                SizedBox(height: 1.5.h),
              ],

              Text(texts["contact"]!, style: sectionTitleStyle),
              SizedBox(height: 0.5.h),
              Text(texts["contact_content"]!, style: contentStyle),

              SizedBox(height: 3.h),
              Text("© 2025 DINNEY", style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, String> _getTexts(int lang) {
    switch (lang) {
      // 🔹 Arabic
      case 1:
        return {
          "title": "سياسة الخصوصية",
          "last_updated": "آخر تحديث: 18 أكتوبر 2025\n\n",
          "intro":
              "تصف سياسة الخصوصية هذه لتطبيق دينّي (\"نحن\" أو \"لنا\") كيفية جمعنا لمعلوماتك الشخصية واستخدامها وحمايتها عندما تستخدم خدماتنا، بما في ذلك تطبيقات الهاتف والموقع الإلكتروني والميزات المرتبطة بها.",

          "section1_title": "1. المعلومات التي نجمعها",
          "section1_content":
              "نجمع المعلومات التي تقدمها لنا مباشرة عند إنشاء حساب أو تعديل ملفك الشخصي أو استخدامك لميزات التطبيق مثل الأنشطة، والمجموعات، والتحديات. قد تشمل هذه المعلومات اسمك، عنوان بريدك الإلكتروني، موقعك، والأنشطة المسجلة بواسطة GPS.",

          "section2_title": "2. كيفية استخدام المعلومات",
          "section2_content":
              "نستخدم معلوماتك لتحسين تجربتك داخل التطبيق، وتخصيص الميزات، وتحليل الأداء، وتحسين جودة الخدمات. كما نستخدمها للتواصل معك بشأن التحديثات أو الأحداث الرياضية أو عروض جديدة.",

          "section3_title": "3. مشاركة المعلومات",
          "section3_content":
              "لا نبيع بياناتك لأي طرف ثالث. قد نشارك بعض البيانات مع مزودي الخدمات الذين يساعدوننا في تشغيل التطبيق (مثل التحليلات أو التخزين السحابي) مع ضمان التزامهم بالسرية التامة.",

          "section4_title": "4. ملفات تعريف الارتباط (الكوكيز)",
          "section4_content":
              "قد نستخدم ملفات تعريف الارتباط لجمع بيانات استخدام مجهولة لتحسين الأداء وتجربة المستخدم. يمكنك تعطيلها من إعدادات جهازك.",

          "section5_title": "5. أمان البيانات",
          "section5_content":
              "نستخدم إجراءات تقنية وتنظيمية لحماية معلوماتك الشخصية من الوصول أو الاستخدام غير المصرح به. ومع ذلك، لا يمكن ضمان الأمان الكامل عبر الإنترنت.",

          "section6_title": "6. حقوقك",
          "section6_content":
              "يحق لك الوصول إلى بياناتك أو تعديلها أو حذفها في أي وقت من إعدادات الحساب. يمكنك أيضًا طلب تصدير بياناتك أو حذفها نهائيًا عبر التواصل معنا.",

          "section7_title": "7. البيانات الجغرافية والموقع",
          "section7_content":
              "يستخدم التطبيق بيانات الموقع لتتبع الأنشطة الرياضية بدقة. يتم حفظ هذه البيانات فقط لغرض تحسين تجربتك، ولن تُشارك مع أطراف خارجية دون موافقتك.",

          "section8_title": "8. بيانات الأطفال",
          "section8_content":
              "خدماتنا غير موجهة للأطفال دون سن 13 عامًا. إذا علمنا أننا جمعنا بيانات من طفل دون موافقة والديه، فسنحذفها فورًا.",

          "section9_title": "9. التغييرات على هذه السياسة",
          "section9_content":
              "قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. سنُخطر المستخدمين عبر إشعار داخل التطبيق أو البريد الإلكتروني في حال وجود تغييرات جوهرية.",

          "section10_title": "10. القوانين المعمول بها",
          "section10_content":
              "تخضع هذه السياسة وتُفسّر وفقًا لقوانين الجزائر، بغض النظر عن تعارض القوانين بين الولايات أو الدول.",

          "contact": "التواصل معنا",
          "contact_content":
              "إذا كان لديك أي أسئلة حول سياسة الخصوصية هذه، يمكنك التواصل معنا عبر البريد الإلكتروني: mahdaouiaboudi@gmail.com.",
        };

      // 🔹 French
      case 2:
        return {
          "title": "POLITIQUE DE CONFIDENTIALITÉ",
          "last_updated": "Dernière mise à jour : 18 octobre 2025\n\n",
          "intro":
              "Cette politique de confidentialité pour l'application Dinney (« nous », « notre ») explique comment nous collectons, utilisons et protégeons vos informations personnelles lorsque vous utilisez nos services, y compris notre application mobile et nos fonctionnalités associées.",

          "section1_title": "1. Informations que nous collectons",
          "section1_content":
              "Nous collectons les informations que vous fournissez lors de la création de votre compte, la modification de votre profil ou l'utilisation de nos fonctionnalités comme les activités, les groupes et les défis. Cela inclut votre nom, adresse e-mail, localisation et données GPS.",

          "section2_title": "2. Comment nous utilisons vos informations",
          "section2_content":
              "Nous utilisons vos informations pour améliorer l'expérience utilisateur, personnaliser les fonctionnalités, analyser les performances et assurer la qualité de nos services. Nous pouvons également vous envoyer des mises à jour ou des informations sur des événements sportifs.",

          "section3_title": "3. Partage des informations",
          "section3_content":
              "Nous ne vendons pas vos données. Certaines informations peuvent être partagées avec des prestataires de services (hébergement, analyses) sous des conditions strictes de confidentialité.",

          "section4_title": "4. Cookies",
          "section4_content":
              "Nous utilisons des cookies pour collecter des données anonymes d'utilisation afin d'améliorer les performances et l'expérience utilisateur. Vous pouvez les désactiver dans les paramètres de votre appareil.",

          "section5_title": "5. Sécurité des données",
          "section5_content":
              "Nous utilisons des mesures techniques et organisationnelles pour protéger vos données personnelles contre tout accès non autorisé. Aucun système n’est toutefois totalement sécurisé.",

          "section6_title": "6. Vos droits",
          "section6_content":
              "Vous pouvez consulter, modifier ou supprimer vos données à tout moment depuis les paramètres de votre compte. Vous pouvez également demander l'exportation ou la suppression complète de vos données.",

          "section7_title": "7. Données de localisation",
          "section7_content":
              "L’application utilise les données de localisation pour suivre vos activités sportives avec précision. Ces données ne sont partagées avec personne sans votre consentement.",

          "section8_title": "8. Données des enfants",
          "section8_content":
              "Nos services ne sont pas destinés aux enfants de moins de 13 ans. Si nous découvrons que nous avons collecté des données sans autorisation parentale, nous les supprimerons immédiatement.",

          "section9_title": "9. Modifications de la politique",
          "section9_content":
              "Nous pouvons mettre à jour cette politique de confidentialité à tout moment. En cas de changement important, vous serez notifié via l’application ou par e-mail.",

          "section10_title": "10. Lois applicables",
          "section10_content":
              "Cette politique est régie et interprétée selon les lois de l’Algérie, indépendamment des conflits de juridictions.",

          "contact": "Nous contacter",
          "contact_content":
              "Pour toute question relative à cette politique de confidentialité, veuillez nous contacter à : mahdaouiaboudi@gmail.com.",
        };

      // 🔹 English (default)
      default:
        return {
          "title": "PRIVACY POLICY",
          "last_updated": "Last updated: October 18, 2025\n\n",
          "intro":
              "This Privacy Policy for the Dinney app (\"we\", \"us\", or \"our\") describes how we collect, use, and protect your personal information when you use our services, including our mobile application and related features.",

          "section1_title": "1. Information We Collect",
          "section1_content":
              "We collect the information you provide when creating an account, editing your profile, or using features like activities, clubs, and challenges. This may include your name, email address, location, and GPS-tracked activity data.",

          "section2_title": "2. How We Use Your Information",
          "section2_content":
              "Your data is used to improve the app experience, personalize features, analyze performance, and enhance service quality. We may also send you updates or notifications about sports events and challenges.",

          "section3_title": "3. Sharing Your Information",
          "section3_content":
              "We do not sell your personal information. We may share limited data with service providers that support app operations (e.g., analytics or cloud storage), bound by strict confidentiality agreements.",

          "section4_title": "4. Cookies and Tracking",
          "section4_content":
              "We may use cookies or similar technologies to collect anonymous usage data that helps improve performance and user experience. You can disable them in your device settings.",

          "section5_title": "5. Data Security",
          "section5_content":
              "We apply technical and organizational measures to protect your personal data from unauthorized access, loss, or misuse. However, no system is completely secure online.",

          "section6_title": "6. Your Rights",
          "section6_content":
              "You can access, modify, or delete your personal data at any time from your account settings. You can also request data export or permanent deletion by contacting us.",

          "section7_title": "7. Location Data",
          "section7_content":
              "The app uses GPS data to record and display your running or cycling routes. This data is stored securely and never shared with third parties without your consent.",

          "section8_title": "8. Children’s Data",
          "section8_content":
              "Our services are not directed toward children under 13. If we discover that we have collected data from a child without parental consent, we will delete it immediately.",

          "section9_title": "9. Policy Updates",
          "section9_content":
              "We may update this Privacy Policy from time to time. Significant changes will be communicated via in-app notification or email.",

          "section10_title": "10. Governing Law",
          "section10_content":
              "This Privacy Policy is governed by and interpreted in accordance with the laws of Algeria, regardless of conflicts of jurisdiction.",

          "contact": "Contact Us",
          "contact_content":
              "If you have any questions about this Privacy Policy, contact us at: mahdaouiaboudi@gmail.com.",
        };
    }
  }
}
