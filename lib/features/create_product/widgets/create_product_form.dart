import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/validators.dart';
import '../bloc/create_product_bloc.dart';
import '../bloc/create_product_event.dart';
import '../bloc/create_product_state.dart';

class CreateProductForm extends StatefulWidget {
  const CreateProductForm({super.key});

  @override
  State<CreateProductForm> createState() => _CreateProductFormState();
}

class _CreateProductFormState extends State<CreateProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _stockController = TextEditingController();
  final _tagsController = TextEditingController();
  final _brandController = TextEditingController();
  final _weightController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _depthController = TextEditingController();
  final _warrantyController = TextEditingController();
  final _minOrderController = TextEditingController();

  String? _selectedAvailability;
  String? _selectedReturnPolicy;
  String? _selectedShipping;

  final List<String> _availabilityOptions = [
    'In Stock',
    'Low Stock',
    'Out of Stock'
  ];
  final List<String> _returnPolicyOptions = [
    'No return policy',
    '30 days return',
    '60 days return',
    '90 days return'
  ];
  final List<String> _shippingOptions = [
    'Ships in 1-2 business days',
    'Ships in 3-5 business days',
    'Ships in 1 week'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    _tagsController.dispose();
    _brandController.dispose();
    _weightController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _depthController.dispose();
    _warrantyController.dispose();
    _minOrderController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final data = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _categoryController.text.trim(),
      'price': double.parse(_priceController.text.trim()),
      'stock': int.parse(_stockController.text.trim()),
      'tags': tags,
      if (_discountController.text.isNotEmpty)
        'discountPercentage': double.parse(_discountController.text.trim()),
      if (_brandController.text.isNotEmpty)
        'brand': _brandController.text.trim(),
      if (_weightController.text.isNotEmpty)
        'weight': double.parse(_weightController.text.trim()),
      if (_widthController.text.isNotEmpty ||
          _heightController.text.isNotEmpty ||
          _depthController.text.isNotEmpty)
        'dimensions': {
          'width': _widthController.text.isNotEmpty
              ? double.parse(_widthController.text.trim())
              : 0.0,
          'height': _heightController.text.isNotEmpty
              ? double.parse(_heightController.text.trim())
              : 0.0,
          'depth': _depthController.text.isNotEmpty
              ? double.parse(_depthController.text.trim())
              : 0.0,
        },
      if (_warrantyController.text.isNotEmpty)
        'warrantyInformation': _warrantyController.text.trim(),
      if (_selectedShipping != null) 'shippingInformation': _selectedShipping,
      if (_selectedAvailability != null)
        'availabilityStatus': _selectedAvailability,
      if (_selectedReturnPolicy != null) 'returnPolicy': _selectedReturnPolicy,
      if (_minOrderController.text.isNotEmpty)
        'minimumOrderQuantity': int.parse(_minOrderController.text.trim()),
    };

    context.read<CreateProductBloc>().add(SubmitProductEvent(data));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateProductBloc, CreateProductState>(
      builder: (context, state) {
        final isLoading = state.status == CreateProductStatus.loading;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Required Fields
              Text('Required Information',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
                enabled: !isLoading,
                validator: (value) => Validators.required(value, 'Title'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                enabled: !isLoading,
                validator: (value) => Validators.required(value, 'Description'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
                enabled: !isLoading,
                validator: (value) => Validators.required(value, 'Category'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price *',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !isLoading,
                      validator: (value) =>
                          Validators.positiveNumber(value, 'Price'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !isLoading,
                      validator: (value) => Validators.integer(value, 'Stock'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Optional Fields
              Text('Optional Information',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand',
                  border: OutlineInputBorder(),
                ),
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  hintText: 'e.g., beauty, skincare, cosmetics',
                  border: OutlineInputBorder(),
                ),
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _discountController,
                      decoration: const InputDecoration(
                        labelText: 'Discount %',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !isLoading,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          return Validators.number(value, 'Discount');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dimensions
              Text('Dimensions', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _widthController,
                      decoration: const InputDecoration(
                        labelText: 'Width',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !isLoading,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                        labelText: 'Height',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !isLoading,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _depthController,
                      decoration: const InputDecoration(
                        labelText: 'Depth',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dropdowns
              DropdownButtonFormField<String>(
                value: _selectedAvailability,
                decoration: const InputDecoration(
                  labelText: 'Availability Status',
                  border: OutlineInputBorder(),
                ),
                items: _availabilityOptions
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ))
                    .toList(),
                onChanged: isLoading
                    ? null
                    : (value) {
                        setState(() => _selectedAvailability = value);
                      },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedShipping,
                decoration: const InputDecoration(
                  labelText: 'Shipping Information',
                  border: OutlineInputBorder(),
                ),
                items: _shippingOptions
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ))
                    .toList(),
                onChanged: isLoading
                    ? null
                    : (value) {
                        setState(() => _selectedShipping = value);
                      },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedReturnPolicy,
                decoration: const InputDecoration(
                  labelText: 'Return Policy',
                  border: OutlineInputBorder(),
                ),
                items: _returnPolicyOptions
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ))
                    .toList(),
                onChanged: isLoading
                    ? null
                    : (value) {
                        setState(() => _selectedReturnPolicy = value);
                      },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _warrantyController,
                decoration: const InputDecoration(
                  labelText: 'Warranty Information',
                  border: OutlineInputBorder(),
                ),
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minOrderController,
                decoration: const InputDecoration(
                  labelText: 'Minimum Order Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                enabled: !isLoading,
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Product'),
              ),
            ],
          ),
        );
      },
    );
  }
}
