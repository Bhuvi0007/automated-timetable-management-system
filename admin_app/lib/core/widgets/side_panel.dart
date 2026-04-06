import 'package:flutter/material.dart';
// import 'package:admin_app/core/constants/routes.dart';

class SidePanel extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SidePanel(
      {super.key, required this.selectedIndex, required this.onItemSelected});

  @override
  State<SidePanel> createState() => _SidePanelState();
}

class _SidePanelState extends State<SidePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  bool _isArrowHover = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _widthAnimation = Tween<double>(
      begin: 235.0,
      end: 60.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // We decide the expanded layout based on a higher threshold
  bool get _isExpanded => _widthAnimation.value >= 100.0;

  void _togglePanel() {
    if (_controller.isAnimating) return;
    if (_controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        final bool isExpanded = _isExpanded;
        return Container(
          width: _widthAnimation.value,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              right: BorderSide(
                color: Color(0xFFDCDCDC),
                width: 1.5,
              ),
            ),
          ),
          child: Column(
            children: [
              _buildToggleButton(isExpanded: isExpanded),
              _buildMenuItems(isExpanded: isExpanded),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleButton({required bool isExpanded}) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isArrowHover = true),
        onExit: (_) => setState(() => _isArrowHover = false),
        child: InkWell(
          onTap: _togglePanel,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isArrowHover
                      ? const Color(0xFFF0F4F9)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isExpanded ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItems({required bool isExpanded}) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _buildMenuItem(
            icon: Icons.home_outlined,
            label: 'Dashboard',
            isActive: widget.selectedIndex == 0,
            onTap: () {
              widget.onItemSelected(0);
            },
            isExpanded: isExpanded,
          ),
          _buildMenuItem(
            icon: Icons.person_outline,
            label: 'Teachers',
            isActive: widget.selectedIndex == 1,
            onTap: () {
              widget.onItemSelected(1);
            },
            isExpanded: isExpanded,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    VoidCallback? onTap,
    required bool isExpanded,
  }) {
    if (!isExpanded) {
      // Collapsed layout: Only show a centered fixed-size icon.
      return AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: 60, // fixed to the collapsed panel width
            height: 56,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFF0F4F9) : null,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: SizedBox(
                width: 36,
                height: 36,
                child: Icon(
                  icon,
                  size: 25,
                  color: const Color(0xFF4B71A6),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // Expanded layout: Show the icon, spacer, and text.
      return AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: InkWell(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFF0F4F9) : null,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: Icon(
                    icon,
                    size: 25,
                    color: const Color(0xFF4B71A6),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF4B71A6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
