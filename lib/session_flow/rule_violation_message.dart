import '../play_session/models.dart';

String ruleViolationMessage(Object error) {
  if (error is! RuleViolation) return '操作未能完成，请重试。';
  return switch (error.code) {
    'player_name_required' => '请输入玩家名称。',
    'duplicate_player_name' => '名单中已经有同名玩家。',
    'player_capacity_reached' => '每场球局最多添加 64 名玩家。',
    'player_state_locked' => '这名玩家正在分组或比赛中，暂时不能修改。',
    'player_has_match_history' => '这名玩家已有比赛记录，不能从球局中移除。',
    'four_waiting_players_required' => '至少需要 4 名候场玩家才能启动球局。',
    'session_players_locked' => '球局当前状态不允许修改玩家。',
    'match_not_ready' => '这场比赛已经不是待开始状态。',
    'match_not_in_progress' => '这场比赛当前不在进行中。',
    'match_cannot_be_canceled' => '这场比赛当前不能取消。',
    'session_not_found' => '没有找到这场球局。',
    _ => '操作未能完成，请重试。',
  };
}
