// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon, do not edit directly.
// See also: https://pub.dev/packages/pigeon

#include "messages.g.h"

struct _PigeonExamplePackageMessageData {
  GObject parent_instance;

  gchar* name;
  gchar* description;
  PigeonExamplePackageCode code;
  FlValue* data;
};

G_DEFINE_TYPE(PigeonExamplePackageMessageData,
              pigeon_example_package_message_data, G_TYPE_OBJECT)

static void pigeon_example_package_message_data_dispose(GObject* object) {
  PigeonExamplePackageMessageData* self =
      PIGEON_EXAMPLE_PACKAGE_MESSAGE_DATA(object);
  g_clear_pointer(&self->name, g_free);
  g_clear_pointer(&self->description, g_free);
  g_clear_pointer(&self->data, fl_value_unref);
  G_OBJECT_CLASS(pigeon_example_package_message_data_parent_class)
      ->dispose(object);
}

static void pigeon_example_package_message_data_init(
    PigeonExamplePackageMessageData* self) {}

static void pigeon_example_package_message_data_class_init(
    PigeonExamplePackageMessageDataClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = pigeon_example_package_message_data_dispose;
}

PigeonExamplePackageMessageData* pigeon_example_package_message_data_new(
    const gchar* name, const gchar* description, PigeonExamplePackageCode code,
    FlValue* data) {
  PigeonExamplePackageMessageData* self = PIGEON_EXAMPLE_PACKAGE_MESSAGE_DATA(
      g_object_new(pigeon_example_package_message_data_get_type(), nullptr));
  self->name = g_strdup(name);
  self->description = g_strdup(description);
  self->code = code;
  self->data = g_object_ref(data);
  return self;
}

const gchar* pigeon_example_package_message_data_get_name(
    PigeonExamplePackageMessageData* self) {
  g_return_val_if_fail(PIGEON_EXAMPLE_PACKAGE_IS_MESSAGE_DATA(self), nullptr);
  return self->name;
}

const gchar* pigeon_example_package_message_data_get_description(
    PigeonExamplePackageMessageData* self) {
  g_return_val_if_fail(PIGEON_EXAMPLE_PACKAGE_IS_MESSAGE_DATA(self), nullptr);
  return self->description;
}

PigeonExamplePackageCode pigeon_example_package_message_data_get_code(
    PigeonExamplePackageMessageData* self) {
  g_return_val_if_fail(PIGEON_EXAMPLE_PACKAGE_IS_MESSAGE_DATA(self),
                       static_cast<PigeonExamplePackageCode>(0));
  return self->code;
}

FlValue* pigeon_example_package_message_data_get_data(
    PigeonExamplePackageMessageData* self) {
  g_return_val_if_fail(PIGEON_EXAMPLE_PACKAGE_IS_MESSAGE_DATA(self), nullptr);
  return self->data;
}

static FlValue* pigeon_example_package_message_data_to_list(
    PigeonExamplePackageMessageData* self) {
  FlValue* values = fl_value_new_list();
  fl_value_append_take(values, fl_value_new_string(self->name));
  fl_value_append_take(values, fl_value_new_string(self->description));
  fl_value_append_take(values, fl_value_new_int(self->code));
  fl_value_append_take(values, fl_value_ref(self->data));
  return values;
}

static PigeonExamplePackageMessageData*
pigeon_example_package_message_data_new_from_list(FlValue* values) {
  return pigeon_example_package_message_data_new(
      fl_value_get_string(fl_value_get_list_value(values, 0)),
      fl_value_get_string(fl_value_get_list_value(values, 1)),
      static_cast<PigeonExamplePackageCode>(
          fl_value_get_int(fl_value_get_list_value(values, 2))),
      fl_value_get_list_value(values, 3));
}

G_DECLARE_FINAL_TYPE(PigeonExamplePackageExampleHostApiCodec,
                     pigeon_example_package_example_host_api_codec,
                     PIGEON_EXAMPLE_PACKAGE, EXAMPLE_HOST_API_CODEC,
                     FlStandardMessageCodec)

struct _PigeonExamplePackageExampleHostApiCodec {
  FlStandardMessageCodec parent_instance;
};

G_DEFINE_TYPE(PigeonExamplePackageExampleHostApiCodec,
              pigeon_example_package_example_host_api_codec,
              fl_standard_message_codec_get_type())

