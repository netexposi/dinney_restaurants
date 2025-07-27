import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

SnackBar SuccessMessage(message){return SnackBar(
      content: Text(message),
      backgroundColor: Colors.green,
      padding: EdgeInsets.all(16.sp),
      behavior: SnackBarBehavior.floating,
      );
}

SnackBar ErrorMessage(message){return SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      padding: EdgeInsets.all(16.sp),
      behavior: SnackBarBehavior.floating,
      );
}