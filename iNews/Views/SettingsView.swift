//
//  SettingsView.swift
//  iNews
//
//  Created by Oli Hinton on 20/07/2026.
//

import SwiftUI

struct SettingsView: View {
    @Environment(NotificationsViewModel.self) private var viewModel
    @State private var sectionVisible = false
    @State private var aboutVisible = false

    var body: some View {
        @Bindable var viewModel = viewModel
        List {
            Section {
                HStack {
                    Image(systemName: "newspaper.fill")
                        .foregroundStyle(.blue)
                        .frame(width: 28)
                    Text("Daily News Updates")
                    Spacer()
                    Toggle("", isOn: $viewModel.notificationsEnabled)
                        .onChange(of: viewModel.notificationsEnabled) { _, enabled in
                            Task { await viewModel.handleToggle(enabled) }
                        }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Daily News notifications")
                .accessibilityHint(viewModel.notificationsEnabled ? "Tap to disable daily notifications" : "Tap to enable daily notifications")

                if viewModel.notificationsEnabled {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundStyle(.orange)
                            .frame(width: 28)
                        DatePicker(
                            "Notification Time",
                            selection: $viewModel.selectedTime,
                            displayedComponents: .hourAndMinute
                        )
                        .onChange(of: viewModel.selectedTime) { _, newTime in
                            viewModel.rescheduleNotifications(at: newTime)
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            } header: {
                Text("Notifications")
            } footer: {
                Text("Receive a daily reminder to catch up on the latest news.")
            }
            .opacity(sectionVisible ? 1 : 0)
            .offset(y: sectionVisible ? 0 : 20)

            Section {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.gray)
                        .frame(width: 28)
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("About")
            }
            .opacity(aboutVisible ? 1 : 0)
            .offset(y: aboutVisible ? 0 : 20)
        }
        .navigationTitle("Settings")
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.notificationsEnabled)
        .alert("Notifications Disabled", isPresented: $viewModel.showingPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable notifications in Settings to receive your daily updates.")
        }
        .task {
            await viewModel.refreshAuthorizationStatus()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                sectionVisible = true
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                aboutVisible = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}


