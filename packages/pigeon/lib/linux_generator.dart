// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'ast.dart';
import 'generator.dart';
import 'generator_tools.dart';

/// General comment opening token.
const String _commentPrefix = '//';

/// Documentation comment spec.
const DocumentCommentSpecification _docCommentSpec =
    DocumentCommentSpecification(_commentPrefix);

/// Options that control how Linux code will be generated.
class LinuxOptions {
  /// Creates a [LinuxOptions] object
  const LinuxOptions({
    this.headerIncludePath,
    this.module,
    this.copyrightHeader,
    this.headerOutPath,
  });

  /// The path to the header that will get placed in the source filed (example:
  /// "foo.h").
  final String? headerIncludePath;

  /// The module where the generated class will live.
  final String? module;

  /// A copyright header that will get prepended to generated code.
  final Iterable<String>? copyrightHeader;

  /// The path to the output header file location.
  final String? headerOutPath;

  /// Creates a [LinuxOptions] from a Map representation where:
  /// `x = LinuxOptions.fromMap(x.toMap())`.
  static LinuxOptions fromMap(Map<String, Object> map) {
    return LinuxOptions(
      headerIncludePath: map['header'] as String?,
      module: map['module'] as String?,
      copyrightHeader: map['copyrightHeader'] as Iterable<String>?,
      headerOutPath: map['linuxHeaderOut'] as String?,
    );
  }

  /// Converts a [LinuxOptions] to a Map representation where:
  /// `x = LinuxOptions.fromMap(x.toMap())`.
  Map<String, Object> toMap() {
    final Map<String, Object> result = <String, Object>{
      if (headerIncludePath != null) 'header': headerIncludePath!,
      if (module != null) 'module': module!,
      if (copyrightHeader != null) 'copyrightHeader': copyrightHeader!,
    };
    return result;
  }

  /// Overrides any non-null parameters from [options] into this to make a new
  /// [LinuxOptions].
  LinuxOptions merge(LinuxOptions options) {
    return LinuxOptions.fromMap(mergeMaps(toMap(), options.toMap()));
  }
}

/// Class that manages all Linux code generation.
class LinuxGenerator extends Generator<OutputFileOptions<LinuxOptions>> {
  /// Constructor.
  const LinuxGenerator();

  /// Generates Linux file of type specified in [generatorOptions]
  @override
  void generate(
    OutputFileOptions<LinuxOptions> generatorOptions,
    Root root,
    StringSink sink, {
    required String dartPackageName,
  }) {
    assert(generatorOptions.fileType == FileType.header ||
        generatorOptions.fileType == FileType.source);
    if (generatorOptions.fileType == FileType.header) {
      const LinuxHeaderGenerator().generate(
        generatorOptions.languageOptions,
        root,
        sink,
        dartPackageName: dartPackageName,
      );
    } else if (generatorOptions.fileType == FileType.source) {
      const LinuxSourceGenerator().generate(
        generatorOptions.languageOptions,
        root,
        sink,
        dartPackageName: dartPackageName,
      );
    }
  }
}

/// Writes Linux header (.h) file to sink.
class LinuxHeaderGenerator extends StructuredGenerator<LinuxOptions> {
  /// Constructor.
  const LinuxHeaderGenerator();

  @override
  void writeFilePrologue(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('$_commentPrefix ${getGeneratedCodeWarning()}');
    indent.writeln('$_commentPrefix $seeAlsoWarning');
  }

  @override
  void writeFileImports(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.newln();
    final String guardName = _getGuardName(generatorOptions.headerIncludePath);
    indent.writeln('#ifndef $guardName');
    indent.writeln('#define $guardName');

    indent.newln();
    indent.writeln('#include <flutter_linux/flutter_linux.h>');
  }

  @override
  void writeOpenNamespace(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.newln();
    indent.writeln('G_BEGIN_DECLS');
  }

  @override
  void writeEnum(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Enum anEnum, {
    required String dartPackageName,
  }) {
    final String module = _getModule(generatorOptions, dartPackageName);
    final String enumName = _getClassName(module, anEnum.name);

    indent.newln();
    addDocumentationComments(
        indent, anEnum.documentationComments, _docCommentSpec);
    indent.writeScoped('typedef enum {', '} $enumName;', () {
      for (int i = 0; i < anEnum.members.length; i++) {
        final EnumMember member = anEnum.members[i];
        final String itemName =
            _getEnumValue(dartPackageName, anEnum.name, member.name);
        addDocumentationComments(
            indent, member.documentationComments, _docCommentSpec);
        indent.writeln(
            '$itemName = $i${i == anEnum.members.length - 1 ? '' : ','}');
      }
    });
  }

  @override
  void writeDataClass(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    final String module = _getModule(generatorOptions, dartPackageName);
    final String className = _getClassName(module, classDefinition.name);

    final String methodPrefix = _getMethodPrefix(module, classDefinition.name);

    indent.newln();
    addDocumentationComments(
        indent, classDefinition.documentationComments, _docCommentSpec);
    _writeDeclareFinalType(indent, module, classDefinition.name);

    indent.newln();
    final List<String> constructorArgs = <String>[];
    for (final NamedType field in classDefinition.fields) {
      final String fieldName = _snakeCaseFromCamelCase(field.name);
      final String type = _getType(module, field.type);
      constructorArgs.add('$type $fieldName');
    }
    indent.writeln(
        "$className* ${methodPrefix}_new(${constructorArgs.join(', ')});");

    for (final NamedType field in classDefinition.fields) {
      final String fieldName = _snakeCaseFromCamelCase(field.name);
      final String returnType = _getType(module, field.type);

      indent.newln();
      addDocumentationComments(
          indent, field.documentationComments, _docCommentSpec);
      indent.writeln(
          '$returnType ${methodPrefix}_get_$fieldName($className* self);');
    }
  }

