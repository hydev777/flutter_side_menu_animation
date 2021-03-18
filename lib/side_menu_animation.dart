import 'package:flutter/material.dart';

/// Signature for creating a widget with a `showMenu` callback
/// for opening the Side Menu.
///
/// See also:
/// * [SideMenuAnimation.builder]
/// * [SideMenuAnimationAppBarBuilder]
typedef SideMenuAnimationBuilder = Widget Function(VoidCallback showMenu);

/// Signature for creating an [AppBar] widget with a
/// `showMenu` callback for opening the Side Menu.
///
/// See also:
/// * [SideMenuAnimation].
typedef SideMenuAnimationAppBarBuilder = AppBar Function(VoidCallback showMenu);

const _sideMenuWidth = 100.0;
const _sideMenuDuration = Duration(milliseconds: 800);
const _kEdgeDragWidth = 20.0;

/// # SideMenuPosition
/// This enum is the position selector of the menu.
///
/// {@template SideMenuPosition.right}
/// ## right
/// Set the position of the menu in the right side on the screen
/// {@endtemplate}
///
/// {@template SideMenuPosition.left}
/// ## left
/// Set the position of the menu in the left side on the screen
/// {@endtemplate}
enum SideMenuPosition {
  /// {@macro SideMenuPosition.right}
  right,

  /// {@macro SideMenuPosition.left}
  left,
}

extension _SideMenuPositionX on SideMenuPosition {
  bool get isLeft => this == SideMenuPosition.left;
  bool get isRight => this == SideMenuPosition.right;
}

/// The [SideMenuAnimation] controls the items from the lateral menu
/// and also can control the circular reveal transition.
class SideMenuAnimation extends StatefulWidget {
  /// Creates a [SideMenuAnimation] without Circular Reveal animation.
  /// Also it is responsible for updating/changing the [AppBar]
  /// based on the index we receive.
  const SideMenuAnimation.builder({
    Key? key,
    required this.builder,
    required this.items,
    required this.onItemSelected,
    this.position = SideMenuPosition.left,
    this.selectedColor = Colors.black,
    this.unselectedColor = Colors.green,
    double? menuWidth,
    Duration? duration,
    this.tapOutsideToDismiss = false,
    this.scrimColor = Colors.transparent,
    double? edgeDragWidth,
    this.enableEdgeDragGesture = false,
    this.curveAnimation = Curves.linear,
  })  : views = null,
        appBarBuilder = null,
        indexSelected = null,
        menuWidth = menuWidth ?? _sideMenuWidth,
        duration = duration ?? _sideMenuDuration,
        edgeDragWidth = edgeDragWidth ?? _kEdgeDragWidth,
        super(key: key);

  /// Creates a [SideMenuAnimation] with Circular Reveal animation.
  /// Alse it is responsible for updating/changing the [AppBar]
  /// based on the index we receive.
  const SideMenuAnimation({
    Key? key,
    required this.views,
    required this.items,
    required this.onItemSelected,
    this.position = SideMenuPosition.left,
    this.selectedColor = Colors.black,
    this.unselectedColor = Colors.green,
    double? menuWidth,
    Duration? duration,
    this.appBarBuilder,
    this.indexSelected = 0,
    this.tapOutsideToDismiss = false,
    this.scrimColor = Colors.transparent,
    double? edgeDragWidth,
    this.enableEdgeDragGesture = false,
    this.curveAnimation = Curves.linear,
  })  : builder = null,
        menuWidth = menuWidth ?? _sideMenuWidth,
        duration = duration ?? _sideMenuDuration,
        edgeDragWidth = edgeDragWidth ?? _kEdgeDragWidth,
        super(key: key);

  /// `builder` where we have to return our view/page based on the index we
  /// have. It also comes with a `showMenu` callback for
  /// opening the Side Menu.
  final SideMenuAnimationBuilder? builder;

  /// Builder where we have to return our [AppBar] based on the
  /// index we have, it also comes with the `showMenu` callback
  /// where we can use to open the Side Menu.
  final SideMenuAnimationAppBarBuilder? appBarBuilder;

  /// List of items that we want to display on the Side Menu.
  final List<Widget> items;

  /// Function where we receive the current index selected.
  final ValueChanged<int> onItemSelected;

  /// [Color] used for the background of the selected item.
  final Color selectedColor;

  /// [Color] used for the background of the unselected item.
  final Color unselectedColor;

  /// Menu width for the Side Menu.
  final double menuWidth;

  /// Duration for the animation when the menu appears, this is the total duration, each item has total_duration/items.lenght
  final Duration duration;

  /// Pages/Views we pass to the widge to display with a circular reveal animation
  final List<Widget>? views;

  /// Initial index selected
  final int? indexSelected;

  /// If we want to tap outside the menu to dismiss the Side Menu,
  /// set this to `true`. It's `false` by default.
  final bool tapOutsideToDismiss;

  /// if we want the menu to appear on the right or left side.
  /// by default it is on the left side.
  final SideMenuPosition position;

  /// If `tapOutsideToDismiss` is true, then we can change the `scrimColor`,
  /// this is the panel where we tap to dismiss the Side Menu.
  final Color scrimColor;

  /// Enable swipe from left to right to display the menu,
  /// it's `false` by default. `enableEdgeDragGesture`
  final bool enableEdgeDragGesture;

  /// If `enableEdgeDragGesture` is true, then we can change
  /// the `edgeDragWidth`, this is the width of the area where we do swipe.
  final double edgeDragWidth;

