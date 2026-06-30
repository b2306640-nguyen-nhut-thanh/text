import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../shared/dialog_utils.dart';
import 'products_manager.dart';

class EditProductScreen extends StatefulWidget {
  EditProductScreen(
    Product? product, {
    super.key,
  }) {
    if (product == null) {
      this.product = Product(
        id: null,
        title: '',
        price: 0,
        description: '',
        imageUrl: '',
      );
    } else {
      this.product = product;
    }
  }

  late final Product product;

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _editForm = GlobalKey<FormState>();
  late Product _editedProduct;

  @override
  void initState() {
    _editedProduct = widget.product;
    super.initState();
  }
  
  Future<void> _saveForm() async {
    final isValid =
        _editForm.currentState!.validate() && _editedProduct.hasFeaturedImage();
    if (!isValid) {
      return;
    }
    _editForm.currentState!.save();

    try {
      final productsManager = context.read<ProductsManager>();
      if (_editedProduct.id != null) {
        await productsManager.updateProduct(_editedProduct);
      } else {
        await productsManager.addProduct(_editedProduct);
      }
    } catch (error) {
      if (mounted) {
        showErrorDialog(context, 'Something went wrong.');
      }
    }
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editedProduct.id != null ? 'Edit Product' : 'Add Product'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _editForm,
          child: ListView(
            children: <Widget>[
              _buildTitleField(),
              _buildPriceField(),
              _buildDescriptionField(),
              _buildProductPreview(),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildTitleField() {
    return TextFormField(
      initialValue: _editedProduct.title,
      decoration: const InputDecoration(labelText: 'Title'),
      textInputAction: TextInputAction.next,
      autofocus: true,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please provide a value.';
        }
        return null;
      },
      onSaved: (value) {
        _editedProduct = _editedProduct.copyWith(title: value);
      },
    );
  }

  TextFormField _buildPriceField() {
    return TextFormField(
      initialValue: _editedProduct.price.toString(),
      decoration: const InputDecoration(labelText: 'Price'),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter a price.';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number.';
        }
        if (double.parse(value) <= 0) {
          return 'Please enter a number greater than zero.';
        }
        return null;
      },
      onSaved: (value) {
        _editedProduct = _editedProduct.copyWith(price: double.parse(value!));
      },
    );
  }

  TextFormField _buildDescriptionField() {
    return TextFormField(
      initialValue: _editedProduct.description,
      decoration: const InputDecoration(labelText: 'Description'),
      maxLines: 3,
      keyboardType: TextInputType.multiline,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Please enter a description.';
        }
        if (value.length < 10) {
          return 'Should be at least 10 characters long.';
        }
        return null;
      },
      onSaved: (value) {
        _editedProduct = _editedProduct.copyWith(description: value);
      },
    );
  }

  Widget _buildProductPreview() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(top: 8, right: 10),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ), // BoxDecoration
          child: !_editedProduct.hasFeaturedImage()
              ? const Center(child: Text('No Image'))
              : FittedBox(
                  child: _editedProduct.featuredImage == null
                      ? Image.network(
                          _editedProduct.imageUrl,
                          fit: BoxFit.cover,
                        ) // Image.network
                      : Image.file(
                          _editedProduct.featuredImage!,
                          fit: BoxFit.cover,
                        ), // Image.file
                ), // FittedBox
        ), // Container
        Expanded(
          child: SizedBox(height: 100, child: _buildImagePickerButton()),
        ), // Expanded
      ], // <Widget>[]
    ); // Row
  }

  TextButton _buildImagePickerButton() {
    return TextButton.icon(
      icon: const Icon(Icons.image),
      label: const Text('Pick Image'),
      onPressed: () async {
        final imagePicker = ImagePicker();
        try {
          final imageFile = await imagePicker.pickImage(
            source: ImageSource.gallery,
          );
          if (imageFile == null) {
            return;
          }

          _editedProduct = _editedProduct.copyWith(
            featuredImage: File(imageFile.path),
          );

          setState(() {});
        } catch (error) {
          if (mounted) {
            showErrorDialog(context, 'Something went wrong.');
          }
        }
      },
    ); // TextButton.icon
  }
}
