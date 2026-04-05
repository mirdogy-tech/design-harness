---
name: harness-verify
description: |
  하네스 구성 감사 오케스트레이터. .claude/ 에이전트/스킬/규칙/훅/MCP의 완전성과 정합성을 팀으로 검증.
  '하네스 감사', '하네스 점검', '에이전트 구조 검증', '하네스 검증', '하네스 체크', '에이전트 팀 검증' 요청 시 반드시 이 스킬을 사용.
  단순 파일 읽기가 아닌 교차 비교 기반 정합성 검증을 수행하므로, 하네스 관련 질문이면 이 스킬을 로드할 것.
---

# 하네스 감사 오케스트레이터

프로젝트 .claude/ 하네스 구성의 완전성과 정합성을 팬아웃/팬인 에이전트 팀으로 검증한다.

## 실행 모드: 에이전트 팀

## 에이전트 구성

| 팀원 | 역할 | 검증 영역 | 출력 |
|------|------|----------|------|
| audit-lead | 리더: 태스크 분배 + 결과 종합 | 전체 조율 | 최종 보고서 |
| structure-checker | 정적 구조 검증 | A(에이전트) B(스킬) C(규칙) D(CLAUDE.md) | 구조 검증 결과 |
| pipeline-checker | 동적 파이프라인 검증 | E(훅) F(스크립트) G(MCP) H(토큰) I(데이터흐름) | 파이프라인 검증 결과 |

## 워크플로우

### Phase 1: 준비
1. 프로젝트의 .claude/ 디렉토리 구조 파악
2. 감사 대상 파일 목록 수집 (agents/, skills/, rules/, settings.json, .mcp.json, CLAUDE.md)

### Phase 2: 팀 구성

```
TeamCreate(
  team_name: "audit-team",
  members: [
    { name: "structure-checker", agent_type: "structure-checker", model: "opus",
      prompt: "프로젝트의 .claude/ 하네스 정적 구조를 검증하라. 에이전트 정의(A), 스킬 구조(B), 규칙 자동로드(C), CLAUDE.md 일관성(D) 4개 영역을 모두 검증하고 결과를 보고하라." },
    { name: "pipeline-checker", agent_type: "pipeline-checker", model: "opus",
      prompt: "프로젝트의 .claude/ 하네스 동적 파이프라인을 검증하라. 훅 체인(E), 스크립트(F), MCP(G), 토큰 최적화(H), 데이터 흐름(I) 5개 영역을 모두 검증하고 결과를 보고하라." }
  ]
)
```

### Phase 3: 감사 실행 (팬아웃)

9개 태스크를 병렬 할당:

```
TaskCreate(tasks: [
  { title: "A: 에이전트 정의 검증", assignee: "structure-checker" },
  { title: "B: 스킬 구조 검증", assignee: "structure-checker" },
  { title: "C: 규칙 자동로드 검증", assignee: "structure-checker" },
  { title: "D: CLAUDE.md 일관성 검증", assignee: "structure-checker" },
  { title: "E: 훅 체인 무결성 검증", assignee: "pipeline-checker" },
  { title: "F: 스크립트 존재/실행 검증", assignee: "pipeline-checker" },
  { title: "G: MCP 서버 검증", assignee: "pipeline-checker" },
  { title: "H: 토큰 최적화 분석", assignee: "pipeline-checker" },
  { title: "I: 데이터 흐름 검증", assignee: "pipeline-checker" },
  { title: "J: 하네스 원칙 준수 검증", assignee: "structure-checker" },
  { title: "K: 엔트로피 탐지", assignee: "pipeline-checker" }
])
```

팀원 간 통신:
- 교차 영향 발견 시 상대 팀원에게 SendMessage로 즉시 공유
- 예: pipeline-checker가 훅 스크립트 미존재 발견 → structure-checker에게 공유 (에이전트 정의 참조 오류)

### Phase 4: 결과 종합 (팬인)

1. 양쪽 팀원의 검증 결과를 SendMessage로 수집
2. 심각도별 분류 (P0/P1/P2/P3)
3. 등급 산정
4. 최종 보고서 출력

### Phase 5: 보고서 저장 + 정리

1. 감사 보고서를 `docs/report/harness-audit/YYMMDD_harness-audit_report.md`에 저장 (YYMMDD = 감사 일자)
2. 팀원에게 종료 확인
3. 사용자에게 보고서 제시

