import SwiftUI
import PhotosUI

struct AddDishView: View {
    @EnvironmentObject var store: DishStore
    @Environment(\.dismiss) private var dismiss

    // Form fields
    @State private var name: String = ""
    @State private var shortDescription: String = ""
    @State private var link: String = ""
    @State private var selectedTags: Set<DishTag> = []
    @State private var typedTags: String = ""

    // Photo picker
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Photo")) {
                    HStack(spacing: 16) {
                        Group {
                            if let imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.secondary)
                                    .padding(12)
                            }
                        }
                        .frame(width: 80, height: 80)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                            Label("Choose Photo", systemImage: "photo.on.rectangle")
                        }
                        .onChange(of: selectedItem) { newValue in
                            Task {
                                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                    await MainActor.run {
                                        self.imageData = data
                                    }
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Details")) {
                    TextField("Dish name", text: $name)
                    TextField("Short description", text: $shortDescription, axis: .vertical)
                        .lineLimit(2, reservesSpace: true)
                    TextField("Recipe link (https://)", text: $link)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section(header: Text("Categories")) {
                    TextField("Type categories (comma-separated)", text: $typedTags, axis: .vertical)
                        .lineLimit(1...3)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Text("Example: fried, baked, cheesy")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Potato Dish")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Upload") { publish() }
                        .disabled(!canPublish)
                }
            }
        }
    }

    private var canPublish: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !shortDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func publish() {
        let fallbackImageName = "fries"
        let dish = Dish(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            shortDescription: shortDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            imageName: fallbackImageName,
            uiImageData: imageData,
            tags: Array(parseTypedTags().union(selectedTags)),
            customTags: parseCustomTags(),
            link: link.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        store.addDish(dish)
        dismiss()
    }

    private func parseTypedTags() -> Set<DishTag> {
        Set(typedTags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .compactMap { DishTag(rawValue: $0) })
    }

    private func parseCustomTags() -> [String] {
        typedTags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

private struct TagSelectionView: View {
    @Binding var selected: Set<DishTag>

    var body: some View {
        let all = DishTag.allCases
        VStack(alignment: .leading, spacing: 8) {
            FlowLayoutHStack(spacing: 8) {
                ForEach(all) { tag in
                    let isOn = selected.contains(tag)
                    Button(action: {
                        if isOn { selected.remove(tag) } else { selected.insert(tag) }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(isOn ? tag.color : .secondary)
                            Text(tag.displayName)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(tag.color.opacity(isOn ? 0.2 : 0.08))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// A simple wrapping HStack helper for tag chips
private struct FlowLayoutHStack<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: () -> Content

    var body: some View {
        GeometryReader { geo in
            self.generateContent(in: geo.size)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 0)
    }

    private func generateContent(in size: CGSize) -> some View {
        var x: CGFloat = 0
        var y: CGFloat = 0
        return ZStack(alignment: .topLeading) {
            content()
                .fixedSize()
                .alignmentGuide(.leading) { d in
                    if (x + d.width > size.width) {
                        x = 0
                        y -= (d.height + spacing)
                    }
                    let result = x
                    x += d.width + spacing
                    return result
                }
                .alignmentGuide(.top) { d in
                    let result = y
                    return result
                }
        }
    }
}

