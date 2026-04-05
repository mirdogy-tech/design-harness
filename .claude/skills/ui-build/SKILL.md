---
name: ui-build
description: |
  UI 컴포넌트 코드 생성. 디자인 명세를 React, Vue, HTML/CSS 등 실제 코드로 변환한다.
  디자인 토큰 구현, 컴포넌트 라이브러리 구축, Figma-to-Code 변환 수행.
  'UI 컴포넌트', '컴포넌트 만들기', '컴포넌트 코드', '디자인 토큰 구현', 
  '디자인 시스템 코드', 'Figma to Code', '버튼 컴포넌트', '카드 컴포넌트',
  'CSS 구현', 'Storybook', '컴포넌트 라이브러리' 요청 시 반드시 이 스킬을 사용할 것.
  디자인 파일이나 ��세서에서 코드를 생성하는 모든 작업에 이 스킬을 사용.
  디자인 토큰 '구현/코드화', Figma-to-Code '변환', 컴포넌트 '코드 생성' 등 구현 단계에 특화.
  디자인 토큰 '정의/설계', 와이어프레임, 비주얼 디자인 등 설계 단계는 ui-design 스킬을 사용�� 것.
---

# UI 컴포넌트 빌드

디자인 명세를 실제 작동하는 UI 컴포넌트 코드로 변환한다.

## 빌드 워크플로우

### 1단계: 프로젝트 스택 파악
구현 전에 프로젝트의 기술 스택을 확인한다:
1. `package.json` — 프레임워크, 스타일링 라이브러리
2. 기존 컴포넌트 구조 — 디렉토리 패턴, 네이밍 컨벤션
3. 기존 디자인 토큰 — CSS 변수, theme 파일
4. 린터/포매터 설정 — ESLint, Prettier 규칙

스택 미지정 시 기본: React + TypeScript + CSS Modules.

### 2단계: 디자인 토큰 구현

디자인 토큰을 코드로 변환한다. ui-designer로부터 받은 토큰 정의를 사용.

#### CSS Custom Properties (기본)
```css
:root {
  /* Colors */
  --color-primary-500: #2196F3;
  --color-neutral-900: #212121;
  
  /* Typography */
  --font-size-body: 16px;
  --line-height-body: 1.5;
  
  /* Spacing */
  --space-1: 4px;
  --space-2: 8px;
  --space-4: 16px;
  --space-6: 24px;
}
```

#### Tailwind Config (Tailwind 프로젝트)
```js
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: { 500: '#2196F3' },
      },
      spacing: {
        '1': '4px',
        '2': '8px',
      },
    },
  },
}
```

### 3단계: 컴포넌트 구현

#### 컴포넌트 구조 원칙
- **Props 인터페이스 먼저 정의** — 디자인 명세의 variant, size, state를 Props로 매핑
- **합성(Composition) 패턴** — 큰 컴포넌트는 작은 서브 컴포넌트로 합성
- **시맨틱 HTML** — `<button>`, `<nav>`, `<main>` 등 의미에 맞는 태그 사용
- **접근성 내장** — ARIA 속성, 키보드 핸들링, 포커스 관리

#### React + TypeScript 패턴
```tsx
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  children: React.ReactNode;
  onClick?: () => void;
}

export function Button({ 
  variant = 'primary', 
  size = 'md', 
  disabled = false,
  children, 
  onClick 
}: ButtonProps) {
  return (
    <button
      className={`btn btn--${variant} btn--${size}`}
      disabled={disabled}
      onClick={onClick}
    >
      {children}
    </button>
  );
}
```

#### 스타일링 패턴 선택
| 프로젝트 스택 | 스타일링 방식 |
|-------------|-------------|
| CSS Modules | `.module.css` + `styles.className` |
| Tailwind | 유틸리티 클래스 직접 적용 |
| Styled Components | `styled.tag` 래퍼 |
| Vanilla CSS | BEM 네이밍 (`.block__element--modifier`) |

### 4단계: 반응형 구현

```css
/* Mobile First */
.container {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

/* Tablet */
@media (min-width: 768px) {
  .container {
    flex-direction: row;
    flex-wrap: wrap;
  }
  .container > * {
    flex: 0 0 calc(50% - var(--space-4));
  }
}

/* Desktop */
@media (min-width: 1024px) {
  .container > * {
    flex: 0 0 calc(33.33% - var(--space-4));
  }
}
```

### 5단계: 인터랙션 & 상태

#### 상태 관리 패턴
- **단순 토글**: `useState` (모달, 드롭다운)
- **폼 상태**: `useForm` 또는 Controlled Input
- **애니메이션**: CSS Transition 우선, 복잡한 경우 Framer Motion
- **비동기 상태**: loading / success / error 3-상태 패턴

#### 접근성 구현
```tsx
// 키보드 네비게이션 예시
<div
  role="listbox"
  aria-label="옵션 선택"
  onKeyDown={(e) => {
    if (e.key === 'ArrowDown') focusNext();
    if (e.key === 'ArrowUp') focusPrev();
    if (e.key === 'Enter') selectCurrent();
  }}
>
```

### 6단계: Figma → Code 변환

Figma 디자인이 제공되면:
1. `get_design_context`로 디자인 컨텍스트 추출
2. Code Connect 매핑이 있으면 기존 컴포넌트 코드와 연결
3. 없으면 디자인 속성(색상, 폰트, 스페이싱)을 프로젝트 토큰으로 매핑
4. 스크린샷 참고하며 레이아웃 충실히 재현

## 산출물

| 유형 | 파일 |
|------|------|
| 컴포넌트 코드 | `src/components/{Name}/{Name}.tsx` |
| 스타일 | `src/components/{Name}/{Name}.module.css` |
| 타입 정의 | `src/components/{Name}/{Name}.types.ts` (복잡한 경우) |
| 디자인 토큰 | `src/styles/tokens.css` 또는 `theme.ts` |
| 스토리 (선택) | `src/components/{Name}/{Name}.stories.tsx` |
