import 'package:dinney_restaurant/generated/l10n.dart';
import 'package:dinney_restaurant/utils/constants.dart';
import 'package:dinney_restaurant/widgets/InputField.dart';
import 'package:dinney_restaurant/widgets/pop_up_message.dart';
import 'package:dinney_restaurant/widgets/spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackView extends ConsumerWidget{
  final TextEditingController messageController = TextEditingController();
  final supabase = Supabase.instance.client;
  FeedbackView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).contact_us),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          spacing: 16.sp,
          children: [
            Text(S.of(context).we_would_love_to_hear_from_you, style: Theme.of(context).textTheme.bodyLarge,),
            InputField(
              controller: messageController,
              hintText: S.of(context).message,
              maxLines: 15,
            ),
            ref.watch(savingLoadingButton) ? 
            LoadingSpinner() : 
            ElevatedButton(
              onPressed: () async{

                if(messageController.text.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(
                    ErrorMessage(S.of(context).message_empty)
                  );
                  return;
                }else{
                  ref.read(savingLoadingButton.notifier).state = true;
                  await supabase.from("feedbacks").insert({
                    "message": messageController.text,
                    "user_id": supabase.auth.currentUser?.id,
                    "app": "Restaurant App"
                  }).whenComplete((){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SuccessMessage(S.of(context).message_sent_successfully)
                    );
                    ref.read(savingLoadingButton.notifier).state = false;
                    messageController.clear();
                    Navigator.pop(context);
                  });
                }
              }, 
              child: Text(S.of(context).send)
            )
          ],
        ),
      ),
    );
  }

}