static gboolean write_pigeon_example_package_message_data(
    FlStandardMessageCodec* codec, GByteArray* buffer,
    PigeonExamplePackageMessageData* value, GError** error) {
  uint8_t type = 128;
  g_byte_array_append(buffer, &type, sizeof(uint8_t));
  g_autoptr(FlValue) values =
      pigeon_example_package_message_data_to_list(value);
  return fl_standard_message_codec_write_value(codec, buffer, values, error);
}

static gboolean pigeon_example_package_example_host_api_write_value(
    FlStandardMessageCodec* codec, GByteArray* buffer, FlValue* value,
    GError** error) {
  if (fl_value_get_type(value) == FL_VALUE_TYPE_CUSTOM) {
    switch (fl_value_get_custom_type(value)) {
      case 128:
        return write_pigeon_example_package_message_data(
            codec, buffer,
            PIGEON_EXAMPLE_PACKAGE_MESSAGE_DATA(
                fl_value_get_custom_value_object(value)),
            error);
    }
  }

  return FL_STANDARD_MESSAGE_CODEC_CLASS(
             pigeon_example_package_example_host_api_codec_parent_class)
      ->write_value(codec, buffer, value, error);
}

static FlValue* read_pigeon_example_package_message_data(
    FlStandardMessageCodec* codec, GBytes* buffer, size_t* offset,
    GError** error) {
  g_autoptr(FlValue) values =
      fl_standard_message_codec_read_value(codec, buffer, offset, error);
  if (values == nullptr) {
    return nullptr;
  }

  g_autoptr(PigeonExamplePackageMessageData) value =
      pigeon_example_package_message_data_new_from_list(values);
  if (value == nullptr) {
    g_set_error(error, FL_MESSAGE_CODEC_ERROR, FL_MESSAGE_CODEC_ERROR_FAILED,
                "Invalid data received for MessageData");
    return nullptr;
  }

  return fl_value_new_custom_object_take(128, G_OBJECT(value));
}

static FlValue* pigeon_example_package_example_host_api_read_value_of_type(
    FlStandardMessageCodec* codec, GBytes* buffer, size_t* offset, int type,
    GError** error) {
  switch (type) {
    case 128:
      return read_pigeon_example_package_message_data(codec, buffer, offset,
                                                      error);
    default:
      return FL_STANDARD_MESSAGE_CODEC_CLASS(
                 pigeon_example_package_example_host_api_codec_parent_class)
          ->read_value_of_type(codec, buffer, offset, type, error);
  }
}

static void pigeon_example_package_example_host_api_codec_init(
    PigeonExamplePackageExampleHostApiCodec* self) {}

static void pigeon_example_package_example_host_api_codec_class_init(
    PigeonExamplePackageExampleHostApiCodecClass* klass) {
  FL_STANDARD_MESSAGE_CODEC_CLASS(klass)->write_value =
      pigeon_example_package_example_host_api_write_value;
  FL_STANDARD_MESSAGE_CODEC_CLASS(klass)->read_value_of_type =
      pigeon_example_package_example_host_api_read_value_of_type;
}

static PigeonExamplePackageExampleHostApiCodec*
pigeon_example_package_example_host_api_codec_new() {
  PigeonExamplePackageExampleHostApiCodec* self =
      PIGEON_EXAMPLE_PACKAGE_EXAMPLE_HOST_API_CODEC(g_object_new(
          pigeon_example_package_example_host_api_codec_get_type(), nullptr));
  return self;
}

struct _PigeonExamplePackageExampleHostApiGetHostLanguageResponse {
  GObject parent_instance;

  FlValue* value;
};

G_DEFINE_TYPE(
    PigeonExamplePackageExampleHostApiGetHostLanguageResponse,
    pigeon_example_package_example_host_api_get_host_language_response,
    G_TYPE_OBJECT)

static void
pigeon_example_package_example_host_api_get_host_language_response_dispose(
    GObject* object) {
  PigeonExamplePackageExampleHostApiGetHostLanguageResponse* self =
      PIGEON_EXAMPLE_PACKAGE_EXAMPLE_HOST_API_GET_HOST_LANGUAGE_RESPONSE(
          object);
  g_clear_pointer(&self->value, fl_value_unref);
  G_OBJECT_CLASS(
      pigeon_example_package_example_host_api_get_host_language_response_parent_class)
      ->dispose(object);
}

