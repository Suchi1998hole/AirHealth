import SwiftUI

// MARK: - Enums

enum OnboardingGoal: String {
    case recover
    case wellness
}

enum SexOption: String, CaseIterable {
    case man = "man"
    case woman = "woman"
    case preferNotToSay = "prefer_not_to_say"
}

enum OnboardingStep: Int, CaseIterable {
    case goal = 0
    case demographics = 1
    case bodyMetrics = 2
}

enum WeightUnit {
    case kg, lb
}

enum HeightUnit {
    case cm, ft
}

// MARK: - View

struct OnboardingView: View {

    // MARK: - Flow
    @State private var step: OnboardingStep = .goal

    // MARK: - Step 1
    @State private var selectedGoal: OnboardingGoal?

    // MARK: - Step 2
    @State private var selectedSex: SexOption?
    @State private var age: Int = 25

    // MARK: - Step 3 (canonical units)
    @State private var weightKg: Double = 70
    @State private var heightCm: Double = 170

    @State private var weightUnit: WeightUnit = .kg
    @State private var heightUnit: HeightUnit = .cm

    @EnvironmentObject var authVM: AuthViewModel

    // MARK: - Body

    var body: some View {
        VStack {

            switch step {
            case .goal:
                goalStep
            case .demographics:
                demographicsStep
            case .bodyMetrics:
                bodyMetricsStep
            }

            onboardingFooter
        }
        .padding()
    }

    // MARK: - STEP 1: Goal

    private var goalStep: some View {
        VStack(spacing: 24) {

            Spacer()
            header

            VStack(spacing: 16) {
                GoalCard(
                    title: "Recover",
                    subtitle: "Heal, reduce pain, and rebuild strength",
                    isSelected: selectedGoal == .recover
                ) {
                    selectedGoal = .recover
                }

                GoalCard(
                    title: "Wellness",
                    subtitle: "Stay active, fit, and prevent injuries",
                    isSelected: selectedGoal == .wellness
                ) {
                    selectedGoal = .wellness
                }
            }

            Spacer()

            Button("Next") {
                step = .demographics
            }
            .buttonStyle(
                PrimaryButtonStyle(enabled: selectedGoal != nil)
            )
            .disabled(selectedGoal == nil)
        }
    }

    // MARK: - STEP 2: Sex + Age

    private var demographicsStep: some View {
        VStack(spacing: 24) {

            Spacer()
            header

            VStack(alignment: .leading, spacing: 12) {
                Text("Sex")
                    .font(.headline)

                ForEach(SexOption.allCases, id: \.self) { option in
                    Button {
                        selectedSex = option
                    } label: {
                        Text(option.rawValue.capitalized.replacingOccurrences(of: "_", with: " "))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        selectedSex == option
                                        ? Color.black
                                        : Color(.systemGray6)
                                    )
                            )
                            .foregroundColor(
                                selectedSex == option ? .white : .black
                            )
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Age")
                    .font(.headline)

                Picker("Age", selection: $age) {
                    ForEach(18...80, id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 120)
            }

            Spacer()

            Button("Next") {
                step = .bodyMetrics
            }
            .buttonStyle(
                PrimaryButtonStyle(enabled: true)
            )
        }
    }

    // MARK: - STEP 3: Weight & Height

    private var bodyMetricsStep: some View {
        VStack(spacing: 24) {

            Spacer()
            header

            // Weight
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Weight")
                        .font(.headline)

                    Spacer()

                    unitToggle(
                        left: "KG",
                        right: "LB",
                        isLeftSelected: weightUnit == .kg
                    ) {
                        weightUnit = weightUnit == .kg ? .lb : .kg
                    }
                }

                Text(displayWeight)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)

                Slider(
                    value: $weightKg,
                    in: 30...200,
                    step: 1
                )
            }

            // Height
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Height")
                        .font(.headline)

                    Spacer()

                    unitToggle(
                        left: "CM",
                        right: "FT",
                        isLeftSelected: heightUnit == .cm
                    ) {
                        heightUnit = heightUnit == .cm ? .ft : .cm
                    }
                }

                Text(displayHeight)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)

                Slider(
                    value: $heightCm,
                    in: 120...220,
                    step: 1
                )
            }

            Spacer()

            Button("Finish") {
                completeOnboarding()
            }
            .buttonStyle(
                PrimaryButtonStyle(enabled: true)
            )
        }
    }

    // MARK: - Footer (Progress + Skip)

    private var onboardingFooter: some View {
        VStack(spacing: 12) {

            HStack(spacing: 8) {
                ForEach(OnboardingStep.allCases, id: \.self) { s in
                    Circle()
                        .fill(s == step ? Color.black : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }

            Button("Skip it") {
                completeOnboarding()
            }
            .foregroundColor(.gray)
        }
        .padding(.bottom, 8)
    }

    // MARK: - Display Helpers

    private var displayWeight: String {
        switch weightUnit {
        case .kg:
            return "\(Int(weightKg)) kg"
        case .lb:
            return "\(Int(weightKg * 2.20462)) lb"
        }
    }

    private var displayHeight: String {
        switch heightUnit {
        case .cm:
            return "\(Int(heightCm)) cm"
        case .ft:
            let inches = heightCm / 2.54
            let feet = Int(inches / 12)
            let remainder = Int(inches.truncatingRemainder(dividingBy: 12))
            return "\(feet)′ \(remainder)″"
        }
    }

    // MARK: - Shared UI

    private var header: some View {
        VStack(spacing: 8) {
            Text("AIR")
                .font(.caption)
                .foregroundColor(.gray)

            Text("Hi, this is Asky, let's")
                .font(.headline)

            Text("Learn more about you")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .multilineTextAlignment(.center)
    }

    private func unitToggle(
        left: String,
        right: String,
        isLeftSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 0) {
            Text(left)
                .frame(width: 44, height: 28)
                .background(isLeftSelected ? Color.black : Color(.systemGray5))
                .foregroundColor(isLeftSelected ? .white : .black)

            Text(right)
                .frame(width: 44, height: 28)
                .background(!isLeftSelected ? Color.black : Color(.systemGray5))
                .foregroundColor(!isLeftSelected ? .white : .black)
        }
        .cornerRadius(6)
        .onTapGesture { action() }
    }

    // MARK: - Completion (BACKEND + LOCAL)

    private func completeOnboarding() {
        guard let userId = AuthService.currentUserId else { return }

        let payload: [String: Any] = [
            "userId": userId,
            "goal": selectedGoal?.rawValue ?? "",
            "sex": selectedSex?.rawValue ?? "",
            "age": age,
            "heightCm": Int(heightCm),
            "weightKg": Int(weightKg)
        ]

        AuthService.updateOnboarding(payload: payload) {
            UserSession.hasCompletedOnboarding = true
            authVM.needsOnboarding = false
        }
    }
}