  @override
  void writeFlutterApi(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
    final String module = _getModule(generatorOptions, dartPackageName);
    final String className = _getClassName(module, api.name);

    final String methodPrefix = _getMethodPrefix(module, api.name);

    indent.newln();
    addDocumentationComments(
        indent, api.documentationComments, _docCommentSpec);
    _writeDeclareFinalType(indent, module, api.name);

    indent.newln();
    indent.writeln(
        '$className* ${methodPrefix}_new(FlBinaryMessenger* messenger);');

    for (final Method method in api.methods) {
      final String methodName = _snakeCaseFromCamelCase(method.name);

      final List<String> asyncArgs = <String>[
        '$className* self',
        for (final Parameter param in method.parameters)
          '${_getType(module, param.type)} ${_snakeCaseFromCamelCase(param.name)}',
        'GCancellable* cancellable',
        'GAsyncReadyCallback callback',
        'gpointer user_data'
      ];
      indent.newln();
      addDocumentationComments(
          indent, method.documentationComments, _docCommentSpec);
      indent.writeln(
          "void ${methodPrefix}_$methodName(${asyncArgs.join(', ')});");

      final String returnType =
          _getType(module, method.returnType, isOutput: true);
      final List<String> finishArgs = <String>[
        '$className* self',
        'GAsyncResult* result',
        if (returnType != 'void') '$returnType* return_value',
        'GError** error'
      ];
      indent.newln();
      indent.writeln(
          "gboolean ${methodPrefix}_${methodName}_finish(${finishArgs.join(', ')});");
    }
  }

  @override
  void writeHostApi(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
    final String module = _getModule(generatorOptions, dartPackageName);
    final String className = _getClassName(module, api.name);
    final String methodPrefix = _getMethodPrefix(module, api.name);
    final String vtableName = _getVTableName(module, api.name);

    for (final Method method
        in api.methods.where((Method method) => !method.isAsynchronous)) {
      _writeApiRespondClass(indent, module, api, method);
    }

    indent.newln();
    _writeDeclareFinalType(indent, module, api.name);

    indent.newln();
    _writeApiVTable(indent, module, api);

    indent.newln();
    indent.writeln(
        '$className* ${methodPrefix}_new(FlBinaryMessenger* messenger, const $vtableName* vtable, gpointer user_data, GDestroyNotify user_data_free_func);');

    for (final Method method
        in api.methods.where((Method method) => method.isAsynchronous)) {
      _writeApiRespondFunctionPrototype(indent, module, api, method);
    }
  }

  // Write the API response classes.
  void _writeApiRespondClass(
      Indent indent, String module, Api api, Method method) {
    final String responseName = _getResponseName(api.name, method.name);
    final String responseClassName = _getClassName(module, responseName);
    final String responseMethodPrefix = _getMethodPrefix(module, responseName);

    indent.newln();
    _writeDeclareFinalType(indent, module, responseName);

    final String returnType = _getType(module, method.returnType);
    indent.newln();
    indent.writeln(
        '$responseClassName* ${responseMethodPrefix}_new($returnType return_value);');

    indent.newln();
    indent.writeln(
        '$responseClassName* ${responseMethodPrefix}_new_error(const gchar* code, const gchar* message, FlValue* details);');
  }

  // Write the vtable for an API.
  void _writeApiVTable(Indent indent, String module, Api api) {
    final String className = _getClassName(module, api.name);
    final String vtableName = _getVTableName(module, api.name);

    indent.writeScoped('typedef struct {', '} $vtableName;', () {
      for (final Method method in api.methods) {
        final String methodName = _snakeCaseFromCamelCase(method.name);
        final String responseName = _getResponseName(api.name, method.name);
        final String responseClassName = _getClassName(module, responseName);

        final List<String> methodArgs = <String>[
          '$className* self',
          for (final Parameter param in method.parameters)
            '${_getType(module, param.type)} ${_snakeCaseFromCamelCase(param.name)}',
          if (method.isAsynchronous)
            'FlBasicMessageChannelResponseHandle* response_handle',
          'gpointer user_data',
        ];
        final String returnType =
            method.isAsynchronous ? 'void' : '$responseClassName*';
        indent.writeln("$returnType (*$methodName)(${methodArgs.join(', ')});");
      }
    });
  }

  // Write the function prototype for an API method response.
  void _writeApiRespondFunctionPrototype(
      Indent indent, String module, Api api, Method method) {
    final String className = _getClassName(module, api.name);
    final String methodPrefix = _getMethodPrefix(module, api.name);
    final String methodName = _snakeCaseFromCamelCase(method.name);
    final String returnType = _getType(module, method.returnType);

    indent.newln();
    final List<String> respondArgs = <String>[
      '$className* self',
      'FlBasicMessageChannelResponseHandle* response_handle',
      '$returnType return_value'
    ];
    indent.writeln(
        "void ${methodPrefix}_respond_$methodName(${respondArgs.join(', ')});");

    indent.newln();
    final List<String> respondErrorArgs = <String>[
      '$className* self',
      'FlBasicMessageChannelResponseHandle* response_handle',
      'const gchar* code',
      'const gchar* message',
      'FlValue* details'
    ];
    indent.writeln(
        "void ${methodPrefix}_respond_error_$methodName(${respondErrorArgs.join(', ')});");
  }

