import SwiftUI

struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var username = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundColor(.accentColor)
                .padding(.bottom, 10)

            Text("Вход")
                .font(.title)
                .fontWeight(.medium)

            VStack(spacing: 12) {
                TextField("Имя пользователя", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.username)

                SecureField("Пароль", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.password)
            }
            .frame(width: 200)

            Button(action: login) {
                Text("Войти")
                    .frame(width: 100)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(username.isEmpty || password.isEmpty)
            .help(username.isEmpty || password.isEmpty ? "Введите имя пользователя и пароль, чтобы войти" : "Войти")
            .keyboardShortcut(.defaultAction)
        }
        .padding()
        .frame(width: 300, height: 400)
    }

    private func login() {
        // Простая имитация входа. В реальном приложении здесь должна быть проверка.
        // Для данной задачи просто устанавливаем флаг.
        if !username.isEmpty && !password.isEmpty {
            isLoggedIn = true
        }
    }
}
