import 'package:flutter/material.dart';

class BoxComponent extends StatelessWidget {
  BoxComponent({
    super.key,
    required this.child,
    this.count,
  });
  String child;
  String? count;

  double screenHeight = 0;

  double screenWidth = 0;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          height: 100,
          width: 400,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: Colors.blue[400]),
          child: count != null
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        child,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    Center(
                      child: Text(
                        count!,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ),
                    // Text(
                    //   "See more ->",
                    //   style: TextStyle(color: Colors.white),
                    // )
                  ],
                )
              : Center(
                  child: Text(
                    child,
                    style: const TextStyle(color: Colors.white, fontSize: 25),
                  ),
                ),
        ),
        count != null
            ? const Positioned(
                bottom: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "See more ->",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
