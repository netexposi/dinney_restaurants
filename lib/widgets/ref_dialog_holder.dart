import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RefDialogHolder extends ConsumerWidget{
  final WidgetRef reference;
  final Dialog diag; 

  const RefDialogHolder( {super.key, required this.reference,required this.diag});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return diag;
  }
}