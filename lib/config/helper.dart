import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:musicxy/config/app_colors.dart';
import 'package:musicxy/config/const.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static const String languageCodeEn = 'en';
  static const String languageCodeSr = 'sr';
  static String languageCodeDefault = languageCodeEn;

  static void darkStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.greyColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  LinearGradient masterGradiant = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.masterGradiantOne, AppColors.masterGradiantTwo],
  );
  LinearGradient greenGradiant = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.greenGradiantOne, AppColors.greenGradiantTwo],
  );

  bool getDeviceType() {
    if (Platform.isAndroid) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      PermissionStatus storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    } else if (Platform.isIOS) {
      PermissionStatus photosStatus = await Permission.photos.request();
      return photosStatus.isGranted || photosStatus.isLimited;
    }
    return false;
  }

  void showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          content: const Text(
            'Please allow SparkdAI to access your album in "Settings" > "Privacy" > "Photos".',
            textAlign: TextAlign.center,
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void urlLaunch(Uri url) async {
    printAction("urlLaunchurlLaunch");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<ByteData> textToByteData(String text, {double fontSize = 20}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromPoints(const Offset(0.0, 0.0), const Offset(100.0, 100.0)),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.black, fontSize: fontSize),
      ),
    );

    textPainter.layout();
    textPainter.paint(canvas, const Offset(0.0, 0.0));

    final picture = recorder.endRecording();
    final img = await picture.toImage(100, 100);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData!;
  }

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        if (Directory('/storage/emulated/0/Download').existsSync()) {
          directory = Directory('/storage/emulated/0/Download');
        } else {
          Directory('/storage/emulated/0/Download').create();
          directory = Directory('/storage/emulated/0/Download');
        }
      }
    } catch (err) {
      printError("Cannot get download folder path");
    }
    return directory?.path;
  }

  Future<bool> getPermission() async {
    bool isPermission = false;
    if (currentSdk >= 33 && Platform.isAndroid) {
      isPermission = true;
    } else {
      var status = await Permission.storage.status;
      if (status.isGranted) {
        isPermission = true;
      } else {
        status = await Permission.storage.request();
        if (status.isGranted) {
          isPermission = true;
        }
      }
    }
    return isPermission;
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    ))!.buffer.asUint8List();
  }

  static int currentSdk = 0;

  checkDeviceSdk() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final androidInfo = await deviceInfoPlugin.androidInfo;
      currentSdk = androidInfo.version.sdkInt;
    }
  }

  Future<String> getFileSizeInKBMB(String filePath) async {
    try {
      File file = File(filePath);
      int sizeInBytes = await file.length();

      double sizeInKB = sizeInBytes / 1024.0;
      double sizeInMB = sizeInKB / 1024.0;

      if (sizeInMB >= 1) {
        return '${sizeInMB.toStringAsFixed(2)} MB';
      } else if (sizeInKB >= 1) {
        return '${sizeInKB.toStringAsFixed(2)} KB';
      } else {
        return '$sizeInBytes bytes';
      }
    } catch (e) {
      print('Error getting file size: $e');
    }
    return '';
  }

  flutterDatePicker({
    String? dateFormat,
    DateTime? initialTime,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    print("initialTime ${initialTime}");
    DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      keyboardType: TextInputType.text,
      initialDate:
          initialTime ??
          DateTime(
            DateTime.now().year - 18,
            DateTime.now().month,
            DateTime.now().day - 1,
          ),
      confirmText: (languageCodeDefault == "en") ? "OK" : "POTVRDI",
      firstDate: firstDate ?? DateTime(1900),
      lastDate:
          lastDate ??
          DateTime(
            DateTime.now().year - 18,
            DateTime.now().month,
            DateTime.now().day - 1,
          ),
      locale: Locale.fromSubtags(
        languageCode: languageCodeDefault,
        scriptCode: (languageCodeDefault == 'sr') ? 'Latn' : null,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.greenGradiantTwo,
              onPrimary: Colors.white,
              onSurface: AppColors.greenGradiantOne,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.greenGradiantTwo,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    String? formattedDate;
    if (pickedDate != null) {
      formattedDate = DateFormat(
        dateFormat ?? "yyyy-MM-dd",
        Locale.fromSubtags(
          languageCode: languageCodeDefault,
          scriptCode: (languageCodeDefault == 'sr') ? 'Latn' : null,
        ).toString(),
      ).format(pickedDate);
    }
    return formattedDate;
  }

  String convertLocalToUtc(
    String? inputDateTime,
    String? inputDateFormat,
    String? outputDateFormat,
  ) {
    if (!utils.isValidationEmpty(inputDateTime)) {
      inputDateTime = concatenateSec(inputDateTime);
      final utcDateTime = DateFormat(
        inputDateFormat,
        Locale.fromSubtags(
          languageCode: languageCodeDefault,
          scriptCode: (languageCodeDefault == 'sr') ? 'Latn' : null,
        ).toString(),
      ).parse(inputDateTime);

      final localDateTime = utcDateTime.toUtc();

      final formatter = DateFormat(outputDateFormat);
      final localDateTimeString = formatter.format(localDateTime);
      printAction("test_convertLocalToUtc: $localDateTimeString");
      return localDateTimeString;
    } else {
      return "";
    }
  }

  String convertLocalToUtcNow({String? date}) {
    String name = date ?? DateTime.now().toString();
    print("time time time ${name}");
    if (!utils.isValidationEmpty(DateTime.now().toString())) {
      final utcDateTime = DateFormat(
        "yyyy-MM-dd HH:mm:ss",
      ).parse(concatenateSec(DateTime.now().toString()));

      final localDateTime = utcDateTime.toUtc();

      final formatter = DateFormat("yyyy-MM-dd HH:mm:ss");
      final localDateTimeString = formatter.format(localDateTime);
      printAction("test_convertLocalToUtc: $localDateTimeString");
      return localDateTimeString;
    } else {
      return "";
    }
  }

  String concatenateSec(String? inputDateTime) {
    if (inputDateTime!.contains(':') && inputDateTime.split(':').length != 3) {
      inputDateTime = "${inputDateTime}:00";
    }
    printAction("test_inputDateTime: $inputDateTime");
    return inputDateTime;
  }

  String convertUtcToLocal(
    String? inputDateTime,
    String? inputDateFormat,
    String? outputDateFormat,
  ) {
    if (!utils.isValidationEmpty(inputDateTime)) {
      printAction("test_convertUtcToLocal: inputDateTime ${inputDateTime}");

      final utcDateTime = DateFormat(
        inputDateFormat,
        Locale.fromSubtags(
          languageCode: languageCodeDefault,
          scriptCode: (languageCodeDefault == 'sr') ? 'Latn' : null,
        ).toString(),
      ).parseUtc(inputDateTime!);

      final localDateTime = utcDateTime.toLocal();

      final formatter = DateFormat(
        outputDateFormat,
        Locale.fromSubtags(
          languageCode: languageCodeDefault,
          scriptCode: (languageCodeDefault == 'sr') ? 'Latn' : null,
        ).toString(),
      );
      final localDateTimeString = formatter.format(localDateTime);
      printAction(
        "test_convertUtcToLocal: localDateTimeString: $localDateTimeString",
      );
      return localDateTimeString;
    } else {
      return "";
    }
  }

  String displayDifferenceNotification({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    String convTime = '';

    Duration difference = startDate.difference(endDate);

    final int secondsInMilli = 1000;
    final int minutesInMilli = secondsInMilli * 60;
    final int hoursInMilli = minutesInMilli * 60;
    final int daysInMilli = hoursInMilli * 24;

    final int elapsedDays = difference.inMilliseconds ~/ daysInMilli;
    difference = Duration(
      milliseconds: difference.inMilliseconds % daysInMilli,
    );

    final int elapsedHours = difference.inMilliseconds ~/ hoursInMilli;
    difference = Duration(
      milliseconds: difference.inMilliseconds % hoursInMilli,
    );

    final int elapsedMinutes = difference.inMilliseconds ~/ minutesInMilli;
    difference = Duration(
      milliseconds: difference.inMilliseconds % minutesInMilli,
    );

    final int elapsedSeconds = difference.inMilliseconds ~/ secondsInMilli;

    if (elapsedDays > 0 && elapsedDays < 7) {
      if (elapsedDays > 1) {
      } else {}
    } else if (elapsedDays >= 7) {
      if (elapsedDays > 360) {
        convTime = customDateTimeFormat(
          endDate.toString(),
          "yyyy-MM-dd HH:mm:ss",
          "dd MMM yyyy",
        );
      } else if (elapsedDays > 30) {
        convTime = customDateTimeFormat(
          endDate.toString(),
          "yyyy-MM-dd HH:mm:ss",
          "dd MMM yyyy",
        );
      } else {}
    } else if (elapsedHours > 0) {
    } else if (elapsedMinutes > 0) {
    } else if (elapsedSeconds > 10) {
    } else {}

    printAction("test_displayDifference_startDate: ${startDate.toString()}");
    printAction("test_displayDifference_endDate: ${endDate.toString()}");
    printAction("test_displayDifference_convTime: $convTime");
    return convTime;
  }

  DateTime getDateTimeFromCustomDateTimeFormat(
    String? inputDateTime,
    String? inputDateFormat,
  ) {
    printAction("test_inputDateTime: $inputDateTime");
    if (!isValidationEmpty(inputDateTime)) {
      var inputFormat = DateFormat(
        inputDateFormat,
        Locale.fromSubtags(
          languageCode: languageCodeDefault,
          scriptCode: (languageCodeDefault == 'sr') ? 'Latn' : null,
        ).toString(),
      );
      var inputDate = inputFormat.parse(inputDateTime!);
      printAction("test_inputDate: $inputDate");

      return inputDate;
    } else {
      return DateTime.now();
    }
  }

  String customDateTimeFormat(
    String? inputDateTime,
    String? inputDateFormat,
    String? outputDateFormat,
  ) {
    if (!isValidationEmpty(inputDateTime)) {
      var inputFormat = DateFormat(
        inputDateFormat,
        Locale.fromSubtags(
          languageCode: languageCodeDefault,
          scriptCode: (languageCodeDefault == 'sr') ? 'Latn' : null,
        ).toString(),
      );
      var inputDate = inputFormat.parse(inputDateTime!);
      printAction("test_inputDate: $inputDate");

      var outputFormat = DateFormat(
        outputDateFormat,
        Locale.fromSubtags(
          languageCode: languageCodeDefault,
          scriptCode: (languageCodeDefault == 'sr') ? 'Latn' : null,
        ).toString(),
      );
      var outputDate = outputFormat.format(inputDate);
      printAction("test_outputDate: $outputDate");

      return outputDate;
    } else {
      return "";
    }
  }

  String formatTimeOfDay(TimeOfDay timeOfDay, Locale locale) {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    DateFormat dateFormat = DateFormat.Hm(locale.toString());
    return dateFormat.format(dateTime);
  }

  flutterTimePicker({TimeOfDay? initialTime}) async {
    TimeOfDay? pickedTime = await showTimePicker(
      initialTime: initialTime ?? TimeOfDay.now(),
      confirmText: (languageCodeDefault == "en") ? "OK" : "POTVRDI",
      context: Get.context!,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.greenGradiantTwo,
              onPrimary: Colors.white,
              onSurface: AppColors.greenGradiantOne,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.greenGradiantTwo,
              ),
            ),
          ),
          child: Localizations.override(
            context: context,
            locale: Locale.fromSubtags(
              languageCode: languageCodeDefault,
              scriptCode: (languageCodeDefault == 'sr') ? 'Latn' : null,
            ),
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(alwaysUse24HourFormat: false),
              child: child!,
            ),
          ),
        );
      },
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      return DateFormat(
        languageCodeDefault == 'sr' ? "HH:mm" : "hh:mm aa",
      ).format(dateTime);
    } else {
      print("Time is not selected");
      return null;
    }
  }

  static void lightStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: (Platform.isAndroid)
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: (Platform.isAndroid)
            ? Brightness.dark
            : Brightness.light,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarDividerColor: AppColors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  static void screenPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void showToast({required String message}) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG,
      textColor: AppColors.white,
      backgroundColor: Colors.black.withOpacity(0.8),
      timeInSecForIosWeb: 30,
    );
  }

  bool emailValidator(String email) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(p);
    if (regExp.hasMatch(email)) {
      return true;
    }
    return false;
  }

  bool phoneValidator(String contact) {
    String p = r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
    RegExp regExp = RegExp(p);
    if (regExp.hasMatch(contact)) {
      return true;
    }
    return false;
  }

  bool passwordValidator(String contact) {
    String p = r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$";
    RegExp regExp = RegExp(p);
    if (regExp.hasMatch(contact)) {
      return true;
    }
    return false;
  }

  bool isValidationEmpty(String? val) {
    if (val == null ||
        val.isEmpty ||
        val == "null" ||
        val == "" ||
        val == "NULL") {
      return true;
    } else {
      return false;
    }
  }

  void showSnackBar({required String message, int? statusCode}) {
    Get.snackbar(
      "",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: statusCode == 1 ? Colors.green : const Color(0xFFD55959),
      titleText: statusCode == 1
          ? const Text("Succes", style: TextStyle(color: Colors.white))
          : const Text("Error", style: TextStyle(color: Colors.white)),
      borderRadius: 10,
      margin: const EdgeInsets.all(12),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      padding: const EdgeInsets.only(bottom: 15, top: 10, left: 15, right: 15),
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeInOut,
    );
  }

  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  String countryCodeToEmoji(String countryCode) {
    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  static transformMilliSeconds(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();
    int hours = (minutes / 60).truncate();

    String hoursStr = (hours % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String strTime = '';
    if (hoursStr == '00' || hoursStr == '0') {
      strTime = '$minutesStr:$secondsStr';
    } else {
      strTime = '$hoursStr:$minutesStr:$secondsStr';
    }
    return strTime;
  }

  String currentTime() {
    String month = DateFormat.M().format(DateTime.now().toUtc());
    String day = DateFormat.d().format(DateTime.now().toUtc());
    String time = DateFormat.Hm().format(DateTime.now().toUtc());
    String timeDate =
        '${DateFormat.y().format(DateTime.now().toUtc())}-${month.length == 1 ? '0$month' : month}-${day.length == 1 ? '0$day' : day} $time';
    return timeDate;
  }

  String currentDate(String outputFormat) {
    var now = DateTime.now().toUtc();
    var formatter = DateFormat(outputFormat);
    String formattedDate = formatter.format(now);
    return formattedDate;
  }

  List<String> fillSlots() {
    List<String> list = [];
    for (int i = 1; i <= 100; i++) {
      list.add("$i");
    }
    return list;
  }

  Future<String> getFileNameWithExtension(File file) async {
    if (await file.exists()) {
      return path.basename(file.path);
    } else {
      return "";
    }
  }

  String changeDateFormat({DateTime? date, String? outputFormat}) {
    if (date != null) {
      DateFormat formatter = DateFormat(outputFormat);
      String formatted = formatter.format(date);
      return formatted;
    }
    return '';
  }

  String timeAgoSinceDate(String dateString, {bool numericDates = true}) {
    DateTime dateUtc = DateTime.parse(dateString);
    var dateTime = DateFormat(
      "yyyy-MM-dd HH:mm:ss",
    ).parse(dateUtc.toString(), true);
    DateTime date = dateTime.toLocal();
    final date2 = DateTime.now();
    final difference = date2.difference(date);

    if ((difference.inDays / 365).floor() >= 2) {
      return (numericDates)
          ? '${(difference.inDays / 365).floor()} Y'
          : '${(difference.inDays / 365).floor()} Years ago';
    } else if ((difference.inDays / 365).floor() >= 1) {
      return (numericDates) ? '1 Y' : 'Last year';
    } else if ((difference.inDays / 30).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} M';
    } else if ((difference.inDays / 30).floor() >= 1) {
      return (numericDates) ? '1 M' : 'Last Month';
    } else if ((difference.inDays / 7).floor() >= 2) {
      return (numericDates)
          ? '${(difference.inDays / 7).floor()} w'
          : '${(difference.inDays / 7).floor()} Weeks ago';
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1 w' : 'Last week';
    } else if (difference.inDays >= 2) {
      return (numericDates)
          ? '${difference.inDays} d'
          : '${difference.inDays} Days ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 d' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours} h';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 h' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} min';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 min' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} sec';
    } else {
      return 'now';
    }
  }

  String getDayOfMonthSuffix(int dayNum) {
    if (!(dayNum >= 1 && dayNum <= 31)) {
      throw Exception('Invalid day of month');
    }

    if (dayNum >= 11 && dayNum <= 13) {
      return 'th';
    }

    switch (dayNum % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var format = DateFormat('dd-yyyy,MM HH:mm a');
    var date = DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);
    var diff = date.difference(now);
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else {
      if (diff.inDays == 1) {
        time = '${diff.inDays}DAY AGO';
      } else {
        time = '${diff.inDays}DAYS AGO';
      }
    }

    return time;
  }
}

void printAction(String text) {
  if (Platform.isAndroid) {
    debugPrint('\x1B[94m$text\x1B[0m');
  } else {
    debugPrint(text);
  }
}

void printCancel(String text) {
  if (Platform.isAndroid) {
    debugPrint('\x1B[96m$text\x1B[0m');
  } else {
    debugPrint(text);
  }
}

void printWhite(String text) {
  if (Platform.isAndroid) {
    debugPrint('\x1B[97m$text\x1B[0m');
  } else {
    debugPrint(text);
  }
}

void printOkStatus(String text) {
  if (Platform.isAndroid) {
    debugPrint('\x1B[92m$text\x1B[0m');
  } else {
    debugPrint(text);
  }
}

void printError(String text) {
  if (Platform.isAndroid) {
    debugPrint('\x1B[91m$text\x1B[0m');
  } else {
    debugPrint(text);
  }
}

void printWarning(String text) {
  if (Platform.isAndroid) {
    debugPrint('\x1B[93m$text\x1B[0m');
  } else {
    debugPrint(text);
  }
}
