#!/bin/bash
# 프로덕트 디자인 하네스 — Agent Team 시작 (tmux split-pane 모드)
# tmux 세션 안에서 claude --agent design-lead를 실행하여 팀원이 split pane으로 표시됩니다.

PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$PROJECT_DIR"

SESSION_NAME="design-team"
LOG_FILE=".claude/logs/agent-events.jsonl"
AGENT_NAME="${1:-design-lead}"  # 기본: design-lead, 인자로 변경 가능 (예: audit-lead)

# --- 0. tmux 설치 확인 ---
if ! command -v tmux &>/dev/null; then
  echo "tmux가 설치되어 있지 않습니다. brew install tmux"
  exit 1
fi

# --- 1. 기존 세션 확인 ---
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  echo ""
  echo "  이미 tmux 세션 '$SESSION_NAME'이 실행 중입니다."
  echo "   접속: tmux attach -t $SESSION_NAME"
  exit 0
fi

echo ""
echo "Agent Team Lead 시작 (tmux split-pane 모드)"
echo "   에이전트: $AGENT_NAME"
echo "   세션: tmux attach -t $SESSION_NAME"
echo "   (종료: /exit 또는 Ctrl+C -> tmux kill-session -t $SESSION_NAME)"
echo ""

# --- 2. 로그 디렉토리 보장 ---
mkdir -p "$(dirname "$LOG_FILE")"

# --- 3. tmux 세션 생성 + claude 실행 ---
TS=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
echo "{\"ts\":\"$TS\",\"event\":\"start\",\"agent\":\"$AGENT_NAME\",\"msg\":\"Agent Team 세션 시작 (tmux)\"}" >> "$LOG_FILE"

tmux new-session -d -s "$SESSION_NAME" -c "$PROJECT_DIR" \
  "claude --agent $AGENT_NAME --dangerously-skip-permissions; \
   TS=\$(date -u +\"%Y-%m-%dT%H:%M:%S.000Z\"); \
   echo \"{\\\"ts\\\":\\\"\$TS\\\",\\\"event\\\":\\\"stop\\\",\\\"agent\\\":\\\"$AGENT_NAME\\\",\\\"msg\\\":\\\"세션 종료\\\"}\" >> \"$LOG_FILE\"; \
   echo ''; \
   echo 'Agent Team 세션 종료.'; \
   read -p '아무 키나 누르면 tmux 세션을 닫습니다...'"

# --- 4. attach ---
if [ -n "$TMUX" ]; then
  tmux switch-client -t "$SESSION_NAME"
elif [ "$TERM_PROGRAM" = "iTerm.app" ] || [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
  tmux attach -t "$SESSION_NAME"
elif command -v osascript &>/dev/null; then
  ATTACH_CMD="cd $PROJECT_DIR && tmux attach -t $SESSION_NAME"
  if [ -d "/Applications/iTerm.app" ]; then
    osascript <<APPLESCRIPT
tell application "iTerm"
  activate
  set newWindow to (create window with default profile)
  tell current session of newWindow
    write text "$ATTACH_CMD"
  end tell
end tell
APPLESCRIPT
  else
    osascript <<APPLESCRIPT
tell application "Terminal"
  activate
  do script "$ATTACH_CMD"
end tell
APPLESCRIPT
  fi
  echo "외부 터미널에서 tmux 세션이 열렸습니다."
else
  tmux attach -t "$SESSION_NAME"
fi
