import 'package:aurat_ride/global_widgets/primary_heading.dart';
import 'package:aurat_ride/global_widgets/primary_local_svg.dart';
import 'package:aurat_ride/screens/primary_bottom_menu/primary_bottom_menu.dart';
import 'package:aurat_ride/utlils/path/asset_paths.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:flutter/material.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryWhite,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Center(
                child: Text(
                  "Favourite",
                  style: TextStyle(
                    fontSize: 20,
                    // fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
                  child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: kPrimaryWhite,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black26),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: PrimaryLocalSvg(
                                      svgPath:
                                          "$kLocalImageBaseUrl/location-icon.svg"),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "Office",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14),
                                    ),
                                    Text(
                                      "this is temp address in islamabad 203 ...",
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: PrimaryLocalSvg(
                                    svgPath: "$kLocalImageBaseUrl/remove-icon.svg"),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 15,
                        );
                      },
                      itemCount: 12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
