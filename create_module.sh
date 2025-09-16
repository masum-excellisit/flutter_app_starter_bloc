#!/bin/bash

# Usage: sh create_module.sh module_name
# Example: sh create_module.sh register

if [ -z "$1" ]; then
  echo "❌ Please provide a module name. Example: sh create_module.sh register"
  exit 1
fi

MODULE_NAME=$1
CLASS_NAME="$(tr '[:lower:]' '[:upper:]' <<< ${MODULE_NAME:0:1})${MODULE_NAME:1}"
MODULE_DIR="lib/features/$MODULE_NAME"

echo "🚀 Creating module: $MODULE_NAME ($CLASS_NAME)"

# Create folder structure
mkdir -p $MODULE_DIR/{api,bloc,data,model,screens,widgets}

# ---------------- API ----------------
cat <<EOF > $MODULE_DIR/api/${MODULE_NAME}_api.dart
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/api_urls.dart';
import '../model/${MODULE_NAME}_request.dart';

class ${CLASS_NAME}Api {
  final ApiClient _client;
  ${CLASS_NAME}Api(this._client);

  Future<ApiResponse<Map<String, dynamic>>> $MODULE_NAME(${CLASS_NAME}Request request) async {
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
class ${CLASS_NAME}Request {
  final String field;

  ${CLASS_NAME}Request({required this.field});

  Map<String, dynamic> toJson() => {
        "field": field,
      };
}
EOF

# ---------------- REPOSITORY ----------------
cat <<EOF > $MODULE_DIR/data/${MODULE_NAME}_repository.dart
import '../../../core/network/api_response.dart';
import '../api/${MODULE_NAME}_api.dart';
import '../model/${MODULE_NAME}_request.dart';

class ${CLASS_NAME}Repository {
  final ${CLASS_NAME}Api _api;
  ${CLASS_NAME}Repository(this._api);

  Future<ApiResponse<Map<String, dynamic>>> $MODULE_NAME(${CLASS_NAME}Request request) {
    return _api.$MODULE_NAME(request);
  }
}
EOF

# ---------------- BLOC ----------------
cat <<EOF > $MODULE_DIR/bloc/${MODULE_NAME}_event.dart
import '../model/${MODULE_NAME}_request.dart';

abstract class ${CLASS_NAME}Event {}

class ${CLASS_NAME}Submitted extends ${CLASS_NAME}Event {
  final ${CLASS_NAME}Request request;
  ${CLASS_NAME}Submitted(this.request);
}
EOF

cat <<EOF > $MODULE_DIR/bloc/${MODULE_NAME}_state.dart
abstract class ${CLASS_NAME}State {}

class ${CLASS_NAME}Initial extends ${CLASS_NAME}State {}

class ${CLASS_NAME}Loading extends ${CLASS_NAME}State {}

class ${CLASS_NAME}Success extends ${CLASS_NAME}State {
  final Map<String, dynamic> data;
  ${CLASS_NAME}Success(this.data);
}

class ${CLASS_NAME}Failure extends ${CLASS_NAME}State {
  final String message;
  ${CLASS_NAME}Failure(this.message);
}
EOF

cat <<EOF > $MODULE_DIR/bloc/${MODULE_NAME}_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_response.dart';
import '../data/${MODULE_NAME}_repository.dart';
import '../model/${MODULE_NAME}_request.dart';

import '${MODULE_NAME}_event.dart';
import '${MODULE_NAME}_state.dart';

class ${CLASS_NAME}Bloc extends Bloc<${CLASS_NAME}Event, ${CLASS_NAME}State> {
  final ${CLASS_NAME}Repository repository;

  ${CLASS_NAME}Bloc(this.repository) : super(${CLASS_NAME}Initial()) {
    on<${CLASS_NAME}Submitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    ${CLASS_NAME}Submitted event,
    Emitter<${CLASS_NAME}State> emit,
  ) async {
    emit(${CLASS_NAME}Loading());
    final response = await repository.$MODULE_NAME(event.request);

    if (response.data != null && response.statusCode == 200) {
      emit(${CLASS_NAME}Success(response.data!));
    } else {
      emit(${CLASS_NAME}Failure(response.errorMessage ?? "$CLASS_NAME failed"));
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

class ${CLASS_NAME}Screen extends StatelessWidget {
  const ${CLASS_NAME}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("$CLASS_NAME")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<${CLASS_NAME}Bloc, ${CLASS_NAME}State>(
          listener: (context, state) {
            if (state is ${CLASS_NAME}Success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("$CLASS_NAME Successful")),
              );
              Navigator.pop(context);
            } else if (state is ${CLASS_NAME}Failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is ${CLASS_NAME}Loading;
            return ${CLASS_NAME}Form(
              isLoading: isLoading,
              onSubmit: (field) {
                context.read<${CLASS_NAME}Bloc>().add(
                      ${CLASS_NAME}Submitted(
                        ${CLASS_NAME}Request(field: field),
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
import '../../../core/utils/validators.dart';

class ${CLASS_NAME}Form extends StatefulWidget {
  final void Function(String field) onSubmit;
  final bool isLoading;

  const ${CLASS_NAME}Form({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<${CLASS_NAME}Form> createState() => _${CLASS_NAME}FormState();
}

class _${CLASS_NAME}FormState extends State<${CLASS_NAME}Form> {
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
import '../../core/network/api_client.dart';
import 'api/${MODULE_NAME}_api.dart';
import 'data/${MODULE_NAME}_repository.dart';
import 'bloc/${MODULE_NAME}_bloc.dart';
import 'screens/${MODULE_NAME}_screen.dart';

class ${CLASS_NAME}Module {
  static Widget route() {
    final apiClient = ApiClient();
    final api = ${CLASS_NAME}Api(apiClient);
    final repo = ${CLASS_NAME}Repository(api);

    return BlocProvider(
      create: (_) => ${CLASS_NAME}Bloc(repo),
      child: const ${CLASS_NAME}Screen(),
    );
  }
}
EOF

echo "✅ Module '$MODULE_NAME' created successfully at $MODULE_DIR"
