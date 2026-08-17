import SwiftUI

// MARK: - Ancient Medieval Fantasy Palette
extension Color {
    static let parchmentBg    = Color(red: 226/255, green: 201/255, blue: 161/255)
    static let parchmentCard  = Color(red: 242/255, green: 224/255, blue: 191/255)
    static let leatherDark   = Color(red: 45/255, green: 31/255, blue: 21/255)
    static let ironBorder     = Color(red: 90/255, green: 66/255, blue: 50/255)
    static let antiqueGold    = Color(red: 184/255, green: 134/255, blue: 11/255)
    static let crimsonRed     = Color(red: 144/255, green: 12/255, blue: 63/255)
}

// MARK: - Keyboard Extension Helper
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Main View
struct ContentView: View {
    @State private var candidates: [String] = []
    @State private var newName: String = ""
    
    // Group Storage State
    @AppStorage("savedGroupsData") private var savedGroupsData: Data = Data()
    @State private var savedGroups: [String: [String]] = [:]
    @State private var newGroupName: String = ""
    @State private var showSaveGroupAlert: Bool = false
    @State private var showClearConfirmation: Bool = false

    // State control
    @State private var isSpinning: Bool = false
    @State private var currentIndex: Int = 0
    @State private var winner: String? = nil

    private var isWinnerDetected: Bool {
        !isSpinning && winner != nil
    }

    private var statusText: String {
        if isSpinning {
            return "✦ 抽緊天選佳麗... ✦"
        } else if isWinnerDetected {
            return "⚔ 天選佳麗出現了！ ⚔"
        } else {
            return "✦ 你嘅天選佳麗會係？ ✦"
        }
    }

    private var statusColor: Color {
        isWinnerDetected ? .crimsonRed : (isSpinning ? .antiqueGold : .ironBorder)
    }

    private var buttonBackgroundColor: Color {
        candidates.count < 2 || isSpinning ? Color.ironBorder.opacity(0.5) : Color.crimsonRed
    }

    var body: some View {
        NavigationStack {
            ZStack {
                RealParchmentBackgroundView()

                VStack(spacing: 24) {
                    scrollDisplayView
                    castDieButtonView
                    ornamentalDivider
                    seekerListView
                }
                .padding(.top)
            }
            .contentShape(Rectangle())
            .onTapGesture { hideKeyboard() }
            .navigationTitle("抽出天選佳麗吧！")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .sensoryFeedback(.selection, trigger: currentIndex)
            .onAppear { loadGroupsFromStorage() }
            .alert("儲存佳麗組合", isPresented: $showSaveGroupAlert) {
                TextField("組合名稱", text: $newGroupName)
                Button("儲存", action: saveCurrentGroup)
                Button("取消", role: .cancel) { newGroupName = "" }
            } message: {
                Text("請輸入佳麗組合名稱：")
            }
        }
    }

    // MARK: - Extracted Subviews

