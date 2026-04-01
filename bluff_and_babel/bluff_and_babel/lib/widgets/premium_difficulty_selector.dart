import 'package:flutter/material.dart';

/// Premium difficulty level card with color coding.
///
/// Features:
/// - Color-coded difficulty (green/orange/red)
/// - Animated scale and glow on selection
/// - Icon + label display
/// - Badge with difficulty level
class DifficultyCard extends StatefulWidget {
  final int level;
  final String label;
  final String description;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const DifficultyCard({
    super.key,
    required this.level,
    required this.label,
    required this.description,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<DifficultyCard> createState() => _DifficultyCardState();
}

class _DifficultyCardState extends State<DifficultyCard> {
  @override
  Widget build(BuildContext context) {
    final boxShadow = widget.isSelected
        ? [
            BoxShadow(
              color: widget.color.withOpacity(0.25),
              blurRadius: 20,
              spreadRadius: 3,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ];

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: widget.isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.95),
            border: Border.all(
              color: widget.isSelected ? widget.color.withOpacity(0.8) : Colors.grey[300]!,
              width: widget.isSelected ? 2 : 1.5,
            ),
            boxShadow: boxShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.15),
                  border: Border.all(
                    color: widget.color.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.level.toString(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: widget.color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
              ),
              if (widget.isSelected) ...[
                const SizedBox(height: 12),
                Icon(
                  Icons.check_circle,
                  color: widget.color,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Premium difficulty selector with color-coded cards.
///
/// Shows difficulty levels as interactive cards with:
/// - Color coding (green for easy, orange for medium, red for hard)
/// - Animated selection with glow effect
/// - Descriptive text
class PremiumDifficultySelector extends StatefulWidget {
  final int initialDifficulty;
  final ValueChanged<int> onDifficultyChanged;

  const PremiumDifficultySelector({
    super.key,
    this.initialDifficulty = 1,
    required this.onDifficultyChanged,
  });

  @override
  State<PremiumDifficultySelector> createState() =>
      _PremiumDifficultySelectorState();
}

class _PremiumDifficultySelectorState extends State<PremiumDifficultySelector>
    with TickerProviderStateMixin {
  late int _selectedDifficulty;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.initialDifficulty.clamp(1, 3);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeTransition(
          opacity: _fadeController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Difficulty',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how challenging you want your learning experience to be',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (isMobile)
          Column(
            children: [
              DifficultyCard(
                level: 1,
                label: 'Easy',
                description: 'Perfect for beginners\nCommon words & phrases',
                color: Colors.green,
                isSelected: _selectedDifficulty == 1,
                onTap: () {
                  setState(() => _selectedDifficulty = 1);
                  widget.onDifficultyChanged(1);
                },
              ),
              const SizedBox(height: 12),
              DifficultyCard(
                level: 2,
                label: 'Medium',
                description: 'Intermediate vocabulary\nMix of common & advanced',
                color: Colors.orange,
                isSelected: _selectedDifficulty == 2,
                onTap: () {
                  setState(() => _selectedDifficulty = 2);
                  widget.onDifficultyChanged(2);
                },
              ),
              const SizedBox(height: 12),
              DifficultyCard(
                level: 3,
                label: 'Hard',
                description: 'Advanced vocabulary\nChallenging & contextual',
                color: Colors.red,
                isSelected: _selectedDifficulty == 3,
                onTap: () {
                  setState(() => _selectedDifficulty = 3);
                  widget.onDifficultyChanged(3);
                },
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: DifficultyCard(
                  level: 1,
                  label: 'Easy',
                  description: 'Perfect for\nbeginners',
                  color: Colors.green,
                  isSelected: _selectedDifficulty == 1,
                  onTap: () {
                    setState(() => _selectedDifficulty = 1);
                    widget.onDifficultyChanged(1);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DifficultyCard(
                  level: 2,
                  label: 'Medium',
                  description: 'Intermediate\nlevel',
                  color: Colors.orange,
                  isSelected: _selectedDifficulty == 2,
                  onTap: () {
                    setState(() => _selectedDifficulty = 2);
                    widget.onDifficultyChanged(2);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DifficultyCard(
                  level: 3,
                  label: 'Hard',
                  description: 'Challenging\nadvanced',
                  color: Colors.red,
                  isSelected: _selectedDifficulty == 3,
                  onTap: () {
                    setState(() => _selectedDifficulty = 3);
                    widget.onDifficultyChanged(3);
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }
}
