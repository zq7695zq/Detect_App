import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
// Define a widget for the fullscreen screenshot
class FullScreenScreenshot extends StatefulWidget {
  final Uint8List? screenshot;
  const FullScreenScreenshot(this.screenshot, {Key? key}) : super(key: key);

  @override
  _FullScreenScreenshotState createState() => _FullScreenScreenshotState();
}

class _FullScreenScreenshotState extends State<FullScreenScreenshot> {
  // Declare a list to store the points of the shape
  List<Offset> points = [];
  // Declare a variable to store the selected shape
  late Shape? selectedShape;

  // Define a function to calculate the relative coordinates
  List<Offset> getRelativeCoordinates(List<Offset> points, double scaleX, double scaleY) {
    // Create an empty list to store the relative coordinates
    List<Offset> relativePoints = [];
    // Loop through each point in the points list
    for (Offset point in points) {
      // Multiply the x and y coordinates by the scale factors
      double relativeX = point.dx * scaleX;
      double relativeY = point.dy * scaleY;
      // Create a new offset with the relative coordinates
      Offset relativePoint = Offset(relativeX, relativeY);
      // Add the relative point to the list
      relativePoints.add(relativePoint);
      print(relativePoint);
    }
    // Return the list of relative coordinates
    return relativePoints;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('全屏截图'),
        actions: [
          IconButton(
            onPressed: () {
              // Clear the points list and update the state
              setState(() {
                points.clear();
              });
            },
            icon: Icon(Icons.close),
          ),
          IconButton(
            onPressed: () async {
              if (points.length == 4) {
                setState(() {
                  selectedShape = Shape(points);
                });
                // Convert the Uint8List to Image
                img.Image? screenshotImage = img.decodeImage(widget.screenshot!);
                // Get the width and height of the image
                int? screenshotWidth = screenshotImage?.width;
                int? screenshotHeight = screenshotImage?.height;
                // Calculate the X and Y scale factors
                double scaleX = screenshotWidth! / MediaQuery.of(context).size.width;
                double scaleY = screenshotHeight! / (MediaQuery.of(context).size.height - kToolbarHeight);
                Navigator.pop(context, getRelativeCoordinates(points, scaleX, scaleY));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('请画出四个坐标点')));
              }
            },
            icon: Icon(Icons.done),
          ),

        ],
      ),
      body: GestureDetector(
          onTapUp: (details) {
            // Add the tapped point to the list
            setState(() {
              print(details.localPosition);
              points.add(details.localPosition);
            });
          },
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: MemoryImage(widget.screenshot!),
                fit: BoxFit.fill,
              ),
            ),
            child: Stack(
              children: [
                // Draw the shape on top of the screenshot
                CustomPaint(
                  painter: ShapePainter(points),
                  size: Size.infinite,
                )
              ],
            ),
          )

      ),
    );
  }
}


// Define a class for the shape
class Shape {
  final List<Offset> points;
  Shape(this.points);
}

// Define a custom painter for the shape
class ShapePainter extends CustomPainter {
  final List<Offset> points;
  ShapePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    // Use a red paint for the shape
    Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    // Draw a path from the points
    Path path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
