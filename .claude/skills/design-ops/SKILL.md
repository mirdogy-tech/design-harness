---
name: design-ops
description: |
  프로덕트 디자인 팀 오케스트레이터. UX 리서치, A/B 테스트, 딥 리서치, UI 설계, UI 컴포넌트 제작을 
  팀으로 수행한다. 프로덕트 디자인 관련 복합 요청, 여러 디자인 단계를 아우르는 작업, 
  '디자인 팀', '디자인 프로젝트', '리서치부터 구현까지', '전체 디자인 프로세스' 요청 시 
  반드시 이 스킬을 사용할 것. 단일 작업(와이어프���임만, 리서치만)도 팀 협업이 필요하면 이 스킬을 사용.
  2개 이상의 서로 다��� 스킬 영역(리서치+디자인, 디자인+구현 등)에 걸치는 요청은 이 스킬이 항상 우선한다.
  단일 영역 단독 작업은 해당 개별 스킬(ux-research, deep-research, ui-design, ui-build)을 직접 사용할 것.
---

# 프로덕트 디자인 팀 오케스트레이터

프로덕트 디자인 요청을 전문 에이전트 팀으로 처리한다.

## 실행 모드: 에이전트 팀

## 에이전트 구성

| 팀원 | 역할 | 전문 영역 | 스킬 |
|------|------|----------|------|
| design-lead | 리더: 요구사항 분석 + 작업 분배 + 결과 종합 | 전체 조율 | — |
| ux-researcher | UX 리서치 + A/B 테스트 | 사용자 조사, 가설 검증 | ux-research |
| deep-researcher | 딥 리서치 | 웹·학술·커뮤니티 교차 검증 | deep-research |
| ui-designer | UI 설계 + 비주얼 디자인 | 와이어프레임, UX 플로우, 디자인 시스템 | ui-design |
| ui-builder | UI 컴포넌트 구현 | 코드 생성, 디자인 토큰 구현 | ui-build |

## 워크플로우

### Phase 1: 요구사항 분석
1. 사용자 요청에서 작업 유형 분류
2. 필요한 팀원 식별 (모든 요청에 전원 투입하지 않는다)
3. 의존 관계 파악 (리서치 → 디자인 → 구현)

### Phase 2: 팀 구성

```
TeamCreate(
  team_name: "design-team",
  members: [
    { name: "ux-researcher", agent_type: "ux-researcher", model: "opus",
      prompt: "UX 리서치 및 A/B 테스트를 수행하라. ux-research 스킬을 참조하여 작업한다." },
    { name: "deep-researcher", agent_type: "deep-researcher", model: "opus",
      prompt: "딥 리서치를 수행하라. deep-research 스킬을 참조하여 다중 소스 교차 검증 보고서를 작성한다." },
    { name: "ui-designer", agent_type: "ui-designer", model: "opus",
      prompt: "UI 설계를 수행하라. ui-design 스킬을 참조하여 와이어프레임, UX 플로우, 비주얼 디자인을 생성한다." },
    { name: "ui-builder", agent_type: "ui-builder", model: "opus",
      prompt: "UI 컴포넌트를 구현하라. ui-build 스킬을 참조하여 디자인 명세를 코드로 변환한다." }
  ]
)
```

**필요한 팀원만 투입한다:**
- 리서치만 필요 → ux-researcher + deep-researcher
- 디자인만 필요 → ui-designer (+ ux-researcher for 검증)
- 구현만 필요 → ui-builder (+ ui-designer for 명세)
- 전체 프로세스 → 전원

### Phase 3: 작업 실행

#### 패턴 A: 전체 프로세스 (리서치 → 디자인 → 구현)

**Step 1 — 리서치 (병렬 팬아웃)**
```
TaskCreate(tasks: [
  { title: "UX 리서치: {주제}", assignee: "ux-researcher" },
  { title: "딥 리서치: {주제}", assignee: "deep-researcher" }
])
```
ux-researcher와 deep-researcher가 병렬로 리서치 수행.
교차 발견 시 SendMessage로 상호 공유.

