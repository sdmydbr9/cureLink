import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'continuation.dart';
import 'lab_report.dart';
import 'dart:math' as math;

class MyFloatingActionButton extends StatefulWidget {
  final VoidCallback onResetPressed;
  final String opdNumber;
  final String species;

  MyFloatingActionButton({
    required this.onResetPressed,
    required this.opdNumber,
    required this.species,
  });

  @override
  _MyFloatingActionButtonState createState() => _MyFloatingActionButtonState();
}

class _MyFloatingActionButtonState extends State<MyFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotateAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1.0),
      end: Offset(0.75, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(_animationController);

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _showActionSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('Options'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContinuationPage(
                      opdNumber: widget.opdNumber,
                    ),
                  ),
                );
              },
              child: Text('Continuation Page'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LabReportPage(
                      opdNumber: widget.opdNumber,
                      species: widget.species,
                    ),
                  ),
                );
              },
              child: Text('Lab Report Page'),
            ),
            CupertinoActionSheetAction(
              onPressed: widget.onResetPressed,
              child: Text('Reset'),
              isDestructiveAction: true,
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isExpanded)
          GestureDetector(
            onTap: _toggleExpansion,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        Positioned(
          bottom: 16.0,
          left: 16.0,
          child: FloatingActionButton(
            onPressed: _showActionSheet,
            backgroundColor:
                Colors.transparent, // Set background color to transparent
            elevation: 0.0, // Remove elevation
            child: Row(
              children: [
                Icon(
                  Icons.more_vert,
                  color: CupertinoColors.systemGrey2,
                  size: 40, // System's gray color
                ),
              ],
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: _isExpanded ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOption(
                    icon: Icons.arrow_forward,
                    title: 'Continuation Page',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContinuationPage(
                            opdNumber: widget.opdNumber,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 8.0),
                  _buildOption(
                    icon: Icons.arrow_forward,
                    title: 'Lab Report Page',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LabReportPage(
                            opdNumber: widget.opdNumber,
                            species: widget.species,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 8.0),
                  _buildOption(
                    icon: Icons.restore,
                    title: 'Reset',
                    onTap: widget.onResetPressed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon),
              SizedBox(width: 8.0),
              Text(
                title,
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