static void
pigeon_example_package_example_host_api_get_host_language_response_init(
    PigeonExamplePackageExampleHostApiGetHostLanguageResponse* self) {}

static void
pigeon_example_package_example_host_api_get_host_language_response_class_init(
    PigeonExamplePackageExampleHostApiGetHostLanguageResponseClass* klass) {
  G_OBJECT_CLASS(klass)->dispose =
      pigeon_example_package_example_host_api_get_host_language_response_dispose;
}

PigeonExamplePackageExampleHostApiGetHostLanguageResponse*
pigeon_example_package_example_host_api_get_host_language_response_new(
    const gchar* return_value) {
  PigeonExamplePackageExampleHostApiGetHostLanguageResponse* self =
      PIGEON_EXAMPLE_PACKAGE_EXAMPLE_HOST_API_GET_HOST_LANGUAGE_RESPONSE(g_object_new(
          pigeon_example_package_example_host_api_get_host_language_response_get_type(),
          nullptr));
  self->value = fl_value_new_list();
  fl_value_append_take(self->value, fl_value_new_string(return_value));
  return self;
}

PigeonExamplePackageExampleHostApiGetHostLanguageResponse*
pigeon_example_package_example_host_api_get_host_language_response_new_error(
    const gchar* code, const gchar* message, FlValue* details) {
  PigeonExamplePackageExampleHostApiGetHostLanguageResponse* self =
      PIGEON_EXAMPLE_PACKAGE_EXAMPLE_HOST_API_GET_HOST_LANGUAGE_RESPONSE(g_object_new(
          pigeon_example_package_example_host_api_get_host_language_response_get_type(),
          nullptr));
  self->value = fl_value_new_list();
  fl_value_append_take(self->value, fl_value_new_string(code));
  fl_value_append_take(self->value, fl_value_new_string(message));
  fl_value_append(self->value, details);
  return self;
}

struct _PigeonExamplePackageExampleHostApiAddResponse {
  GObject parent_instance;

  FlValue* value;
};

G_DEFINE_TYPE(PigeonExamplePackageExampleHostApiAddResponse,
              pigeon_example_package_example_host_api_add_response,
              G_TYPE_OBJECT)

static void pigeon_example_package_example_host_api_add_response_dispose(
    GObject* object) {
  PigeonExamplePackageExampleHostApiAddResponse* self =
      PIGEON_EXAMPLE_PACKAGE_EXAMPLE_HOST_API_ADD_RESPONSE(object);
  g_clear_pointer(&self->value, fl_value_unref);
  G_OBJECT_CLASS(
      pigeon_example_package_example_host_api_add_response_parent_class)
      ->dispose(object);
}

static void pigeon_example_package_example_host_api_add_response_init(
    PigeonExamplePackageExampleHostApiAddResponse* self) {}

static void pigeon_example_package_example_host_api_add_response_class_init(
    PigeonExamplePackageExampleHostApiAddResponseClass* klass) {
  G_OBJECT_CLASS(klass)->dispose =
      pigeon_example_package_example_host_api_add_response_dispose;
}

PigeonExamplePackageExampleHostApiAddResponse*
pigeon_example_package_example_host_api_add_response_new(int64_t return_value) {
  PigeonExamplePackageExampleHostApiAddResponse* self =
      PIGEON_EXAMPLE_PACKAGE_EXAMPLE_HOST_API_ADD_RESPONSE(g_object_new(
          pigeon_example_package_example_host_api_add_response_get_type(),
          nullptr));
  self->value = fl_value_new_list();
  fl_value_append_take(self->value, fl_value_new_int(return_value));
  return self;
}

PigeonExamplePackageExampleHostApiAddResponse*
pigeon_example_package_example_host_api_add_response_new_error(
    const gchar* code, const gchar* message, FlValue* details) {
  PigeonExamplePackageExampleHostApiAddResponse* self =
      PIGEON_EXAMPLE_PACKAGE_EXAMPLE_HOST_API_ADD_RESPONSE(g_object_new(
          pigeon_example_package_example_host_api_add_response_get_type(),
          nullptr));
  self->value = fl_value_new_list();
  fl_value_append_take(self->value, fl_value_new_string(code));
  fl_value_append_take(self->value, fl_value_new_string(message));
  fl_value_append(self->value, details);
  return self;
}