  @override
  void writeCloseNamespace(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.newln();
    indent.writeln('G_END_DECLS');

    indent.newln();
    final String guardName = _getGuardName(generatorOptions.headerIncludePath);
    indent.writeln('#endif  // $guardName');
  }
}

/// Writes Linux source (.cc) file to sink.
class LinuxSourceGenerator extends StructuredGenerator<LinuxOptions> {
  /// Constructor.
  const LinuxSourceGenerator();

  @override
  void writeFilePrologue(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    if (generatorOptions.copyrightHeader != null) {
      addLines(indent, generatorOptions.copyrightHeader!, linePrefix: '// ');
    }
    indent.writeln('$_commentPrefix ${getGeneratedCodeWarning()}');
    indent.writeln('$_commentPrefix $seeAlsoWarning');
  }

  @override
  void writeFileImports(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent, {
    required String dartPackageName,
  }) {
    indent.newln();
    indent.writeln('#include "${generatorOptions.headerIncludePath}"');
  }

  @override
  void writeDataClass(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Class classDefinition, {
    required String dartPackageName,
  }) {
    final String module = _getModule(generatorOptions, dartPackageName);
    final String snakeModule = _snakeCaseFromCamelCase(module);
    final String className = _getClassName(module, classDefinition.name);
    final String snakeClassName = _snakeCaseFromCamelCase(classDefinition.name);

    final String methodPrefix = _getMethodPrefix(module, classDefinition.name);
    final String testMacro = '${snakeModule}_IS_$snakeClassName'.toUpperCase();

    indent.newln();
    _writeObjectStruct(indent, module, classDefinition.name, () {
      indent.newln();
      for (final NamedType field in classDefinition.fields) {
        final String fieldName = _snakeCaseFromCamelCase(field.name);
        final String fieldType = _getType(module, field.type, isOutput: true);
        indent.writeln('$fieldType $fieldName;');
      }
    });

    indent.newln();
    _writeDefineType(indent, module, classDefinition.name);

    indent.newln();
    _writeDispose(indent, module, classDefinition.name, () {
      bool haveSelf = false;
      for (final NamedType field in classDefinition.fields) {
        final String fieldName = _snakeCaseFromCamelCase(field.name);
        final String? clear = _getClearFunction(field.type, 'self->$fieldName');
        if (clear != null) {
          if (!haveSelf) {
            _writeCastSelf(indent, module, classDefinition.name, 'object');
            haveSelf = true;
          }
          indent.writeln('$clear;');
        }
      }
    });

    indent.newln();
    _writeInit(indent, module, classDefinition.name, () {});

    indent.newln();
    _writeClassInit(indent, module, classDefinition.name, () {});

    final List<String> constructorArgs = <String>[
      for (final NamedType field in classDefinition.fields)
        '${_getType(module, field.type)} ${_snakeCaseFromCamelCase(field.name)}',
    ];
    indent.newln();
    indent.writeScoped(
        "$className* ${methodPrefix}_new(${constructorArgs.join(', ')}) {", '}',
        () {
      _writeObjectNew(indent, module, classDefinition.name);
      for (final NamedType field in classDefinition.fields) {
        final String fieldName = _snakeCaseFromCamelCase(field.name);
        final String value = _referenceValue(field.type, fieldName);

        indent.writeln('self->$fieldName = $value;');
      }
      indent.writeln('return self;');
    });

    for (final NamedType field in classDefinition.fields) {
      final String fieldName = _snakeCaseFromCamelCase(field.name);
      final String returnType = _getType(module, field.type);

      indent.newln();
      indent.writeScoped(
          '$returnType ${methodPrefix}_get_$fieldName($className* self) {', '}',
          () {
        indent.writeln(
            'g_return_val_if_fail($testMacro(self), ${_getDefaultValue(module, field.type)});');
        indent.writeln('return self->$fieldName;');
      });
    }

    indent.newln();
    indent.writeScoped(
        'static FlValue* ${methodPrefix}_to_list($className* self) {', '}', () {
      indent.writeln('FlValue* values = fl_value_new_list();');
      for (final NamedType field in classDefinition.fields) {
        final String fieldName = _snakeCaseFromCamelCase(field.name);
        indent.writeln(
            'fl_value_append_take(values, ${_makeFlValue(module, field.type, 'self->$fieldName')});');
      }
      indent.writeln('return values;');
    });

    indent.newln();
    indent.writeScoped(
        'static $className* ${methodPrefix}_new_from_list(FlValue* values) {',
        '}', () {
      final List<String> args = <String>[];
      for (int i = 0; i < classDefinition.fields.length; i++) {
        final NamedType field = classDefinition.fields[i];
        args.add(_fromFlValue(
            module, field.type, 'fl_value_get_list_value(values, $i)'));
      }
      indent.writeln('return ${methodPrefix}_new(${args.join(', ')});');
    });
  }