## 검증 항목 요약 (11개 영역, 52개 체크)

상세 체크리스트는 각 에이전트 정의(structure-checker.md, pipeline-checker.md)에 포함.

| 영역 | 코드 | 체크 수 | 담당 |
|------|------|---------|------|
| 에이전트 정의 | A | 10 | structure-checker |
| 스킬 구조 | B | 6 | structure-checker |
| 규칙 자동로드 | C | 3 | structure-checker |
| CLAUDE.md 일관성 | D | 5 | structure-checker |
| 훅 체인 무결성 | E | 7 | pipeline-checker |
| 스크립트 검증 | F | 5 | pipeline-checker |
| MCP 서버 | G | 4 | pipeline-checker |
| 토큰 최적화 | H | 8 | pipeline-checker |
| 데이터 흐름 | I | 7 | pipeline-checker |
| **하네스 원칙 준수** | **J** | **3** | **structure-checker** |
| **엔트로피 탐지** | **K** | **3** | **pipeline-checker** |

### J: 하네스 원칙 준수 검증 (structure-checker)

`references/harness_rule.md`의 7원칙 대비 현재 하네스 상태를 점검한다.

| # | 체크 | 기준 |
|---|------|------|
| J-1 | CLAUDE.md 100줄 이내 | 원칙 1: 지도를 주지, 백과사전을 주지 마라 |
| J-2 | 생성-평가 분리 | 원칙 3: Engineer(생성) ↔ Code Reviewer/QA(평가)가 독립 에이전트로 분리 |
| J-3 | 불변량 코드 강제 | 원칙 2: 아키텍처 경계가 훅/린터로 강제되는지 (문서만으로 정의된 불변량 탐지) |

### K: 엔트로피 탐지 (pipeline-checker)

`references/harness_rule.md` 원칙 5, 6 대비 하네스 드리프트를 탐지한다.

| # | 체크 | 기준 |
|---|------|------|
| K-1 | 미참조 에이전트 탐지 | 원칙 6: CLAUDE.md·leader.md 어디에서도 참조하지 않는 에이전트 파일 |
| K-2 | 미참조 스킬 탐지 | 원칙 6: CLAUDE.md·에이전트 정의 어디에서도 참조하지 않는 스킬 |
| K-3 | 미실행 훅 스크립트 탐지 | 원칙 6: settings.json에 등록되지 않은 scripts/agent/*.sh 파일 |

## 심각도 판정 기준

| 등급 | 의미 | 예시 |
|------|------|------|
| P0 | 팀 실행 불가 또는 데이터 손실 위험 | 훅 스크립트 미존재, 에이전트 frontmatter 누락, MCP 불일치 |
| P1 | 팀 실행 가능하나 품질 저하 | 자동 종료 규칙 누락, 도메인 겹침, 스킬 참조 불일치 |
| P2 | 토큰 낭비 또는 유지보수 부담 | 스킬 500줄 초과, 중복 정보, description 개선 필요 |
| P3 | 베스트 프랙티스 권장 | effort 조정, 파일 크기 최적화 |

## 에러 핸들링

| 상황 | 전략 |
|------|------|
| 팀원 1명 실패/중지 | 해당 영역을 "검증 불가"로 표시, 나머지 결과로 보고서 생성 |
| 스크립트 실행 실패 | "실행 검증 불가" 표시, 존재 여부만 보고 |
| 환경변수 미설정 | "확인 불가" 표시, 보안상 값 노출 금지 |
| 팀원 간 충돌 발견 | 양쪽 결과를 병기 |

## 테스트 시나리오

### 정상 흐름
1. 사용자: "하네스 감사해줘"
2. audit-lead → TeamCreate(audit-team, [structure-checker, pipeline-checker])
3. TaskCreate × 9 (병렬)
4. 팀원 검증 수행 → 결과 보고
5. audit-lead → 종합 보고서 출력 (등급 + 항목별 PASS/WARN/FAIL)

### 에러 흐름
1. structure-checker가 스킬 참조 불일치 발견 (B-4 FAIL)
2. pipeline-checker가 훅 스크립트 미존재 발견 (E-4 FAIL)
3. 양쪽이 교차 발견 공유
4. audit-lead가 P0/P1 이슈를 보고서 상단에 강조
5. 수정 권고사항과 함께 보고서 제출