G_DECLARE_FINAL_TYPE(
    PigeonExamplePackageExampleHostApiSendMessageResponse,
    pigeon_example_package_example_host_api_send_message_response,
    PIGEON_EXAMPLE_PACKAGE, EXAMPLE_HOST_API_SEND_MESSAGE_RESPONSE, GObject)

struct _PigeonExamplePackageExampleHostApiSendMessageResponse {
  GObject parent_instance;

  FlValue* value;
};

G_DEFINE_TYPE(PigeonExamplePackageExampleHostApiSendMessageResponse,
              pigeon_example_package_example_host_api_send_message_response,
              G_TYPE_OBJECT)

static void
pigeon_example_package_example_host_api_send_message_response_dispose(
    GObject* object) {
  PigeonExamplePackageExampleHostApiSendMessageResponse* self =
      PIGEON_EXAMPLE_PACKAGE_EXAMPLE_HOST_API_SEND_MESSAGE_RESPONSE(object);
  g_clear_pointer(&self->value, fl_value_unref);
  G_OBJECT_CLASS(
      pigeon_example_package_example_host_api_send_message_response_parent_class)
      ->dispose(object);
}

static void pigeon_example_package_example_host_api_send_message_response_init(
    PigeonExamplePackageExampleHostApiSendMessageResponse* self) {}

static void
pigeon_example_package_example_host_api_send_message_response_class_init(
    PigeonExamplePackageExampleHostApiSendMessageResponseClass* klass) {
  G_OBJECT_CLASS(klass)->dispose =
      pigeon_example_package_example_host_api_send_message_response_dispose;
}

static PigeonExamplePackageExampleHostApiSendMessageResponse*
pigeon_example_package_example_host_api_send_message_response_new(
    gboolean return_value) {
  PigeonExamplePackageExampleHostApiSendMessageResponse* self =
      PIGEON_EXAMPLE_PACKAGE_EXAMPLE_HOST_API_SEND_MESSAGE_RESPONSE(g_object_new(
          pigeon_example_package_example_host_api_send_message_response_get_type(),
          nullptr));
  self->value = fl_value_new_list();
  fl_value_append_take(self->value, fl_value_new_bool(return_value));
  return self;
}

static PigeonExamplePackageExampleHostApiSendMessageResponse*
pigeon_example_package_example_host_api_send_message_response_new_error(
    const gchar* code, const gchar* message, FlValue* details) {
  PigeonExamplePackageExampleHostApiSendMessageResponse* self =
      PIGEON_EXAMPLE_PACKAGE_EXAMPLE_HOST_API_SEND_MESSAGE_RESPONSE(g_object_new(
          pigeon_example_package_example_host_api_send_message_response_get_type(),
          nullptr));
  self->value = fl_value_new_list();
  fl_value_append_take(self->value, fl_value_new_string(code));
  fl_value_append_take(self->value, fl_value_new_string(message));
  fl_value_append(self->value, details);
  return self;
}

struct _PigeonExamplePackageExampleHostApi {
  GObject parent_instance;

  FlBinaryMessenger* messenger;
  const PigeonExamplePackageExampleHostApiVTable* vtable;
  gpointer user_data;
  GDestroyNotify user_data_free_func;

  FlBasicMessageChannel* get_host_language_channel;
  FlBasicMessageChannel* add_channel;
  FlBasicMessageChannel* send_message_channel;
};

G_DEFINE_TYPE(PigeonExamplePackageExampleHostApi,
              pigeon_example_package_example_host_api, G_TYPE_OBJECT)

static void get_host_language_cb(
    FlBasicMessageChannel* channel, FlValue* message,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  PigeonExamplePackageExampleHostApi* self =
      PIGEON_EXAMPLE_PACKAGE_EXAMPLE_HOST_API(user_data);

  if (self->vtable == nullptr || self->vtable->get_host_language == nullptr) {
    return;
  }

  g_autoptr(PigeonExamplePackageExampleHostApiGetHostLanguageResponse)
      response = self->vtable->get_host_language(self, self->user_data);
  if (response == nullptr) {
    g_warning("No response returned to ExampleHostApi.getHostLanguage");
    return;
  }

  g_autoptr(GError) error = NULL;
  if (!fl_basic_message_channel_respond(channel, response_handle,
                                        response->value, &error)) {
    g_warning("Failed to send response to ExampleHostApi.getHostLanguage: %s",
              error->message);
  }
}

