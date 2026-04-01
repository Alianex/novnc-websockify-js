import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../game_engine/bluff_mechanic.dart';
import '../models/card_model.dart';

/// Animated bluff card widget with multiple choice options
class BluffCardWidget extends StatefulWidget {
  final CardModel card;
  final List<BluffOption> options;
  final RiskLevel selectedRisk;
  final BluffOption? selectedOption;
  final Future<void> Function(BluffOption)? onOptionSelected;
  final bool isAnswered;

  const BluffCardWidget({
    Key? key,
    required this.card,
    required this.options,
    required this.selectedRisk,
    this.selectedOption,
    this.onOptionSelected,
    this.isAnswered = false,
  }) : super(key: key);

  @override
  State<BluffCardWidget> createState() => _BluffCardWidgetState();
}

class _BluffCardWidgetState extends State<BluffCardWidget>
  with TickerProviderStateMixin {
  late List<AnimationController> _optionControllers;
  late AnimationController _questionController;

  @override
  void initState() {
    super.initState();
    _questionController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _optionControllers = List.generate(
      widget.options.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animateIn();
  }

  void _animateIn() {
    _questionController.forward();
    for (int i = 0; i < _optionControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 100 * (i + 1)), () {
        if (mounted) {
          _optionControllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Question card
          ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: _questionController, curve: Curves.elasticOut),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Choose the correct answer',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.blue[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.card.question,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.card.hint != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lightbulb, size: 16, color: Colors.amber[700]),
                          const SizedBox(width: 6),
                          Text(
                            'Hint: ${widget.card.hint}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.amber[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Options grid
          ...List.generate(
            widget.options.length,
            (index) => _buildOptionButton(
              context,
              widget.options[index],
              index,
              _optionControllers[index],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    BluffOption option,
    int index,
    AnimationController controller,
  ) {
    final isSelected = widget.selectedOption == option;
    final showCorrect = widget.isAnswered && option.isCorrect;
    final showIncorrect = widget.isAnswered &&
        !option.isCorrect &&
        widget.selectedOption == option;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GestureDetector(
            onTap: widget.isAnswered || widget.onOptionSelected == null
              ? null
              : () {
                widget.onOptionSelected?.call(option);
              },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _getOptionColor(showCorrect, showIncorrect, isSelected).withOpacity(0.1),
              border: Border.all(
                color: _getOptionColor(showCorrect, showIncorrect, isSelected),
                width: isSelected ? 2.5 : 1.5,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _getOptionColor(showCorrect, showIncorrect, isSelected)
                            .withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Option indicator circle
                AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: isSelected ? 1.2 : 1.0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getOptionColor(showCorrect, showIncorrect, isSelected)
                          .withOpacity(0.3),
                      border: Border.all(
                        color: _getOptionColor(showCorrect, showIncorrect, isSelected),
                        width: isSelected ? 2 : 1.5,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Icon(
                              showCorrect ? Icons.check : Icons.close,
                              size: 14,
                              color: _getOptionColor(showCorrect, showIncorrect, isSelected),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 12),
                // Option text
                Expanded(
                  child: Text(
                    option.text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _getOptionColor(showCorrect, showIncorrect, isSelected),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                // Feedback icon
                if (widget.isAnswered) ...[
                  const SizedBox(width: 12),
                  if (showCorrect)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    )
                  else if (showIncorrect)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getOptionColor(bool showCorrect, bool showIncorrect, bool isSelected) {
    if (showCorrect) return Colors.green;
    if (showIncorrect) return Colors.red;
    if (isSelected) {
      return switch (widget.selectedRisk) {
        RiskLevel.low => Colors.green,
        RiskLevel.medium => Colors.orange,
        RiskLevel.high => Colors.red,
      };
    }
    return Colors.grey[600]!;
  }
}