  @override
  void writeFlutterApi(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
    final String module = _getModule(generatorOptions, dartPackageName);
    final String className = _getClassName(module, api.name);

    final String methodPrefix = _getMethodPrefix(module, api.name);

    indent.newln();
    _writeObjectStruct(indent, module, api.name, () {
      indent.writeln('FlMethodChannel* channel;');
    });

    indent.newln();
    _writeDefineType(indent, module, api.name);

    indent.newln();
    _writeDispose(indent, module, api.name, () {
      _writeCastSelf(indent, module, api.name, 'object');
      indent.writeln('g_clear_object(&self->channel);');
    });

    indent.newln();
    _writeInit(indent, module, api.name, () {});

    indent.newln();
    _writeClassInit(indent, module, api.name, () {});

    indent.newln();
    indent.writeScoped(
        '$className* ${methodPrefix}_new(FlBinaryMessenger* messenger) {', '}',
        () {
      _writeObjectNew(indent, module, api.name);
      indent.writeln(
          'self->channel = fl_method_channel_new(messenger, "${api.name}", codec);');
      indent.writeln('return self;');
    });

    for (final Method method in api.methods) {
      final String methodName = _snakeCaseFromCamelCase(method.name);

      final List<String> asyncArgs = <String>[
        '$className* self',
        for (final Parameter param in method.parameters)
          '${_getType(module, param.type)} ${_snakeCaseFromCamelCase(param.name)}',
        'GCancellable* cancellable',
        'GAsyncReadyCallback callback',
        'gpointer user_data',
      ];
      indent.newln();
      indent.writeScoped(
          "void ${methodPrefix}_$methodName(${asyncArgs.join(', ')}) {", '}',
          () {
        final List<String> valueArgs = <String>[
          for (final Parameter param in method.parameters)
            _makeFlValue(
                module, param.type, _snakeCaseFromCamelCase(param.name)),
          'nullptr'
        ];
        indent.writeln(
            'g_autoptr(FlValue) args = fl_value_new_array_take(${valueArgs.join(', ')});');
        indent.writeln(
            'fl_method_channel_invoke_method(self->channel, "${method.name}", args, cancellable, callback, user_data);');
      });

      final String returnType =
          _getType(module, method.returnType, isOutput: true);
      final List<String> finishArgs = <String>[
        '$className* self',
        'GAsyncResult* result',
        if (returnType != 'void') '$returnType* return_value',
        'GError** error',
      ];
      indent.newln();
      indent.writeScoped(
          "gboolean ${methodPrefix}_${methodName}_finish(${finishArgs.join(', ')}) {",
          '}', () {
        indent.writeln(
            'g_autoptr(FlMethodResponse) response = fl_method_channel_invoke_method_finish(self->channel, result, error);');
        indent.writeScoped('if (response == nullptr) {', '}', () {
          indent.writeln('return FALSE;');
        });

        indent.newln();
        indent.writeln(
            'g_autoptr(FlValue) r = fl_method_response_get_result(response, error);');
        indent.writeScoped('if (r == nullptr) {', '}', () {
          indent.writeln('return FALSE;');
        });

        if (returnType != 'void') {
          indent.newln();
          final String returnValue =
              _fromFlValue(module, method.returnType, 'r');
          indent.writeln(
              '*return_value = ${_referenceValue(method.returnType, returnValue)};');
        }

        indent.newln();
        indent.writeln('return TRUE;');
      });
    }
  }