  /// Curve used for the animation
  final Curve curveAnimation;

  @override
  _SideMenuAnimationState createState() => _SideMenuAnimationState();
}

class _SideMenuAnimationState extends State<SideMenuAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  late int _selectedIndex;
  late int _oldSelectedIndex;
  int _selectedColor = 1;
  bool _dontAnimate = false;
  late ColorTween _scrimColorTween;

  @override
  void initState() {
    _selectedIndex = widget.indexSelected ?? 0;
    _oldSelectedIndex = _selectedIndex;
    _animationController =
        AnimationController(vsync: this, duration: widget.duration);
    _createAnimations();
    _animationController.forward(from: 1.0);
    _createColorTween();
    super.initState();
  }

  void _createAnimations() {
    final _intervalGap = 1 / widget.items.length;
    _animations = List.generate(
      widget.items.length,
      (index) => Tween(begin: 0.0, end: 1.6).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            _intervalGap * index,
            _intervalGap * (index + 1),
            curve: widget.curveAnimation,
          ),
        ),
      ),
    );
  }

  void _createColorTween() {
    _scrimColorTween = ColorTween(
      end: Colors.transparent,
      begin: widget.scrimColor,
    );
  }

  @override
  void didUpdateWidget(SideMenuAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrimColor != widget.scrimColor) _createColorTween();
    if (oldWidget.items.length != widget.items.length) _createAnimations();
    if (oldWidget.duration != widget.duration) {
      _animationController.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _displayMenuDragGesture(DragEndDetails endDetails) {
    final velocity = endDetails.primaryVelocity!;
    if (widget.position.isLeft) {
      if (velocity > 0) _animationReverse();
    } else {
      if (velocity < 0) _animationReverse();
    }
  }

  void _animationReverse() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemSize = constraints.maxHeight / widget.items.length;
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => Stack(
              children: [
                if (widget.builder != null) widget.builder!(_animationReverse),
                if (widget.appBarBuilder != null)
                  Scaffold(
                    appBar: widget.appBarBuilder!(_animationReverse),
                    body: Stack(
                      children: [
                        if (widget.views!.isNotEmpty) ...[
                          widget.views![_oldSelectedIndex],
                          ClipPath(
                            clipper: _MainSideMenuClipper(
                              percent: _animationController.status ==
                                          AnimationStatus.forward &&
                                      _selectedIndex != _oldSelectedIndex &&
                                      !_dontAnimate
                                  ? Tween(begin: 0.0, end: 3.0)
                                      .animate(_animationController)
                                      .value
                                  : 3.0,
                              dy: (itemSize * _selectedIndex) + (itemSize / 2),
                              dx: widget.position.isLeft
                                  ? 0.0
                                  : constraints.maxWidth,
                            ),
                            child: widget.views![_selectedIndex],
                          )
                        ],
                      ],
                    ),
                  ),
                if (widget.tapOutsideToDismiss &&
                    _animationController.value < 1)
                  Align(
                    child: GestureDetector(
                      onTap: () {
                        _dontAnimate = true;
                        _animationController.forward(from: 0.0);
                      },
                      child: AnimatedContainer(
                        duration: widget.duration,
                        color: _scrimColorTween.evaluate(
                          Tween(begin: 0.0, end: 1.0)
                              .animate(_animationController),
                        ),
                      ),
                    ),
                  ),
                if (widget.enableEdgeDragGesture &&
                    _animationController.isCompleted)
                  Align(
                    alignment: widget.position.isLeft
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: GestureDetector(
                      onHorizontalDragEnd: _displayMenuDragGesture,
                      behavior: HitTestBehavior.translucent,
                      excludeFromSemantics: true,
                      child: Container(width: widget.edgeDragWidth),
                    ),
                  ),
                for (int i = 0; i < widget.items.length; i++)
                  Positioned(
                    left: widget.position.isLeft ? 0 : null,
                    right: widget.position.isRight ? 0 : null,
                    top: itemSize * i,
                    width: widget.menuWidth,
                    height: itemSize,
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_animationController.status ==
                                AnimationStatus.reverse
                            ? -_animations[widget.items.length - 1 - i].value
                            : -_animations[i].value),
                      alignment: widget.position.isRight
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      child: Material(
                        color: (i == _selectedColor)
                            ? widget.selectedColor
                            : widget.unselectedColor,
                        child: InkWell(
                          onTap: () {
                            _animationController.forward(from: 0.0);
                            if (i != 0) {
                              setState(() {
                                _oldSelectedIndex = _selectedIndex;
                                _selectedIndex = i - 1;
                                _selectedColor = i;
                              });
                              _dontAnimate = false;
                            } else {
                              _dontAnimate = true;
                            }
                            widget.onItemSelected(i);
                          },
                          child: widget.items[i],
                        ),
                      ),
                    ),
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MainSideMenuClipper extends CustomClipper<Path> {
  _MainSideMenuClipper({
    required this.percent,
    required this.dx,
    required this.dy,
  });

  final double percent;
  final double dx, dy;

  @override
  Path getClip(Size size) => Path()
    ..addOval(
      Rect.fromCenter(
        center: Offset(dx, dy),
        width: size.width * percent,
        height: size.height * percent,
      ),
    );

  @override
  bool shouldReclip(covariant _MainSideMenuClipper oldClipper) =>
      oldClipper.percent != percent;
}
