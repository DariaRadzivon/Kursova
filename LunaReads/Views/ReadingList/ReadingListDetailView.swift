import SwiftUI
import AVFoundation
import Photos
import UIKit


struct ReadingListDetailView: View {
    let itemID: String

    @EnvironmentObject private var viewModel: ReadingListViewModel

    @State private var newNoteText: String = ""
    @State private var editingNote: ReadingNote?
    @State private var editingText: String = ""

    @State private var showPhotoSourceDialog = false
    @State private var showCamera = false
    @State private var showImagePicker = false
    
    @State private var showPermissionAlert = false
    @State private var permissionAlertTitle = ""
    @State private var permissionAlertMessage = ""


    var body: some View {
        // шукаємо item по id
        if let item = viewModel.item(withID: itemID) {
            ScrollView {
                VStack(spacing: 20) {
                    coverSection(for: item)
                    photoNoteSection(for: item)
                    notesSection(for: item)
                }
                .padding()
            }
            .onTapGesture {
                hideKeyboard()
        }
            .background(
                LinearGradient(
                    colors: [AppColor.paperWhite, AppColor.softMint.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle(item.title)
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("Джерело фото",
                isPresented: $showPhotoSourceDialog,
                titleVisibility: .visible
            ) {
                Button("Камера") { handleCameraTap() }
                Button("Галерея") { handleGalleryTap() }
                Button("Скасувати", role: .cancel) {}
            }

            .sheet(isPresented: $showCamera) {
                CameraView { image in
                    if let image {
                        viewModel.attachNoteImage(to: item.id, image: image)
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView { image in
                    if let image {
                        viewModel.attachNoteImage(to: item.id, image: image)
                    }
                }
            }
            .alert(permissionAlertTitle, isPresented: $showPermissionAlert) {
                Button("Відкрити налаштування") { openAppSettings() }
                Button("Скасувати", role: .cancel) { }
            } message: {
                Text(permissionAlertMessage)
            }

        } else {
            Text("Цю книгу видалено зі списку.")
                .foregroundColor(AppColor.inkBlack)
        }
    }

    // MARK: - Sections

    private func coverSection(for item: ReadingListItem) -> some View {
        VStack(spacing: 8) {
            if let url = item.coverURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 20)
                            .fill(AppColor.lavender.opacity(0.4))
                            .frame(height: 260)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .interpolation(.high)
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 260)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 10)
                    case .failure:
                        placeholderCover
                    @unknown default:
                        placeholderCover
                    }
                }
            } else {
                placeholderCover
            }

            Text(item.author)
                .font(.headline)
                .foregroundColor(AppColor.inkBlack.opacity(0.8))
        }
    }

    private var placeholderCover: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColor.lavender.opacity(0.35))
                .frame(height: 260)
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundColor(AppColor.inkBlack.opacity(0.6))
        }
        .shadow(radius: 8)
    }

    private func photoNoteSection(for item: ReadingListItem) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Заголовок секції
            HStack(spacing: 8) {
                Image(systemName: "camera.fill")
                    .imageScale(.medium)
                    .padding(6)
                    .background(
                        Circle()
                            .fill(AppColor.blushPink.opacity(0.15))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Фото-нотатки")
                        .font(.headline)
                        .foregroundColor(AppColor.inkBlack)
                    if item.hasNoteImages {
                        Text("\(item.noteImagesData.count) фото")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Додай візуальні нотатки до книги")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }

            if item.hasNoteImages {
                // Карусель з фотками
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(item.noteImagesData, id: \.self) { data in
                            if let uiImage = UIImage(data: data) {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 140, height: 140)
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)

                                    // Хрестик для видалення конкретної фотки
                                    Button {
                                        viewModel.removeNoteImage(from: item.id, imageData: data)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .imageScale(.large)
                                            .foregroundStyle(.white, .black.opacity(0.55))
                                            .shadow(radius: 4)
                                    }
                                    .padding(6)
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Картка "додати ще фото"
                        Button {
                            showPhotoSourceDialog = true
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28, weight: .semibold))
                                Text("Додати\nще фото")
                                    .font(.footnote.weight(.medium))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: 120, height: 120)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .strokeBorder(AppColor.blushPink.opacity(0.4), style: StrokeStyle(lineWidth: 1.4, dash: [6]))
                                    .background(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(AppColor.paperWhite.opacity(0.9))
                                    )
                            )
                            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                }

                // Нижній ряд з кнопками
                HStack {
                    Button {
                        showPhotoSourceDialog = true
                    } label: {
                        Label("Ще фото", systemImage: "camera.on.rectangle")
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(AppColor.blushPink)
                            )
                            .foregroundColor(.white)
                            .shadow(color: AppColor.blushPink.opacity(0.4), radius: 8, x: 0, y: 4)
                    }

                    Spacer()

                    Button(role: .destructive) {
                        viewModel.removeNoteImage(from: item.id)
                    } label: {
                        Label("Видалити всі", systemImage: "trash")
                            .font(.caption)
                    }
                    .tint(.red.opacity(0.85))
                }
            } else {
                // Стан, коли ще немає жодної фотки
                Button {
                    showPhotoSourceDialog = true
                } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(AppColor.blushPink.opacity(0.15))
                                .frame(width: 42, height: 42)

                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(AppColor.blushPink)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Додати фото-нотатку")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(AppColor.inkBlack)
                            Text("Збережи обкладинку, улюблену цитату, скрін чи будь-який візуальний момент.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer()
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(AppColor.paperWhite)
                            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppColor.paperWhite.opacity(0.95))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 6)
        )
    }




    private func notesSection(for item: ReadingListItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Нотатки")
                .font(.headline)
                .foregroundColor(AppColor.inkBlack)

            if item.notes.isEmpty {
                Text("Додай першу нотатку про цю книгу 💫")
                    .font(.subheadline)
                    .foregroundColor(AppColor.inkBlack.opacity(0.7))
            } else {
                VStack(spacing: 8) {
                    ForEach(item.notes) { note in
                        noteRow(itemID: item.id, note: note)
                    }
                }
            }

            Divider()
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 6) {
                Text("Нова нотатка")
                    .font(.subheadline.weight(.semibold))

                TextField("Що ти думаєш про цю книгу?", text: $newNoteText, axis: .vertical)
                    .lineLimit(3...6)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColor.paperWhite)
                            .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
                    )

                Button {
                    viewModel.addNote(to: item.id, text: newNoteText)
                    newNoteText = ""
                } label: {
                    HStack(spacing: 12) {
                        // Іконка з фоном
                        ZStack {
                            Circle()
                                .fill(AppColor.blushPink.opacity(0.18))
                                .frame(width: 40, height: 40)

                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppColor.blushPink)
                        }

                        // Текстовий блок
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Додати нотатку")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(AppColor.inkBlack)

                            Text("Запиши думки, цитати чи враження від книги.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer()
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(AppColor.paperWhite)
                            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
                    )
                }
                .buttonStyle(.plain)
                .disabled(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppColor.paperWhite.opacity(0.95))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }

    private func noteRow(itemID: String, note: ReadingNote) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.text)
                .font(.body)
                .foregroundColor(AppColor.inkBlack)

            HStack {
                Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(AppColor.inkBlack.opacity(0.6))

                Spacer()

                Button {
                    editingNote = note
                    editingText = note.text
                } label: {
                    Image(systemName: "pencil")
                }
                .buttonStyle(.plain)

                Button(role: .destructive) {
                    viewModel.deleteNote(in: itemID, note: note)
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
            }
            .font(.caption)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColor.lavender.opacity(0.15))
        )
        .sheet(item: $editingNote) { note in
            editNoteSheet(itemID: itemID, note: note)
        }
    }

    private func editNoteSheet(itemID: String, note: ReadingNote) -> some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Редагувати нотатку", text: $editingText, axis: .vertical)
                    .lineLimit(3...10)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColor.paperWhite)
                    )

                Button {
                    viewModel.updateNote(in: itemID, note: note, newText: editingText)
                    editingNote = nil
                } label: {
                    Text("Зберегти")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(AppColor.blushPink)
                        .foregroundColor(.white)
                        .cornerRadius(18)
                }

                Spacer()
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [AppColor.paperWhite, AppColor.lavender.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Редагування")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") {
                        editingNote = nil
                    }
                }
            }
        }
    }
    
    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func presentPermissionAlert(title: String, message: String) {
        permissionAlertTitle = title
        permissionAlertMessage = message
        showPermissionAlert = true
    }

    private func handleCameraTap() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCamera = true

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted { showCamera = true }
                    else {
                        presentPermissionAlert(
                            title: "Немає доступу до камери",
                            message: "Увімкни доступ у Налаштуваннях, щоб зробити фото."
                        )
                    }
                }
            }

        case .denied, .restricted:
            presentPermissionAlert(
                title: "Немає доступу до камери",
                message: "Доступ вимкнено. Відкрий Налаштування та дозволь доступ до камери."
            )

        @unknown default:
            presentPermissionAlert(
                title: "Немає доступу до камери",
                message: "Не вдалося отримати доступ до камери."
            )
        }
    }

    private func handleGalleryTap() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch status {
        case .authorized, .limited:
            showImagePicker = true

        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        showImagePicker = true
                    } else {
                        presentPermissionAlert(
                            title: "Немає доступу до фото",
                            message: "Увімкни доступ у Налаштуваннях, щоб обрати фото."
                        )
                    }
                }
            }

        case .denied, .restricted:
            presentPermissionAlert(
                title: "Немає доступу до фото",
                message: "Доступ вимкнено. Відкрий Налаштування та дозволь доступ до Фото."
            )

        @unknown default:
            presentPermissionAlert(
                title: "Немає доступу до фото",
                message: "Не вдалося отримати доступ до Фото."
            )
        }
    }

}