  @override
  void writeHostApi(
    LinuxOptions generatorOptions,
    Root root,
    Indent indent,
    Api api, {
    required String dartPackageName,
  }) {
    final String module = _getModule(generatorOptions, dartPackageName);
    final String className = _getClassName(module, api.name);

    final String methodPrefix = _getMethodPrefix(module, api.name);
    final String vtableName = _getVTableName(module, api.name);

    final String codecName = '${api.name}Codec';
    final String codecClassName = _getClassName(module, codecName);
    final String codecMethodPrefix = '${methodPrefix}_codec';

    indent.newln();
    _writeDeclareFinalType(indent, module, codecName,
        parentClassName: 'FlStandardMessageCodec');

    indent.newln();
    _writeObjectStruct(indent, module, codecName, () {},
        parentClassName: 'FlStandardMessageCodec');

    indent.newln();
    _writeDefineType(indent, module, codecName,
        parentType: 'fl_standard_message_codec_get_type()');

    for (final EnumeratedClass customClass in getCodecClasses(api, root)) {
      final String customClassName = _getClassName(module, customClass.name);
      final String snakeCustomClassName =
          _snakeCaseFromCamelCase(customClassName);
      indent.newln();
      indent.writeScoped(
          'static gboolean write_$snakeCustomClassName(FlStandardMessageCodec* codec, GByteArray* buffer, $customClassName* value, GError** error) {',
          '}', () {
        indent.writeln('uint8_t type = ${customClass.enumeration};');
        indent.writeln('g_byte_array_append(buffer, &type, sizeof(uint8_t));');
        indent.writeln(
            'g_autoptr(FlValue) values = ${snakeCustomClassName}_to_list(value);');
        indent.writeln(
            'return fl_standard_message_codec_write_value(codec, buffer, values, error);');
      });
    }

    indent.newln();
    indent.writeScoped(
        'static gboolean ${methodPrefix}_write_value(FlStandardMessageCodec* codec, GByteArray* buffer, FlValue* value, GError** error) {',
        '}', () {
      indent.writeScoped(
          'if (fl_value_get_type(value) == FL_VALUE_TYPE_CUSTOM) {', '}', () {
        indent.writeScoped('switch (fl_value_get_custom_type(value)) {', '}',
            () {
          for (final EnumeratedClass customClass
              in getCodecClasses(api, root)) {
            indent.writeln('case ${customClass.enumeration}:');
            indent.nest(1, () {
              final String customClassName =
                  _getClassName(module, customClass.name);
              final String snakeCustomClassName =
                  _snakeCaseFromCamelCase(customClassName);
              final String castMacro =
                  _getClassCastMacro(module, customClass.name);
              indent.writeln(
                  'return write_$snakeCustomClassName(codec, buffer, $castMacro(fl_value_get_custom_value_object(value)), error);');
            });
          }
        });
      });

      indent.newln();
      indent.writeln(
          'return FL_STANDARD_MESSAGE_CODEC_CLASS(${codecMethodPrefix}_parent_class)->write_value(codec, buffer, value, error);');
    });

    for (final EnumeratedClass customClass in getCodecClasses(api, root)) {
      final String customClassName = _getClassName(module, customClass.name);
      final String snakeCustomClassName =
          _snakeCaseFromCamelCase(customClassName);
      indent.newln();
      indent.writeScoped(
          'static FlValue* read_$snakeCustomClassName(FlStandardMessageCodec* codec, GBytes* buffer, size_t* offset, GError** error) {',
          '}', () {
        indent.writeln(
            'g_autoptr(FlValue) values = fl_standard_message_codec_read_value(codec, buffer, offset, error);');
        indent.writeScoped('if (values == nullptr) {', '}', () {
          indent.writeln('return nullptr;');
        });
        indent.newln();
        indent.writeln(
            'g_autoptr($customClassName) value = ${snakeCustomClassName}_new_from_list(values);');
        indent.writeScoped('if (value == nullptr) {', '}', () {
          indent.writeln(
              'g_set_error(error, FL_MESSAGE_CODEC_ERROR, FL_MESSAGE_CODEC_ERROR_FAILED, "Invalid data received for MessageData");');
          indent.writeln('return nullptr;');
        });
        indent.newln();
        indent.writeln(
            'return fl_value_new_custom_object_take(${customClass.enumeration}, G_OBJECT(value));');
      });
    }

    indent.newln();
    indent.writeScoped(
        'static FlValue* ${methodPrefix}_read_value_of_type(FlStandardMessageCodec* codec, GBytes* buffer, size_t* offset, int type, GError** error) {',
        '}', () {
      indent.writeScoped('switch (type) {', '}', () {
        for (final EnumeratedClass customClass in getCodecClasses(api, root)) {
          final String customClassName =
              _getClassName(module, customClass.name);
          final String snakeCustomClassName =
              _snakeCaseFromCamelCase(customClassName);
          indent.writeln('case ${customClass.enumeration}:');
          indent.nest(1, () {
            indent.writeln(
                'return read_$snakeCustomClassName(codec, buffer, offset, error);');
          });
        }

        indent.writeln('default:');
        indent.nest(1, () {
          indent.writeln(
              'return FL_STANDARD_MESSAGE_CODEC_CLASS(${codecMethodPrefix}_parent_class)->read_value_of_type(codec, buffer, offset, type, error);');
        });
      });
    });

    indent.newln();
    _writeInit(indent, module, codecName, () {});

    indent.newln();
    _writeClassInit(indent, module, codecName, () {
      indent.writeln(
          'FL_STANDARD_MESSAGE_CODEC_CLASS(klass)->write_value = ${methodPrefix}_write_value;');
      indent.writeln(
          'FL_STANDARD_MESSAGE_CODEC_CLASS(klass)->read_value_of_type = ${methodPrefix}_read_value_of_type;');
    }, hasDispose: false);

    indent.newln();
    indent.writeScoped(
        'static $codecClassName* ${codecMethodPrefix}_new() {', '}', () {
      _writeObjectNew(indent, module, codecName);
      indent.writeln('return self;');
    });

    for (final Method method in api.methods) {
      final String responseName = _getResponseName(api.name, method.name);
      final String responseClassName = _getClassName(module, responseName);
      final String responseMethodPrefix =
          _getMethodPrefix(module, responseName);

      if (method.isAsynchronous) {
        indent.newln();
        _writeDeclareFinalType(indent, module, responseName);
      }

      indent.newln();
      _writeObjectStruct(indent, module, responseName, () {
        indent.writeln('FlValue* value;');
      });

      indent.newln();
      _writeDefineType(indent, module, responseName);

      indent.newln();
      _writeDispose(indent, module, responseName, () {
        _writeCastSelf(indent, module, responseName, 'object');
        indent.writeln('g_clear_pointer(&self->value, fl_value_unref);');
      });

      indent.newln();
      _writeInit(indent, module, responseName, () {});

      indent.newln();
      _writeClassInit(indent, module, responseName, () {});

      final String returnType = _getType(module, method.returnType);
      indent.newln();
      indent.writeScoped(
          "${method.isAsynchronous ? 'static ' : ''}$responseClassName* ${responseMethodPrefix}_new($returnType return_value) {",
          '}', () {
        _writeObjectNew(indent, module, responseName);
        indent.writeln('self->value = fl_value_new_list();');
        indent.writeln(
            "fl_value_append_take(self->value, ${_makeFlValue(module, method.returnType, 'return_value')});");
        indent.writeln('return self;');
      });

      indent.newln();
      indent.writeScoped(
          '${method.isAsynchronous ? 'static ' : ''}$responseClassName* ${responseMethodPrefix}_new_error(const gchar* code, const gchar* message, FlValue* details) {',
          '}', () {
        _writeObjectNew(indent, module, responseName);
        indent.writeln('self->value = fl_value_new_list();');
        indent.writeln(
            'fl_value_append_take(self->value, fl_value_new_string(code));');
        indent.writeln(
            'fl_value_append_take(self->value, fl_value_new_string(message));');
        indent.writeln('fl_value_append(self->value, details);');
        indent.writeln('return self;');
      });
    }

    indent.newln();
    _writeObjectStruct(indent, module, api.name, () {
      indent.writeln('FlBinaryMessenger* messenger;');
      indent.writeln('const ${className}VTable* vtable;');
      indent.writeln('gpointer user_data;');
      indent.writeln('GDestroyNotify user_data_free_func;');

      indent.newln();
      for (final Method method in api.methods) {
        final String methodName = _snakeCaseFromCamelCase(method.name);
        indent.writeln('FlBasicMessageChannel* ${methodName}_channel;');
      }
    });

    indent.newln();
    _writeDefineType(indent, module, api.name);

    for (final Method method in api.methods) {
      final String methodName = _snakeCaseFromCamelCase(method.name);
      final String responseName = _getResponseName(api.name, method.name);
      final String responseClassName = _getClassName(module, responseName);

      indent.newln();
      indent.writeScoped(
          'static void ${methodName}_cb(FlBasicMessageChannel* channel, FlValue* message, FlBasicMessageChannelResponseHandle* response_handle, gpointer user_data) {',
          '}', () {
        _writeCastSelf(indent, module, api.name, 'user_data');

        indent.newln();
        indent.writeScoped(
            'if (self->vtable == nullptr || self->vtable->$methodName == nullptr) {',
            '}', () {
          indent.writeln('return;');
        });

        final List<String> methodArgs = <String>[
          for (int i = 0; i < method.parameters.length; i++)
            _fromFlValue(module, method.parameters[i].type,
                'fl_value_get_list_value(message, $i)'),
        ];

        indent.newln();
        if (method.isAsynchronous) {
          final List<String> vfuncArgs = <String>['self'];
          vfuncArgs.addAll(methodArgs);
          vfuncArgs.addAll(<String>['response_handle', 'self->user_data']);
          indent.writeln("self->vtable->$methodName(${vfuncArgs.join(', ')});");
        } else {
          final List<String> vfuncArgs = <String>['self'];
          vfuncArgs.addAll(methodArgs);
          vfuncArgs.add('self->user_data');
          indent.writeln(
              "g_autoptr($responseClassName) response = self->vtable->$methodName(${vfuncArgs.join(', ')});");
          indent.writeScoped('if (response == nullptr) {', '}', () {
            indent.writeln(
                'g_warning("No response returned to ${api.name}.${method.name}");');
            indent.writeln('return;');
          });

          indent.newln();
          indent.writeln('g_autoptr(GError) error = NULL;');
          indent.writeScoped(
              'if (!fl_basic_message_channel_respond(channel, response_handle, response->value, &error)) {',
              '}', () {
            indent.writeln(
                'g_warning("Failed to send response to ${api.name}.${method.name}: %s", error->message);');
          });
        }
      });
    }

    indent.newln();
    _writeDispose(indent, module, api.name, () {
      _writeCastSelf(indent, module, api.name, 'object');
      indent.writeln('g_clear_object(&self->messenger);');
      indent.writeScoped('if (self->user_data != nullptr) {', '}', () {
        indent.writeln('self->user_data_free_func(self->user_data);');
      });
      indent.writeln('self->user_data = nullptr;');

      indent.newln();
      for (final Method method in api.methods) {
        final String methodName = _snakeCaseFromCamelCase(method.name);
        indent.writeln('g_clear_object(&self->${methodName}_channel);');
      }
    });

    indent.newln();
    _writeInit(indent, module, api.name, () {});

    indent.newln();
    _writeClassInit(indent, module, api.name, () {});

    indent.newln();
    indent.writeScoped(
        '$className* ${methodPrefix}_new(FlBinaryMessenger* messenger, const $vtableName* vtable, gpointer user_data, GDestroyNotify user_data_free_func) {',
        '}', () {
      _writeObjectNew(indent, module, api.name);
      indent.writeln('self->messenger = g_object_ref(messenger);');
      indent.writeln('self->vtable = vtable;');
      indent.writeln('self->user_data = user_data;');
      indent.writeln('self->user_data_free_func = user_data_free_func;');

      indent.newln();
      indent.writeln(
          'g_autoptr($codecClassName) codec = ${codecMethodPrefix}_new();');
      for (final Method method in api.methods) {
        final String methodName = _snakeCaseFromCamelCase(method.name);
        final String channelName =
            makeChannelName(api, method, dartPackageName);
        indent.writeln(
            'self->${methodName}_channel = fl_basic_message_channel_new(messenger, "$channelName", FL_MESSAGE_CODEC(codec));');
        indent.writeln(
            'fl_basic_message_channel_set_message_handler(self->${methodName}_channel, ${methodName}_cb, self, nullptr);');
      }

      indent.newln();
      indent.writeln('return self;');
    });

    for (final Method method
        in api.methods.where((Method method) => method.isAsynchronous)) {
      final String returnType = _getType(module, method.returnType);
      final String methodName = _snakeCaseFromCamelCase(method.name);
      final String responseName = _getResponseName(api.name, method.name);
      final String responseClassName = _getClassName(module, responseName);
      final String responseMethodPrefix =
          _getMethodPrefix(module, responseName);

      indent.newln();
      final List<String> respondArgs = <String>[
        '$className* self',
        'FlBasicMessageChannelResponseHandle* response_handle',
        '$returnType return_value'
      ];
      indent.writeScoped(
          "void ${methodPrefix}_respond_$methodName(${respondArgs.join(', ')}) {",
          '}', () {
        indent.writeln(
            'g_autoptr($responseClassName) response = ${responseMethodPrefix}_new(return_value);');
        indent.writeln('g_autoptr(GError) error = nullptr;');
        indent.writeScoped(
            'if (!fl_basic_message_channel_respond(self->${methodName}_channel, response_handle, response->value, &error)) {',
            '}', () {
          indent.writeln(
              'g_warning("Failed to send response to ${api.name}.${method.name}: %s", error->message);');
        });
      });

      indent.newln();
      final List<String> respondErrorArgs = <String>[
        '$className* self',
        'FlBasicMessageChannelResponseHandle* response_handle',
        'const gchar* code',
        'const gchar* message',
        'FlValue* details'
      ];
      indent.writeScoped(
          "void ${methodPrefix}_respond_error_$methodName(${respondErrorArgs.join(', ')}) {",
          '}', () {
        indent.writeln(
            'g_autoptr($responseClassName) response = ${responseMethodPrefix}_new_error(code, message, details);');
        indent.writeln('g_autoptr(GError) error = nullptr;');
        indent.writeScoped(
            'if (!fl_basic_message_channel_respond(self->${methodName}_channel, response_handle, response->value, &error)) {',
            '}', () {
          indent.writeln(
              'g_warning("Failed to send response to ${api.name}.${method.name}: %s", error->message);');
        });
      });
    }
  }
}