**Step 2 — 디자인 (리서치 결과 반영)**
리서치 완료 후 결과를 ui-designer에게 전달:
```
TaskCreate(tasks: [
  { title: "UI 설계: {주제}", assignee: "ui-designer",
    depends_on: ["UX 리서치", "딥 리서치"] }
])
```
ui-designer는 리서치 인사이트를 기반으로 설계.
ux-researcher에게 UX 플로우 검증 요청 (SendMessage).

**Step 3 — 구현 (디자인 명세 기반)**
```
TaskCreate(tasks: [
  { title: "UI 컴포넌트 구현: {주제}", assignee: "ui-builder",
    depends_on: ["UI 설계"] }
])
```
ui-builder는 ui-designer의 명세를 받아 코드 생성.
구현 제약사항은 ui-designer에게 피드백 (SendMessage).

#### 패턴 B: 리서치 중심
ux-researcher + deep-researcher만 투입. 결과를 종합 보고서로 제출.

#### 패턴 C: 디자인 중심
ui-designer 중심, ux-researcher가 검증 지원. 와이어프레임·플로우·비주얼 산출.

#### 패턴 D: 구현 중심
ui-builder 중심, ui-designer가 명세 지원. 컴포넌트 코드 산출.

### Phase 4: 결과 종합
1. 각 팀원의 산출물을 수집
2. 일관성 검토 (리서치 인사이트가 디자인에 반영되었는지, 디자인 명세가 코드에 반영되었는지)
3. 종합 보고서 또는 산출물 패키지 구성
4. 사용자에게 제시

### Phase 5: 산출물 저장 및 정리
- 중간 산출물: `_workspace/{phase}_{agent}_{artifact}.{ext}`
- 최종 산출물: 사용자 지정 경로 또는 프로젝트 루트

## 데이터 전달 프로토콜

| 경로 | 전달 방식 | 내용 |
|------|----------|------|
| ux-researcher ↔ deep-researcher | SendMessage | 교차 분석 데이터 |
| ux-researcher → ui-designer | 파일 + SendMessage | 리서치 보고서 + 핵심 인사이트 요약 |
| deep-researcher → ui-designer | 파일 + SendMessage | 딥 리서치 보고서 + 트렌드·벤치마크 |
| ui-designer → ui-builder | 파일 + SendMessage | 디자인 명세 + 토큰 정의 |
| ui-designer → ux-researcher | SendMessage | UX 플로우 검증 요청 |
| ui-builder → ui-designer | SendMessage | 구현 제약사항 피드백 |

## 에러 핸들링

| 상황 | 전략 |
|------|------|
| 팀원 1명 실패 | 해당 영역 "미완료" 표시, 나머지 결과로 산출물 구성 |
| 리서치 결과 상충 | 양쪽 결과를 병기, 사용자에게 판단 요청 |
| 디자인-구현 불일치 | ui-designer와 ui-builder 간 SendMessage로 조율, 해결 불가 시 양쪽 제시 |
| Figma 접근 불가 | 텍스트 기반 대안으로 전환 |

## 테스트 시나리오

### 정상 흐름
1. 사용자: "신규 온보딩 화면을 설계해줘. 먼저 경쟁사를 조사하고, 와이어프레임과 컴포넌트까지 만들어줘."
2. design-lead → 전체 프로세스 패턴 선택
3. TeamCreate(design-team, [ux-researcher, deep-researcher, ui-designer, ui-builder])
4. Step 1: ux-researcher(온보딩 UX 리서치) + deep-researcher(경쟁사 온보딩 분석) 병렬 실행
5. Step 2: ui-designer가 리서치 결과 기반으로 와이어프레임 + UX 플로우 설계
6. Step 3: ui-builder가 디자인 명세 기반으로 온보딩 컴포넌트 코드 생성
7. design-lead → 종합 산출물 제시

### 에러 흐름
1. deep-researcher가 웹 검색에서 결과 부족 (키워드 확장 후 재시도)
2. ui-designer가 와이어프레임 생성 중 ux-researcher 리서치 미완료 → 일반 UX 원칙 기반 초안, 리서치 후 수정
3. ui-builder가 구현 중 디자인 명세 누락 발견 → ui-designer에게 SendMessage로 보완 요청
4. design-lead가 누락/지연 사항을 종합 보고서에 명시
