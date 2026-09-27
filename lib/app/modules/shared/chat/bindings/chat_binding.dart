import 'package:get/get.dart';
import 'package:harvest_hub/app/modules/shared/chat/controllers/chat_inbox_controller.dart';
import 'package:harvest_hub/app/modules/shared/chat/controllers/chat_room_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatInboxController>(() => ChatInboxController());
    Get.lazyPut<ChatRoomController>(() => ChatRoomController());
  }
}
