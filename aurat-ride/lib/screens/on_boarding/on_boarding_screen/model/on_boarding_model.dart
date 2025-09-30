import '../../../../utlils/path/asset_paths.dart';

class OnBoardingModel {
  final String image, heading, description;
  OnBoardingModel(
      {required this.image, required this.heading, required this.description});
}

final List<OnBoardingModel> kDummyOnBoardingData = [
  OnBoardingModel(
      image: '$kLocalImageBaseUrl/on-boarding-1.svg',
      heading: "Anywhere you are",
      description:
          "Sell houses easily with the help of Listenoryx and to make this line. I am writing more."),
  OnBoardingModel(
      image: '$kLocalImageBaseUrl/on-boarding-2.svg',
      heading: "Anywhere you are",
      description:
          "Sell houses easily with the help of Listenoryx and to make this line. I am writing more."),
  OnBoardingModel(
      image: '$kLocalImageBaseUrl/on-boarding-3.svg',
      heading: "Anywhere you are",
      description:
          "Sell houses easily with the help of Listenoryx and to make this line. I am writing more."),
];