// Returns the module name to use.
String _getModule(LinuxOptions generatorOptions, String dartPackageName) {
  return generatorOptions.module ?? _camelCaseFromSnakeCase(dartPackageName);
}

// Returns the header guard defintion for [headerFileName].
String _getGuardName(String? headerFileName) {
  const String prefix = 'PIGEON_';
  if (headerFileName != null) {
    return '$prefix${headerFileName.replaceAll('.', '_').toUpperCase()}_';
  } else {
    return '${prefix}H_';
  }
}

// Writes the GObject macro to generate a new type.
void _writeDeclareFinalType(Indent indent, String module, String name,
    {String parentClassName = 'GObject'}) {
  final String upperModule = _snakeCaseFromCamelCase(module).toUpperCase();
  final String className = _getClassName(module, name);
  final String snakeClassName = _snakeCaseFromCamelCase(name);
  final String upperSnakeClassName = snakeClassName.toUpperCase();
  final String methodPrefix = _getMethodPrefix(module, name);

  indent.writeln(
      'G_DECLARE_FINAL_TYPE($className, $methodPrefix, $upperModule, $upperSnakeClassName, $parentClassName)');
}

// Writes the GObject macro to define a new type.
void _writeDefineType(Indent indent, String module, String name,
    {String parentType = 'G_TYPE_OBJECT'}) {
  final String className = _getClassName(module, name);
  final String methodPrefix = _getMethodPrefix(module, name);

  indent.writeln('G_DEFINE_TYPE($className, $methodPrefix, $parentType)');
}

