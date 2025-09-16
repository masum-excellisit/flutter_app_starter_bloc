#!/bin/bash

# Usage: sh create_module.sh module_name
# Example: sh create_module.sh register

if [ -z "$1" ]; then
  echo "❌ Please provide a module name. Example: sh create_module.sh register"
  exit 1
fi

MODULE_NAME=$1
MODULE_DIR="lib/features/$MODULE_NAME"

echo "🚀 Creating module: $MODULE_NAME"

# Create folder structure
mkdir -p $MODULE_DIR/{api,bloc,data,model,screens,widgets}

# ---------------- API ----------------
cat <<EOF > $MODULE_DIR/api/${MODULE_NAME}_api.dart
import '../../../core/api_client.dart';
import '../../../core/api_response.dart';
import '../../../core/api_urls.dart';
import '../model/${MODULE_NAME}_request.dart';

class ${MODULE_NAME^}Api {
  final ApiClient _client;
  ${MODULE_NAME^}Api(this._client);

  Future<ApiResponse<Map<String, dynamic>>> ${MODULE_NAME}(${MODULE_NAME^}Request request) async {
    return _client.postRequest<Map<String, dynamic>>(
      endPoint: EndPoints.$MODULE_NAME, // make sure to add this in api_urls.dart
      reqModel: request.toJson(),
      fromJson: (json) => json,
    );
  }
}
EOF

# ---------------- MODEL ----------------
cat <<EOF > $MODULE_DIR/model/${MODULE_NAME}_request.dart
class ${MODULE_NAME^}Request {
  final String field;

  ${MODULE_NAME^}Request({required this.field});

  Map<String, dynamic> toJson() => {
        "field": field,
      };
}
EOF

# ---------------- REPOSITORY ----------------
cat <<EOF > $MODULE_DIR/data/${MODULE_NAME}_repository.dart
import '../../../core/api_response.dart';
import '../api/${MODULE_NAME}_api.dart';
import '../model/${MODULE_NAME}_request.dart';

class ${MODULE_NAME^}Repository {
  final ${MODULE_NAME^}Api _api;
  ${MODULE_NAME^}Repository(this._api);

  Future<ApiResponse<Map<String, dynamic>>> ${MODULE_NAME}(${MODULE_NAME^}Request request) {
    return _api.${MODULE_NAME}(request);
  }
}
EOF

# ---------------- BLOC ----------------
cat <<EOF > $MODULE_DIR/bloc/${MODULE_NAME}_event.dart
import '../model/${MODULE_NAME}_request.dart';

abstract class ${MODULE_NAME^}Event {}

class ${MODULE_NAME^}Submitted extends ${MODULE_NAME^}Event {
  final ${MODULE_NAME^}Request request;
  ${MODULE_NAME^}Submitted(this.request);
}
EOF

cat <<EOF > $MODULE_DIR/bloc/${MODULE_NAME}_state.dart
abstract class ${MODULE_NAME^}State {}

class ${MODULE_NAME^}Initial extends ${MODULE_NAME^}State {}

class ${MODULE_NAME^}Loading extends ${MODULE_NAME^}State {}

class ${MODULE_NAME^}Success extends ${MODULE_NAME^}State {
  final Map<String, dynamic> data;
  ${MODULE_NAME^}Success(this.data);
}

class ${MODULE_NAME^}Failure extends ${MODULE_NAME^}State {
  final String message;
  ${MODULE_NAME^}Failure(this.message);
}
EOF

cat <<EOF > $MODULE_DIR/bloc/${MODULE_NAME}_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api_response.dart';
import '../data/${MODULE_NAME}_repository.dart';
import '../model/${MODULE_NAME}_request.dart';
import 'package:equatable/equatable.dart';

import '${MODULE_NAME}_event.dart';
import '${MODULE_NAME}_state.dart';