    /// Central Parchment Scroll Display
    @ViewBuilder
    private var scrollDisplayView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.parchmentCard.opacity(0.85))
                .shadow(color: Color.leatherDark.opacity(0.25), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(statusColor, lineWidth: isWinnerDetected ? 2.5 : 1.5)
                )

            RoundedRectangle(cornerRadius: 8)
                .stroke(statusColor.opacity(0.4), lineWidth: 1)
                .padding(6)

            VStack(spacing: 12) {
                Text(statusText)
                    .font(.system(size: 13, weight: .bold, design: .serif))
                    .foregroundColor(statusColor)

                Text(candidates.isEmpty ? "尚無候選佳麗" : candidates[currentIndex])
                    .font(.system(size: 34, weight: .heavy, design: .serif))
                    .foregroundColor(.leatherDark)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .padding()
        }
        .frame(height: 160)
        .padding(.horizontal)
    }

    /// Medieval Wax Seal / Cast Die Button
    @ViewBuilder
    private var castDieButtonView: some View {
        Button(action: startLuckyDraw) {
            HStack(spacing: 10) {
                Image(systemName: isSpinning ? "hourglass" : "dice.fill")
                    .font(.system(size: 18, weight: .bold))
                    .rotationEffect(.degrees(isSpinning ? 360 : 0))
                    .animation(
                        isSpinning
                            ? .linear(duration: 0.8).repeatForever(autoreverses: false)
                            : .default,
                        value: isSpinning
                    )
                
                Text(isSpinning ? "幫緊你..." : "Let's Roll!")
                    .font(.system(size: 17, weight: .bold, design: .serif))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(buttonBackgroundColor)
            .foregroundColor(.parchmentCard)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.antiqueGold.opacity(0.6), lineWidth: 1)
            )
            .shadow(color: Color.leatherDark.opacity(0.3), radius: 4, x: 0, y: 3)
        }
        .disabled(candidates.count < 2 || isSpinning)
        .padding(.horizontal)
    }

    /// Ornamental Line Divider
    @ViewBuilder
    private var ornamentalDivider: some View {
        HStack {
            Rectangle().frame(height: 1).foregroundColor(.ironBorder.opacity(0.4))
            Text("✤")
                .font(.system(size: 14, design: .serif))
                .foregroundColor(.ironBorder)
            Rectangle().frame(height: 1).foregroundColor(.ironBorder.opacity(0.4))
        }
        .padding(.horizontal)
    }

    /// Seeker Roster View
    @ViewBuilder
    private var seekerListView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Text("候選佳麗 [\(candidates.count)]")
                    .font(.system(size: 13, weight: .bold, design: .serif))
                    .foregroundColor(.leatherDark.opacity(0.8))

                Spacer()

                if !candidates.isEmpty {
                    clearAllButton
                }

                groupMenu
            }

            inputNameRow

            candidateScrollView
        }
        .padding(.horizontal)
        .confirmationDialog("確定要清空所有候選佳麗嗎？", isPresented: $showClearConfirmation, titleVisibility: .visible) {
            Button("清空所有候選佳麗", role: .destructive) { clearAllCandidates() }
            Button("不了", role: .cancel) {}
        }
    }

    /// Clear All Button
    @ViewBuilder
    private var clearAllButton: some View {
        Button(action: { showClearConfirmation = true }) {
            HStack(spacing: 4) {
                Text("🧹")
                    .font(.system(size: 13))
                Text("一鍵清空")
                    .font(.system(size: 12, weight: .bold, design: .serif))
            }
            .foregroundColor(.crimsonRed)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color.parchmentCard)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.crimsonRed.opacity(0.5), lineWidth: 1)
            )
        }
        .disabled(isSpinning)
    }

    /// Text Field Input Row
    @ViewBuilder
    private var inputNameRow: some View {
        HStack(spacing: 12) {
            TextField("", text: $newName, prompt: Text("報上名來...").foregroundColor(.leatherDark.opacity(0.4)))
                .font(.system(size: 16, design: .serif))
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.parchmentCard.opacity(0.85))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.ironBorder.opacity(0.5), lineWidth: 1)
                )
                .foregroundColor(.leatherDark)
                .disabled(isSpinning)
                .submitLabel(.done)
                .onSubmit {
                    addCandidate()
                    hideKeyboard()
                }

            CrystalBallButton(
                isDisabled: newName.trimmingCharacters(in: .whitespaces).isEmpty || isSpinning,
                action: addCandidate
            )
        }
    }

    /// Scroll View Roster
    @ViewBuilder
    private var candidateScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                if candidates.isEmpty {
                    Text("無人啊師兄...")
                        .font(.system(size: 14, design: .serif))
                        .foregroundColor(.leatherDark.opacity(0.5))
                        .padding(.vertical, 20)
                } else {
                    ForEach(Array(candidates.enumerated()), id: \.element) { index, name in
                        CandidateRowView(
                            name: name,
                            isSpinning: isSpinning,
                            onUpdate: { newText in updateCandidate(at: index, newName: newText) },
                            onDelete: { deleteCandidate(at: index) }
                        )
                    }
                }
            }
            .padding(2)
        }
        .scrollIndicators(.visible)
        .tint(.ironBorder)
    }

    /// Menu Subview
    @ViewBuilder
    private var groupMenu: some View {
        Menu {
            Button(action: { showSaveGroupAlert = true }) {
                Label("儲存目前佳麗組合...", systemImage: "square.and.arrow.down")
            }
            .disabled(candidates.isEmpty || isSpinning)

            if !savedGroups.isEmpty {
                Divider()

                Section("載入佳麗組合") {
                    ForEach(Array(savedGroups.keys.sorted()), id: \.self) { groupName in
                        Button(action: { loadGroup(named: groupName) }) {
                            Label("\(groupName) (\(savedGroups[groupName]?.count ?? 0)人)", systemImage: "folder")
                        }
                    }
                }

                Section("刪除佳麗組合") {
                    ForEach(Array(savedGroups.keys.sorted()), id: \.self) { groupName in
                        Button(role: .destructive, action: { deleteGroup(named: groupName) }) {
                            Label("刪除 \(groupName)", systemImage: "trash")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 12))
                Text("佳麗組合")
                    .font(.system(size: 12, weight: .bold, design: .serif))
            }
            .foregroundColor(.antiqueGold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.leatherDark)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.antiqueGold.opacity(0.5), lineWidth: 1)
            )
        }
        .disabled(isSpinning)
    }

    // MARK: - Logic Methods
    private func addCandidate() {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !candidates.contains(trimmed) {
            candidates.append(trimmed)
            newName = ""
        }
    }

    private func updateCandidate(at index: Int, newName: String) {
        guard index < candidates.count else { return }
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty {
            candidates[index] = trimmed
        }
    }

    private func deleteCandidate(at index: Int) {
        guard index < candidates.count else { return }
        candidates.remove(at: index)
        if currentIndex >= candidates.count {
            currentIndex = max(0, candidates.count - 1)
        }
    }

    private func clearAllCandidates() {
        candidates.removeAll()
        currentIndex = 0
        winner = nil
    }

    private func startLuckyDraw() {
        guard candidates.count >= 2 else { return }
        
        isSpinning = true
        winner = nil
        
        let winningIndex = Int.random(in: 0..<candidates.count)
        let totalSteps = 25 + winningIndex
        var currentStep = 0
        var delay = 0.05

        func stepAnimation() {
            guard currentStep < totalSteps else {
                isSpinning = false
                winner = candidates[winningIndex]
                currentIndex = winningIndex
                return
            }

            currentIndex = (currentIndex + 1) % candidates.count
            currentStep += 1
            
            if currentStep > totalSteps - 10 {
                delay += 0.04
            } else if currentStep > totalSteps - 5 {
                delay += 0.08
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                stepAnimation()
            }
        }

        stepAnimation()
    }

    // MARK: - Group Persistence Storage Logic
    private func saveCurrentGroup() {
        let trimmed = newGroupName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty && !candidates.isEmpty else { return }
        
        savedGroups[trimmed] = candidates
        persistGroups()
        newGroupName = ""
    }

    private func loadGroup(named name: String) {
        if let loaded = savedGroups[name] {
            candidates = loaded
            currentIndex = 0
            winner = nil
        }
    }

    private func deleteGroup(named name: String) {
        savedGroups.removeValue(forKey: name)
        persistGroups()
    }

    private func persistGroups() {
        if let encoded = try? JSONEncoder().encode(savedGroups) {
            savedGroupsData = encoded
        }
    }

    private func loadGroupsFromStorage() {
        if let decoded = try? JSONDecoder().decode([String: [String]].self, from: savedGroupsData) {
            savedGroups = decoded
        }
    }
}

