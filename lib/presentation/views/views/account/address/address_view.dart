import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/data/models/address_model.dart';
import 'package:ztajir_furniture/presentation/view_model/address_service.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';
import 'package:ztajir_furniture/presentation/views/widgets/custom_confirmation_dialog.dart';
import 'package:ztajir_furniture/presentation/views/widgets/primary_button.dart';
import 'package:ztajir_furniture/presentation/views/widgets/address/address_card.dart';
import 'package:ztajir_furniture/presentation/views/widgets/address/address_selection_sheet.dart';
import 'package:ztajir_furniture/presentation/views/views/account/address/view_location_screen.dart';
import 'package:ztajir_furniture/presentation/views/views/account/address/map_picker_screen.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class AddressesScreen extends StatefulWidget {
  final Function(AddressModel)? onSelect;
  const AddressesScreen({super.key, this.onSelect});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<AddressModel> _addresses = [];
  final AddressService _addressService = AddressService();
  final _titleController = TextEditingController();
  final _detailController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    final addresses = await _addressService.loadAddresses();
    setState(() {
      _addresses = addresses;
      _isLoading = false;
    });
  }

  Future<void> _deleteAddress(int index) async {
    final loc = AppLocalizations.of(context)!;
    final confirm = await CustomConfirmationDialog.show(
      context: context,
      title: loc.translate('delete_address_title'),
      content: loc.translate('delete_address_confirm'),
      confirmText: loc.translate('delete'),
      cancelText: loc.translate('cancel'),
      icon: Icons.location_off_rounded,
      confirmColor: AppColors.redColor,
      iconColor: AppColors.redColor,
    );

    if (confirm) {
      final addresses = await _addressService.deleteAddress(index);
      setState(() => _addresses = addresses);
    }
  }

  Future<void> _addManualAddress() async {
    if (_titleController.text.isEmpty || _detailController.text.isEmpty) return;

    final address = _addressService.createAddress(
      title: _titleController.text.trim(),
      details: _detailController.text.trim(),
    );

    final addresses = await _addressService.addAddress(address);
    setState(() => _addresses = addresses);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: StaticAppBar(appBarName: loc.translate('addresses_title')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(child: _buildAddressList(loc)),
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: PrimaryButton(
                    text: loc.translate('add_new_address'),
                    onPressed: _showSelectionSheet,
                    height: 55.h,
                    borderRadius: 15.w,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAddressList(AppLocalizations loc) {
    if (_addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_rounded,
              size: 80.w,
              color: AppColors.darkGreyColor,
            ),
            SizedBox(height: 16.h),
            Text(
              loc.translate('no_saved_addresses'),
              style: TextStyle(fontSize: 16.sp, color: AppColors.darkGreyColor),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: _addresses.length,
      itemBuilder: (context, index) {
        final address = _addresses[index];
        return AddressCard(
          address: address,
          onDelete: () => _deleteAddress(index),
          onTap: () {
            if (widget.onSelect != null) {
              widget.onSelect!(address);
              Navigator.pop(context);
            } else if (address.lat != 0.0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ViewLocationScreen(address: address),
                ),
              );
            }
          },
        );
      },
    );
  }

  void _showSelectionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.w)),
      ),
      builder: (_) => AddressSelectionSheet(
        onManualTap: () {
          Navigator.pop(context);
          _showManualEntryDialog();
        },
        onMapTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MapPickerScreen()),
          ).then((_) => _loadAddresses());
        },
      ),
    );
  }

  void _showManualEntryDialog() {
    final loc = AppLocalizations.of(context)!;
    _titleController.clear();
    _detailController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.secondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.w),
        ),
        title: Text(
          loc.translate('new_address_dialog_title'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: loc.translate('address_title_hint'),
                filled: true,
                fillColor: AppColors.whiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.w),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _detailController,
              decoration: InputDecoration(
                hintText: loc.translate('address_details_hint'),
                filled: true,
                fillColor: AppColors.whiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.w),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                  ),
                  child: Text(
                    loc.translate('cancel'),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _addManualAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.w),
                    ),
                  ),
                  child: Text(
                    loc.translate('save'),
                    style: const TextStyle(color: AppColors.whiteColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
