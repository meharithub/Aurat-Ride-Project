// import 'package:aurat_ride/global_widgets/primary_local_svg.dart';
// import 'package:aurat_ride/utlils/theme/colors.dart';
// import 'package:flutter/material.dart';

// class OnBoardingNextButton extends StatelessWidget {
//   final VoidCallback onCompleted;
//   final VoidCallback onTap;
//   final String svgPath;
//   final bool isLast;
//   final Duration duration;
//   final double? controllerValue;
//   AnimationController animationController;

//   OnBoardingNextButton(
//       {super.key,
//       this.isLast = false,
//       required this.onCompleted,
//       required this.onTap,
//       this.duration = const Duration(seconds: 3),
//       this.controllerValue,
//       required this.animationController,
//       required this.svgPath});

//   // late final AnimationController _controller;
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: SizedBox(
//         height: 69,
//         width: 69,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             // Animated circular progress
//             AnimatedBuilder(
//               animation: animationController,
//               builder: (_, __) => SizedBox(
//                 height: 69,
//                 width: 69,
//                 child: CircularProgressIndicator(
//                   value: animationController.value,
//                   strokeWidth: 4,
//                   valueColor:
//                       AlwaysStoppedAnimation(kPrimaryGreen.withOpacity(0.8)),
//                   backgroundColor: kPrimaryGreen.withOpacity(0.3),
//                 ),
//               ),
//             ),

//             // Your center content
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 SizedBox(
//                     height: 60,
//                     width: 60,
//                     child: PrimaryLocalSvg(svgPath: svgPath)),
//                 isLast
//                     ? Text(
//                         "Go",
//                         style: TextStyle(fontSize: 18, color: Colors.black54),
//                       )
//                     : const Icon(Icons.arrow_forward, color: Colors.black54),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
