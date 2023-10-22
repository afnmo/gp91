import 'package:flutter/material.dart';

class CustomSnackBarContent extends StatefulWidget {
  const CustomSnackBarContent({
    super.key,
    required this.errorTitle,
    required this.errorBody,
    required this.snackBarcolor,
    required this.iconColor,
  });

  final String errorTitle;
  final String errorBody;
  final Color snackBarcolor;
  final Color iconColor;

  @override
  State<StatefulWidget> createState() => _CustomSnackBarContentState();
}

class _CustomSnackBarContentState extends State<CustomSnackBarContent> {
  bool isWidgetVisible = true;

  void removeWidget() {
    setState(() {
      isWidgetVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isWidgetVisible) {
      return const SizedBox(); // Return an empty container if the widget is not visible.
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          height: 90,
          decoration: BoxDecoration(
            color: widget.snackBarcolor,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 58,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.errorTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    // Spacer(),
                    Text(
                      widget.errorBody,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
            ),
            child: Icon(
              Icons.bubble_chart,
              size: 80,
              color: widget.iconColor,
            ),
          ),
        ),
        Positioned(
          top: -25,
          // left: 0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: removeWidget,
                icon: Icon(
                  Icons.circle,
                  size: 40,
                  color: widget.iconColor,
                ),
              ),
              Positioned(
                top: 3,
                left: 3,
                child: IconButton(
                  onPressed: removeWidget,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
