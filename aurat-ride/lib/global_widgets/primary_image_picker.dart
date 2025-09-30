import 'dart:io';
import 'package:aurat_ride/global_widgets/primary_local_svg.dart';
import 'package:aurat_ride/utlils/path/asset_paths.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PrimaryAvatar extends StatefulWidget {
  final double size;
  final String? imageUrl; // optional network image
  final void Function(File file)? onImagePicked;

  const PrimaryAvatar({
    super.key,
    this.size = 96,
    this.imageUrl,
    this.onImagePicked,
  });

  @override
  State<PrimaryAvatar> createState() => _PrimaryAvatarState();
}

class _PrimaryAvatarState extends State<PrimaryAvatar> {
  File? _localImage;
  final _picker = ImagePicker();

  Future<void> _pick(ImageSource source) async {
    try {
      final x = await _picker.pickImage(source: source, imageQuality: 85);
      if (x == null) return;
      final file = File(x.path);
      setState(() => _localImage = file);
      widget.onImagePicked?.call(file);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pick(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    ImageProvider? imageProvider;
    if (_localImage != null) {
      imageProvider = FileImage(_localImage!);
    } else if (widget.imageUrl?.isNotEmpty == true) {
      imageProvider = NetworkImage(widget.imageUrl!);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? Icon(Icons.person, size: size * 0.5, color: Colors.grey)
              : null,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showPicker,
              customBorder: const CircleBorder(),
              child: Container(
                width: size * 0.32,
                height: size * 0.32,
                decoration: BoxDecoration(
                  color: kPrimaryGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: kPrimaryGreen),
                ),
                child: Center(
                  child: PrimaryLocalSvg(
                      svgPath: "$kLocalImageBaseUrl/camera-icon.svg"),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