// Writes the struct for a GObject.
void _writeObjectStruct(
    Indent indent, String module, String name, void Function() func,
    {String parentClassName = 'GObject'}) {
  final String className = _getClassName(module, name);

  indent.writeScoped('struct _$className {', '};', () {
    indent.writeln('$parentClassName parent_instance;');
    indent.newln();

    func();
  });
}

// Writes the dispose method for a GObject.
void _writeDispose(
    Indent indent, String module, String name, void Function() func) {
  final String methodPrefix = _getMethodPrefix(module, name);

  indent.writeScoped(
      'static void ${methodPrefix}_dispose(GObject* object) {', '}', () {
    func();
    indent.writeln(
        'G_OBJECT_CLASS(${methodPrefix}_parent_class)->dispose(object);');
  });
}

// Writes the init function for a GObject.
void _writeInit(
    Indent indent, String module, String name, void Function() func) {
  final String className = _getClassName(module, name);
  final String methodPrefix = _getMethodPrefix(module, name);

  indent.writeScoped(
      'static void ${methodPrefix}_init($className* self) {', '}', () {
    func();
  });
}

// Writes the class init function for a GObject.
void _writeClassInit(
    Indent indent, String module, String name, void Function() func,
    {bool hasDispose = true}) {
  final String className = _getClassName(module, name);
  final String methodPrefix = _getMethodPrefix(module, name);

  indent.writeScoped(
      'static void ${methodPrefix}_class_init(${className}Class* klass) {', '}',
      () {
    if (hasDispose) {
      indent
          .writeln('G_OBJECT_CLASS(klass)->dispose = ${methodPrefix}_dispose;');
    }
    func();
  });
}

// Writes the constructor for a GObject.
void _writeObjectNew(Indent indent, String module, String name) {
  final String className = _getClassName(module, name);
  final String methodPrefix = _getMethodPrefix(module, name);
  final String castMacro = _getClassCastMacro(module, name);

  indent.writeln(
      '$className* self = $castMacro(g_object_new(${methodPrefix}_get_type(), nullptr));');
}

// Writes the cast used at the top of GObject methods.
void _writeCastSelf(
    Indent indent, String module, String name, String variableName) {
  final String className = _getClassName(module, name);
  final String castMacro = _getClassCastMacro(module, name);
  indent.writeln('$className* self = $castMacro($variableName);');
}

// Converts a string from CamelCase to snake_case.
String _snakeCaseFromCamelCase(String camelCase) {
  return camelCase.replaceAllMapped(RegExp(r'[A-Z]'),
      (Match m) => '${m.start == 0 ? '' : '_'}${m[0]!.toLowerCase()}');
}

// Converts a string from snake_case to CamelCase
String _camelCaseFromSnakeCase(String snakeCase) {
  return snakeCase
      .split('_')
      .map((String v) => v[0].toUpperCase() + v.substring(1))
      .join();
}

// Returns the GObject class name for [name].
String _getClassName(String module, String name) {
  return '$module$name';
}

/// Return the name of the VTable structure to use for API requests.
String _getVTableName(String module, String name) {
  final String className = _getClassName(module, name);
  return '${className}VTable';
}