static void add_cb(FlBasicMessageChannel* channel, FlValue* message,
                   FlBasicMessageChannelResponseHandle* response_handle,
                   gpointer user_data) {
  PigeonExamplePackageExampleHostApi* self =
      PIGEON_EXAMPLE_PACKAGE_EXAMPLE_HOST_API(user_data);

  if (self->vtable == nullptr || self->vtable->add == nullptr) {
    return;
  }

  g_autoptr(PigeonExamplePackageExampleHostApiAddResponse) response =
      self->vtable->add(self,
                        fl_value_get_int(fl_value_get_list_value(message, 0)),
                        fl_value_get_int(fl_value_get_list_value(message, 1)),
                        self->user_data);
  if (response == nullptr) {
    g_warning("No response returned to ExampleHostApi.add");
    return;
  }

  g_autoptr(GError) error = NULL;
  if (!fl_basic_message_channel_respond(channel, response_handle,
                                        response->value, &error)) {
    g_warning("Failed to send response to ExampleHostApi.add: %s",
              error->message);
  }
}

static void send_message_cb(
    FlBasicMessageChannel* channel, FlValue* message,
    FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {
  PigeonExamplePackageExampleHostApi* self =
      PIGEON_EXAMPLE_PACKAGE_EXAMPLE_HOST_API(user_data);

  if (self->vtable == nullptr || self->vtable->send_message == nullptr) {
    return;
  }

  self->vtable->send_message(
      self,
      PIGEON_EXAMPLE_PACKAGE_MESSAGE_DATA(fl_value_get_custom_value_object(
          fl_value_get_list_value(message, 0))),
      response_handle, self->user_data);
}

static void pigeon_example_package_example_host_api_dispose(GObject* object) {
  PigeonExamplePackageExampleHostApi* self =
      PIGEON_EXAMPLE_PACKAGE_EXAMPLE_HOST_API(object);
  g_clear_object(&self->messenger);
  if (self->user_data != nullptr) {
    self->user_data_free_func(self->user_data);
  }
  self->user_data = nullptr;

  g_clear_object(&self->get_host_language_channel);
  g_clear_object(&self->add_channel);
  g_clear_object(&self->send_message_channel);
  G_OBJECT_CLASS(pigeon_example_package_example_host_api_parent_class)
      ->dispose(object);
}

static void pigeon_example_package_example_host_api_init(
    PigeonExamplePackageExampleHostApi* self) {}

static void pigeon_example_package_example_host_api_class_init(
    PigeonExamplePackageExampleHostApiClass* klass) {
  G_OBJECT_CLASS(klass)->dispose =
      pigeon_example_package_example_host_api_dispose;
}

PigeonExamplePackageExampleHostApi* pigeon_example_package_example_host_api_new(
    FlBinaryMessenger* messenger,
    const PigeonExamplePackageExampleHostApiVTable* vtable, gpointer user_data,
    GDestroyNotify user_data_free_func) {
  PigeonExamplePackageExampleHostApi* self =
      PIGEON_EXAMPLE_PACKAGE_EXAMPLE_HOST_API(g_object_new(
          pigeon_example_package_example_host_api_get_type(), nullptr));
  self->messenger = g_object_ref(messenger);
  self->vtable = vtable;
  self->user_data = user_data;
  self->user_data_free_func = user_data_free_func;

  g_autoptr(PigeonExamplePackageExampleHostApiCodec) codec =
      pigeon_example_package_example_host_api_codec_new();
  self->get_host_language_channel =
      fl_basic_message_channel_new(messenger,
                                   "dev.flutter.pigeon.pigeon_example_package."
                                   "ExampleHostApi.getHostLanguage",
                                   FL_MESSAGE_CODEC(codec));
  fl_basic_message_channel_set_message_handler(
      self->get_host_language_channel, get_host_language_cb, self, nullptr);
  self->add_channel = fl_basic_message_channel_new(
      messenger, "dev.flutter.pigeon.pigeon_example_package.ExampleHostApi.add",
      FL_MESSAGE_CODEC(codec));
  fl_basic_message_channel_set_message_handler(self->add_channel, add_cb, self,
                                               nullptr);
  self->send_message_channel = fl_basic_message_channel_new(
      messenger,
      "dev.flutter.pigeon.pigeon_example_package.ExampleHostApi.sendMessage",
      FL_MESSAGE_CODEC(codec));
  fl_basic_message_channel_set_message_handler(self->send_message_channel,
                                               send_message_cb, self, nullptr);

  return self;
}

void pigeon_example_package_example_host_api_respond_send_message(
    PigeonExamplePackageExampleHostApi* self,
    FlBasicMessageChannelResponseHandle* response_handle,
    gboolean return_value) {
  g_autoptr(PigeonExamplePackageExampleHostApiSendMessageResponse) response =
      pigeon_example_package_example_host_api_send_message_response_new(
          return_value);
  g_autoptr(GError) error = nullptr;
  if (!fl_basic_message_channel_respond(self->send_message_channel,
                                        response_handle, response->value,
                                        &error)) {
    g_warning("Failed to send response to ExampleHostApi.sendMessage: %s",
              error->message);
  }
}

void pigeon_example_package_example_host_api_respond_error_send_message(
    PigeonExamplePackageExampleHostApi* self,
    FlBasicMessageChannelResponseHandle* response_handle, const gchar* code,
    const gchar* message, FlValue* details) {
  g_autoptr(PigeonExamplePackageExampleHostApiSendMessageResponse) response =
      pigeon_example_package_example_host_api_send_message_response_new_error(
          code, message, details);
  g_autoptr(GError) error = nullptr;
  if (!fl_basic_message_channel_respond(self->send_message_channel,
                                        response_handle, response->value,
                                        &error)) {
    g_warning("Failed to send response to ExampleHostApi.sendMessage: %s",
              error->message);
  }
}

struct _PigeonExamplePackageMessageFlutterApi {
  GObject parent_instance;

  FlMethodChannel* channel;
};

G_DEFINE_TYPE(PigeonExamplePackageMessageFlutterApi,
              pigeon_example_package_message_flutter_api, G_TYPE_OBJECT)

static void pigeon_example_package_message_flutter_api_dispose(
    GObject* object) {
  PigeonExamplePackageMessageFlutterApi* self =
      PIGEON_EXAMPLE_PACKAGE_MESSAGE_FLUTTER_API(object);
  g_clear_object(&self->channel);
  G_OBJECT_CLASS(pigeon_example_package_message_flutter_api_parent_class)
      ->dispose(object);
}

static void pigeon_example_package_message_flutter_api_init(
    PigeonExamplePackageMessageFlutterApi* self) {}

static void pigeon_example_package_message_flutter_api_class_init(
    PigeonExamplePackageMessageFlutterApiClass* klass) {
  G_OBJECT_CLASS(klass)->dispose =
      pigeon_example_package_message_flutter_api_dispose;
}

PigeonExamplePackageMessageFlutterApi*
pigeon_example_package_message_flutter_api_new(FlBinaryMessenger* messenger) {
  PigeonExamplePackageMessageFlutterApi* self =
      PIGEON_EXAMPLE_PACKAGE_MESSAGE_FLUTTER_API(g_object_new(
          pigeon_example_package_message_flutter_api_get_type(), nullptr));
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  self->channel = fl_method_channel_new(messenger, "MessageFlutterApi",
                                        FL_METHOD_CODEC(codec));
  return self;
}

void pigeon_example_package_message_flutter_api_flutter_method(
    PigeonExamplePackageMessageFlutterApi* self, const gchar* a_string,
    GCancellable* cancellable, GAsyncReadyCallback callback,
    gpointer user_data) {
  g_autoptr(FlValue) args = fl_value_new_list();
  fl_value_append_take(args, fl_value_new_string(a_string));
  fl_method_channel_invoke_method(self->channel, "flutterMethod", args,
                                  cancellable, callback, user_data);
}

gboolean pigeon_example_package_message_flutter_api_flutter_method_finish(
    PigeonExamplePackageMessageFlutterApi* self, GAsyncResult* result,
    gchar** return_value, GError** error) {
  g_autoptr(FlMethodResponse) response =
      fl_method_channel_invoke_method_finish(self->channel, result, error);
  if (response == nullptr) {
    return FALSE;
  }

  g_autoptr(FlValue) r = fl_method_response_get_result(response, error);
  if (r == nullptr) {
    return FALSE;
  }

  *return_value = g_strdup(fl_value_get_string(r));

  return TRUE;
}
