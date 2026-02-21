import SwiftUI
import Domain
import DesignSystem

/// Reusable chat UI for guided discovery stages.
///
/// Shows a scrollable list of conversation messages with user bubbles
/// on the right and agent bubbles on the left. Includes a text input
/// field and typing indicator.
struct ConversationView: View {
    @Bindable var viewModel: WorkshopFlowViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(
                            Array(viewModel.conversationMessages.enumerated()),
                            id: \.offset
                        ) { index, message in
                            MessageBubble(message: message)
                                .id(index)
                        }

                        if viewModel.isAgentTyping {
                            TypingIndicator()
                                .id("typing")
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.conversationMessages.count) {
                    withAnimation {
                        if viewModel.isAgentTyping {
                            proxy.scrollTo("typing", anchor: .bottom)
                        } else {
                            proxy.scrollTo(viewModel.conversationMessages.count - 1, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            HStack(spacing: 12) {
                TextField("Type a message...", text: $viewModel.userInput, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...4)
                    .voiceInput(text: $viewModel.userInput, voiceService: viewModel.voiceInputService)

                Button {
                    Task { await viewModel.sendMessage() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(
                            viewModel.userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? Color.gray
                                : CBTColors.accent
                        )
                }
                .disabled(viewModel.userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isAgentTyping)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {
    let message: ConversationMessage

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 60) }

            Text(LocalizedStringKey(message.content))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    isUser
                        ? Color.gray.opacity(0.15)
                        : CBTColors.accent.opacity(0.12)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .font(.body)
                .tint(CBTColors.accent)

            if !isUser { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Typing Indicator

private struct TypingIndicator: View {
    @State private var dotCount = 0

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(CBTColors.accent.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .opacity(dotCount == i ? 1.0 : 0.4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(CBTColors.accent.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Spacer()
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(400))
                withAnimation { dotCount = (dotCount + 1) % 3 }
            }
        }
    }
}

#Preview {
    ConversationView(viewModel: WorkshopFlowViewModel(
        agentService: MockAgentService(),
        protocolRepository: MockProtocolRepository()
    ))
}