// Returns the GObject macro to cast a GObject to a class of [name].
String _getClassCastMacro(String module, String name) {
  final String className = _getClassName(module, name);
  final String snakeClassName = _snakeCaseFromCamelCase(className);
  return snakeClassName.toUpperCase();
}

// Returns the prefix used for methods in class [name].
String _getMethodPrefix(String module, String name) {
  final String className = _getClassName(module, name);
  return _snakeCaseFromCamelCase(className);
}

// Returns an enumeration value in C++ form.
String _getEnumValue(String module, String enumName, String memberName) {
  final String snakeEnumName = _snakeCaseFromCamelCase(enumName);
  final String snakeMemberName = _snakeCaseFromCamelCase(memberName);
  return '${module}_${snakeEnumName}_$snakeMemberName'.toUpperCase();
}

// Returns code for storing a value of [type].
String _getType(String module, TypeDeclaration type, {bool isOutput = false}) {
  if (type.isClass) {
    return '${_getClassName(module, type.baseName)}*';
  } else if (type.isEnum) {
    return _getClassName(module, type.baseName);
  } else if (type.baseName == 'List' || type.baseName == 'Map') {
    return 'FlValue*';
  } else if (type.baseName == 'void') {
    return 'void';
  } else if (type.baseName == 'bool') {
    return 'gboolean';
  } else if (type.baseName == 'int') {
    return 'int64_t';
  } else if (type.baseName == 'double') {
    return 'double';
  } else if (type.baseName == 'String') {
    return isOutput ? 'gchar*' : 'const gchar*';
  } else {
    throw Exception('Unknown type ${type.baseName}');
  }
}

// Returns code to clear a value stored in [variableName], or null if no function required.
String? _getClearFunction(TypeDeclaration type, String variableName) {
  if (type.isClass) {
    return 'g_clear_object(&$variableName)';
  } else if (type.baseName == 'List' || type.baseName == 'Map') {
    return 'g_clear_pointer(&$variableName, fl_value_unref)';
  } else if (type.baseName == 'String') {
    return 'g_clear_pointer(&$variableName, g_free)';
  } else {
    return null;
  }
}

// Returns code for the default value for [type].
String _getDefaultValue(String module, TypeDeclaration type) {
  if (type.isClass) {
    return 'nullptr';
  } else if (type.isEnum) {
    final String enumName = _getClassName(module, type.baseName);
    return 'static_cast<$enumName>(0)';
  } else if (type.baseName == 'List' || type.baseName == 'Map') {
    return 'nullptr';
  } else if (type.baseName == 'void') {
    return '';
  } else if (type.baseName == 'bool') {
    return 'FALSE';
  } else if (type.baseName == 'int') {
    return '0';
  } else if (type.baseName == 'double') {
    return '0.0';
  } else if (type.baseName == 'String') {
    return 'nullptr';
  } else {
    throw Exception('Unknown type ${type.baseName}');
  }
}

// Returns code to copy the native data type stored in [variableName].
String _referenceValue(TypeDeclaration type, String variableName) {
  if (type.isClass || type.baseName == 'List' || type.baseName == 'Map') {
    return 'g_object_ref($variableName)';
  } else if (type.baseName == 'String') {
    return 'g_strdup($variableName)';
  } else {
    return variableName;
  }
}

// Returns code to convert the native data type stored in [variableName] to a FlValue.
String _makeFlValue(String module, TypeDeclaration type, String variableName) {
  if (type.isClass) {
    return 'fl_value_new_custom_object(0, G_OBJECT($variableName))';
  } else if (type.isEnum) {
    return 'fl_value_new_int($variableName)';
  } else if (type.baseName == 'List' || type.baseName == 'Map') {
    return 'fl_value_ref($variableName)';
  } else if (type.baseName == 'void') {
    return 'fl_value_new_null()';
  } else if (type.baseName == 'bool') {
    return 'fl_value_new_bool($variableName)';
  } else if (type.baseName == 'int') {
    return 'fl_value_new_int($variableName)';
  } else if (type.baseName == 'double') {
    return 'fl_value_new_double($variableName)';
  } else if (type.baseName == 'String') {
    return 'fl_value_new_string($variableName)';
  } else {
    throw Exception('Unknown type ${type.baseName}');
  }
}

// Returns code to convert the FlValue stored in [variableName] to a native data type.
String _fromFlValue(String module, TypeDeclaration type, String variableName) {
  if (type.isClass) {
    final String castMacro = _getClassCastMacro(module, type.baseName);
    return '$castMacro(fl_value_get_custom_value_object($variableName))';
  } else if (type.isEnum) {
    final String enumName = _getClassName(module, type.baseName);
    return 'static_cast<$enumName>(fl_value_get_int($variableName))';
  } else if (type.baseName == 'List' || type.baseName == 'Map') {
    return variableName;
  } else if (type.baseName == 'bool') {
    return 'fl_value_get_bool($variableName)';
  } else if (type.baseName == 'int') {
    return 'fl_value_get_int($variableName)';
  } else if (type.baseName == 'double') {
    return 'fl_value_get_double($variableName)';
  } else if (type.baseName == 'String') {
    return 'fl_value_get_string($variableName)';
  } else {
    throw Exception('Unknown type ${type.baseName}');
  }
}

// Returns the name of a GObject class used to send responses to [methodName].
String _getResponseName(String name, String methodName) {
  final String upperMethodName =
      methodName[0].toUpperCase() + methodName.substring(1);
  return '$name${upperMethodName}Response';
}