class ${MODULE_NAME^}Bloc extends Bloc<${MODULE_NAME^}Event, ${MODULE_NAME^}State> {
  final ${MODULE_NAME^}Repository repository;

  ${MODULE_NAME^}Bloc(this.repository) : super(${MODULE_NAME^}Initial()) {
    on<${MODULE_NAME^}Submitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ${MODULE_NAME^}Submitted event,
    Emitter<${MODULE_NAME^}State> emit,
  ) async {
    emit(${MODULE_NAME^}Loading());
    final response = await repository.${MODULE_NAME}(event.request);

    if (response.data != null && response.statusCode == 200) {
      emit(${MODULE_NAME^}Success(response.data!));
    } else {
      emit(${MODULE_NAME^}Failure(response.errorMessage ?? "${MODULE_NAME^} failed"));
    }
  }
}
EOF

# ---------------- SCREEN ----------------
cat <<EOF > $MODULE_DIR/screens/${MODULE_NAME}_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/${MODULE_NAME}_bloc.dart';
import '../bloc/${MODULE_NAME}_event.dart';
import '../bloc/${MODULE_NAME}_state.dart';
import '../model/${MODULE_NAME}_request.dart';
import '../widgets/${MODULE_NAME}_form.dart';

class ${MODULE_NAME^}Screen extends StatelessWidget {
  const ${MODULE_NAME^}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("${MODULE_NAME^}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<${MODULE_NAME^}Bloc, ${MODULE_NAME^}State>(
          listener: (context, state) {
            if (state is ${MODULE_NAME^}Success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("${MODULE_NAME^} Successful")),
              );
              Navigator.pop(context);
            } else if (state is ${MODULE_NAME^}Failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is ${MODULE_NAME^}Loading;
            return ${MODULE_NAME^}Form(
              isLoading: isLoading,
              onSubmit: (field) {
                context.read<${MODULE_NAME^}Bloc>().add(
                      ${MODULE_NAME^}Submitted(
                        ${MODULE_NAME^}Request(field: field),
                      ),
                    );
              },
            );
          },
        ),
      ),
    );
  }
}
EOF

# ---------------- FORM ----------------
cat <<EOF > $MODULE_DIR/widgets/${MODULE_NAME}_form.dart
import 'package:flutter/material.dart';
import '../../../core/validators.dart';

class ${MODULE_NAME^}Form extends StatefulWidget {
  final void Function(String field) onSubmit;
  final bool isLoading;

  const ${MODULE_NAME^}Form({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<${MODULE_NAME^}Form> createState() => _${MODULE_NAME^}FormState();
}

class _${MODULE_NAME^}FormState extends State<${MODULE_NAME^}Form> {
  final _formKey = GlobalKey<FormState>();
  final _fieldCtrl = TextEditingController();

  @override
  void dispose() {
    _fieldCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(_fieldCtrl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _fieldCtrl,
            decoration: const InputDecoration(labelText: "Field"),
            validator: (value) => Validators.required(value, "Field"),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submit,
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Submit"),
            ),
          ),
        ],
      ),
    );
  }
}
EOF

# ---------------- MODULE ENTRY ----------------
cat <<EOF > $MODULE_DIR/${MODULE_NAME}_module.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/api_client.dart';
import 'api/${MODULE_NAME}_api.dart';
import 'data/${MODULE_NAME}_repository.dart';
import 'bloc/${MODULE_NAME}_bloc.dart';
import 'screens/${MODULE_NAME}_screen.dart';

class ${MODULE_NAME^}Module {
  static Widget route() {
    final apiClient = ApiClient();
    final api = ${MODULE_NAME^}Api(apiClient);
    final repo = ${MODULE_NAME^}Repository(api);

    return BlocProvider(
      create: (_) => ${MODULE_NAME^}Bloc(repo),
      child: ${MODULE_NAME^}Screen(),
    );
  }
}
EOF

echo "✅ Module '$MODULE_NAME' created successfully at $MODULE_DIR"
