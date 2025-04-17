import 'dart:js_interop';

import 'package:crisp_chat/src/flutter_crisp_chat_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import '../crisp_chat.dart';

@JS('\$crisp.push')
external void crispPush(JSArray<JSAny?> args);

@JS('\$crisp.get')
external String? crispGet(JSString key);

@JS('CRISP_TOKEN_ID')
external set crispTokenId(String? tokenId);

@JS('CRISP_TOKEN_ID')
external String? get crispTokenId;

@JS('CRISP_WEBSITE_ID')
external set crispWebsiteId(String? websiteId);

@JS('CRISP_WEBSITE_ID')
external String? get crispWebsiteId;

class FlutterCrispChatWebPlugin extends FlutterCrispChatPlatform {
  static void registerWith(Registrar registrar) {
    FlutterCrispChatPlatform.instance = FlutterCrispChatWebPlugin();
  }

  @override
  Future<void> openCrispChat({required CrispConfig config}) async {
    final oldWebsiteId = crispWebsiteId;
    final oldTokenId = crispTokenId;

    crispWebsiteId = config.websiteID;
    if (config.tokenId != null) crispTokenId = config.tokenId!;

    if (config.sessionSegment != null) setSessionSegments(segments: [config.sessionSegment!]);
    if (config.user != null) {
      if (config.user!.nickName != null) crispPush(["set".toJS, "user:nickname".toJS, [config.user!.email!.toJS].toJS].toJS);
      if (config.user!.email != null) crispPush(["set".toJS, "user:email".toJS, [config.user!.email!.toJS].toJS].toJS);
      if (config.user!.avatar != null) crispPush(["set".toJS, "user:avatar".toJS, [config.user!.avatar!.toJS].toJS].toJS);
      if (config.user!.phone != null) crispPush(["set".toJS, "user:phone".toJS, [config.user!.phone!.toJS].toJS].toJS);
      if (config.user!.company != null && config.user!.company!.name != null) {
        final company = config.user!.company!;
        crispPush(["set".toJS, "user:company".toJS, [
          company.name!.toJS,
          {
            if (company.url != null) "url": company.url!,
            if (company.companyDescription != null) "description": company.companyDescription!,
            if (company.employment != null) "employment": [company.employment!.title, company.employment!.role],
            if (company.geoLocation != null) "geolocation": [company.geoLocation!.country, company.geoLocation!.city],
          }.jsify()
        ].toJS].toJS);
      }
    }

    if (oldTokenId != config.tokenId || oldWebsiteId != config.websiteID) {
      resetCrispChatSession(); // reset since we've changed the websiteId and tokenId
    }

    crispPush(["do".toJS, "chat:open".toJS].toJS);
  }

  @override
  void setSessionSegments({required List<String> segments, bool overwrite = false}) {
    crispPush(["set".toJS, "session:segments".toJS, [segments.map((s) => s.toJS).toList().toJS, overwrite.toJS].toJS].toJS);
  }

  @override
  Future<String?> getSessionIdentifier() async {
    return crispGet("session:identifier".toJS)?.toString();
  }

  @override
  void setSessionInt({required String key, required int value}) {
    crispPush(["set".toJS, "session:data".toJS, [[[key.toJS, value.toJS].toJS].toJS].toJS].toJS);
  }

  @override
  void setSessionString({required String key, required String value}) {
    crispPush(["set".toJS, "session:data".toJS, [[[key.toJS, value.toJS].toJS].toJS].toJS].toJS);
  }

  @override
  Future<void> resetCrispChatSession() async {
    crispPush(["do".toJS, "session:reset".toJS].toJS);
  }
}