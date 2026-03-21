import SwiftUI

struct MemoZoneView: View {
    // Phase 3에서 Supabase 연동 예정, 지금은 목업 데이터
    @State private var memos: [MemoItem] = MemoItem.mockData
    @State private var searchText = ""
    @State private var showNewMemo = false

    private var filteredMemos: [MemoItem] {
        if searchText.isEmpty { return memos }
        return memos.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 검색바
            searchBar

            // Zone Label
            HStack {
                Text("MEMOS")
                    .font(.system(size: AppTheme.zoneLabelSize, weight: AppTheme.zoneLabelWeight))
                    .foregroundColor(AppTheme.zoneLabel)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)

            // 메모 리스트
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(filteredMemos) { memo in
                        MemoRowView(memo: memo)
                    }
                }
                .padding(.horizontal, 8)
            }

            // 하단바
            bottomBar
        }
        .background(AppTheme.memoZoneBg)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textTertiary)

            TextField("메모 검색...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textPrimary)

            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppTheme.inputBg)
        .cornerRadius(AppTheme.cornerRadius)
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            Button(action: { showNewMemo = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 11))
                    Text("새 메모")
                        .font(.system(size: 12))
                }
                .foregroundColor(AppTheme.accent)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("\(filteredMemos.count)개 메모")
                .font(.system(size: 11))
                .foregroundColor(AppTheme.textTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppTheme.border.opacity(0.5))
    }
}

// MARK: - Mock Data (Phase 3에서 제거)

struct MemoItem: Identifiable {
    let id: UUID
    let title: String
    let content: String

    static let mockData: [MemoItem] = [
        .init(id: UUID(), title: "서버 배포 체크리스트", content: "1. 테스트 통과 확인\n2. 환경변수 점검\n3. DB 마이그레이션\n4. 배포 후 헬스체크"),
        .init(id: UUID(), title: "API 엔드포인트 정리", content: "POST /auth/login\nGET /users/me\nGET /memos\nPOST /memos"),
        .init(id: UUID(), title: "디자인 시스템 컬러", content: "Primary: #19202E\nSecondary: #1E2535\nAccent: #4A9EFF"),
        .init(id: UUID(), title: "회의 노트 - 3/20", content: "- Phase 2 UI 확정\n- 다크 테마 적용\n- 글로벌 단축키 Cmd+Shift+N"),
    ]
}
