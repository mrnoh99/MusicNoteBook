# Music Notebook

Apple Pencil로 필기하는 5선 악보 노트 앱 (iPad 전용, SwiftUI + PencilKit)

## 주요 기능

- **5선 배경 노트**: 페이지 전체에 5선(오선) 악보 줄이 인쇄된 것처럼 표시됩니다.
- **Apple Pencil 필기**: PencilKit(`PKCanvasView`)을 사용해 펜슬로 자유롭게 필기/그리기가 가능하며, 시스템 도구 팔레트(펜, 형광펜, 지우개, 색상)를 그대로 사용합니다.
- **확대/축소**: 페이지를 손가락으로 핀치하여 확대·축소할 수 있습니다 (0.5x ~ 4x).
- **페이지 추가/삭제**: 툴바의 `+` 버튼으로 현재 페이지 뒤에 새 페이지를 추가하고, 좌우 화살표로 페이지를 이동할 수 있습니다.
- **자동 저장**: 모든 페이지의 필기 내용은 기기 내 문서 폴더(`notebook.json`)에 자동 저장되어 앱을 다시 열어도 유지됩니다.

## 프로젝트 구조

```
MusicNotebook/
├── MusicNotebook.xcodeproj/       # Xcode 프로젝트 (Xcode 26 파일 시스템 동기화 그룹 형식)
├── Config/
│   └── Info.plist
└── MusicNotebook/
    ├── MusicNotebookApp.swift     # 앱 진입점
    ├── ContentView.swift          # 메인 화면 (툴바, 페이지 내비게이션)
    ├── NotebookStore.swift        # 페이지 목록 상태 관리 및 저장/불러오기
    ├── NotebookPage.swift         # 페이지 데이터 모델 (PKDrawing 래핑)
    ├── StaffPaperView.swift       # 5선 배경을 그리는 UIView
    ├── DrawingCanvasView.swift    # 확대/축소 가능한 PencilKit 캔버스
    └── Assets.xcassets/
```

## 요구 사항

- Xcode 26 이상
- iPad, iOS 26 이상 (iPad 전용 앱, `TARGETED_DEVICE_FAMILY = 2`)
- Apple Pencil (권장)

## 실행 방법

1. 저장소를 clone 합니다.
2. `MusicNotebook.xcodeproj`를 Xcode로 엽니다.
3. iPad 시뮬레이터 또는 실기기를 선택 후 실행(⌘R)합니다.
