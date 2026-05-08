import 'package:flutter/material.dart';

class ExpandableNotes extends StatefulWidget {
  final ValueChanged<String>? onChanged;

  const ExpandableNotes({
    super.key,
    this.onChanged,
  });

  @override
  State<ExpandableNotes> createState() => _ExpandableNotesState();
}

class _ExpandableNotesState extends State<ExpandableNotes> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },
            child: Row(
              children: [
                const Icon(Icons.notes_rounded),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Add Notes',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? .5 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: const Icon(Icons.expand_more),
                )
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 18),
              child: TextField(
                maxLines: 5,
                onChanged: widget.onChanged,
                decoration: InputDecoration(
                  hintText: 'Write additional appointment details...',
                  filled: true,
                  fillColor: const Color(0xFFF2F3FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          )
        ],
      ),
    );
  }
}
