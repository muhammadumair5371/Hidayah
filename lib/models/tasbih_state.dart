class TasbihState {
  final int count;
  final int target;
  final int themeIndex; // 0: Classic Beads Ring, 1: Simple Circle Counter, 2: Modern Minimal

  TasbihState({
    required this.count,
    required this.target,
    required this.themeIndex,
  });

  TasbihState copyWith({
    int? count,
    int? target,
    int? themeIndex,
  }) {
    return TasbihState(
      count: count ?? this.count,
      target: target ?? this.target,
      themeIndex: themeIndex ?? this.themeIndex,
    );
  }
}
