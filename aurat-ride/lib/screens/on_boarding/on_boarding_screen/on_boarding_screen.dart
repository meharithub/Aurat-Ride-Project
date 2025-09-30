import 'package:aurat_ride/global_widgets/primary_ink_well.dart';
import 'package:aurat_ride/global_widgets/primary_local_svg.dart';
import 'package:aurat_ride/screens/on_boarding/on_boarding_screen/model/on_boarding_model.dart';
import 'package:aurat_ride/screens/on_boarding/on_boarding_screen/widgets/on_boarding_image_with_text.dart';
import 'package:aurat_ride/screens/on_boarding/on_boarding_screen/widgets/on_boarding_next_button.dart';
import 'package:aurat_ride/screens/welcome/welcome_screen/welcome_screen.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:aurat_ride/utlils/path/asset_paths.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>
    with SingleTickerProviderStateMixin {
  // late final PageController _pageController;
  // late final AnimationController _animationController;

  // int _currentPage = 0;

  // final List<String> pages = [
  //   "Welcome to our App",
  //   "Explore the Features",
  //   "Get Started Today"
  // ];

  @override
  void initState() {
    super.initState();
    // _pageController = PageController();
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        HelperFunctions.navigateReplace(context, WelcomeScreen());
      }
    });
    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: Duration(seconds: 3), // 1 second loader
    // )..addStatusListener((status) {
    //     if (status == AnimationStatus.completed) {
    //       onCompleted();
    //     }
    //   });
    // _animationController.forward();
  }

  // void restart() {
  //   _animationController.reset();
  //   _animationController.forward();
  // }

  // onCompleted() {
  //   if (_currentPage < kDummyOnBoardingData.length - 1) {
  //     _pageController.animateToPage(_currentPage + 1,
  //         duration: Duration(milliseconds: 200), curve: Curves.bounceIn);
  //     _currentPage += 1;
  //     restart();
  //     if (_currentPage == kDummyOnBoardingData.length - 1) {
  //       setState(() {});
  //       if (mounted) {
  //         Future.delayed(Duration(seconds: 3), () {
  //           if (mounted) {
  //             HelperFunctions.navigateReplace(context, WelcomeScreen());
  //           }
  //         });
  //       }
  //     }
  //   }
  // }

  // onNextTap() {
  //   if (_currentPage < kDummyOnBoardingData.length - 1) {
  //     _pageController.animateToPage(_currentPage + 1,
  //         duration: Duration(milliseconds: 200), curve: Curves.bounceIn);
  //     _currentPage += 1;
  //     restart();
  //     if (_currentPage == kDummyOnBoardingData.length - 1) {
  //       setState(() {});
  //       Future.delayed(Duration(seconds: 3), () {
  //         Navigator.of(context).pushReplacement(
  //             MaterialPageRoute(builder: (context) => WelcomeScreen()));
  //       });
  //     }
  //   }
  // }

  @override
  void dispose() {
    // _pageController.dispose();
    // _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryWhite,
      child: SafeArea(
          child: Scaffold(
        backgroundColor: kPrimaryWhite,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: Image.asset("$kLocalImageBaseUrl/app-logo.jpeg",
                      height: 250, width: 250)),
              // const SizedBox(
              //   height: 10,
              // ),
              // PrimaryInkWell(
              //   onTap: (){
              //     HelperFunctions.navigateReplace(context, WelcomeScreen());
              //   },
              //   child: Align(
              //       alignment: Alignment.centerRight,
              //       child: Text(
              //         "Skip",
              //         style: TextStyle(fontSize: 14, color: Colors.black54),
              //       )),
              // ),
              // const SizedBox(
              //   height: 20,
              // ),
              // Expanded(
              //   flex: 2,
              //   child: PageView.builder(
              //       physics: const NeverScrollableScrollPhysics(),
              //       controller: _pageController,
              //       itemCount: kDummyOnBoardingData.length,
              //       onPageChanged: (index) {
              //         _currentPage = index;
              //       },
              //       itemBuilder: (_, index) {
              //         final OnBoardingModel model = kDummyOnBoardingData[index];
              //         return OnBoardingImageWithText(
              //             description: model.description,
              //             heading: model.heading,
              //             imagePath: model.image);
              //       }),
              // ),
              // const SizedBox(
              //   height: 20,
              // ),
              // Expanded(
              //   child: OnBoardingNextButton(
              //     svgPath:
              //         "assets/images/on-boarding-next-button-background.svg",
              //     onTap: () {
              //       onCompleted();
              //     },
              //     isLast: _currentPage == kDummyOnBoardingData.length - 1,
              //     onCompleted: onCompleted,
              //     animationController: _animationController,
              //   ),
              // ),
              // const SizedBox(
              //   height: 40,
              // ),
            ],
          ),
        ),
      )),
    );
  }
}