// MARK: - Candidate Row Subview with Edit Support
struct CandidateRowView: View {
    let name: String
    let isSpinning: Bool
    let onUpdate: (String) -> Void
    let onDelete: () -> Void

    @State private var isEditing: Bool = false
    @State private var editText: String = ""

    var body: some View {
        HStack(spacing: 8) {
            Text("📜")
                .font(.caption)

            if isEditing {
                TextField("修改名稱...", text: $editText)
                    .font(.system(size: 15, design: .serif))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.parchmentBg)
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.antiqueGold, lineWidth: 1)
                    )
                    .foregroundColor(.leatherDark)
                    .submitLabel(.done)
                    .onSubmit { saveEdit() }
            } else {
                Text(name)
                    .font(.system(size: 16, design: .serif))
                    .foregroundColor(.leatherDark)
            }

            Spacer()

            HStack(spacing: 6) {
                // Edit Button
                Button(action: {
                    if isEditing {
                        saveEdit()
                    } else {
                        editText = name
                        isEditing = true
                    }
                }) {
                    Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isEditing ? .green : .antiqueGold)
                        .padding(6)
                        .background(Color.parchmentBg.opacity(0.6))
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.ironBorder.opacity(0.3), lineWidth: 1)
                        )
                }
                .disabled(isSpinning)

                // Delete Button
                Button(action: onDelete) {
                    Image(systemName: "xmark.seal.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.crimsonRed.opacity(0.85))
                        .padding(6)
                        .background(Color.parchmentBg.opacity(0.6))
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.ironBorder.opacity(0.3), lineWidth: 1)
                        )
                }
                .disabled(isSpinning)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.parchmentCard.opacity(0.8))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.ironBorder.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: Color.leatherDark.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    private func saveEdit() {
        onUpdate(editText)
        isEditing = false
    }
}

// MARK: - Extracted Standalone Views

/// Mystic Add Button Extracted to separate struct
struct CrystalBallButton: View {
    let isDisabled: Bool
    let action: () -> Void

    private var gradientColors: [Color] {
        isDisabled
            ? [Color.ironBorder, Color.leatherDark]
            : [Color(red: 142/255, green: 45/255, blue: 226/255), Color(red: 74/255, green: 0/255, blue: 224/255)]
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .stroke(Color.antiqueGold, lineWidth: 1.5)
                    .frame(width: 44, height: 44)

                Circle()
                    .fill(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 38, height: 38)

                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isDisabled ? .gray : .parchmentCard)
            }
        }
        .disabled(isDisabled)
    }
}

/// Real Image Texture Background Component
struct RealParchmentBackgroundView: View {
    var body: some View {
        ZStack {
            Color(red: 226/255, green: 201/255, blue: 161/255)
            
            Image("parchment_texture")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
