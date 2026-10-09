//
//  TeachersListSection.swift
//  KyoNeo
//
//  Created by Aether on 09/05/2024.
//

import SwiftUI
import SwiftUIIntrospect

struct TeacherRowItem: Identifiable, Equatable, Hashable {
    var id: UUID = UUID()
    var teacher: TeacherEntity
    var label: String
    var description: String?
    var icon: String
    var trailingIcons: [String]?
    var color: Color?
    var destinationView: AnyView?

    static func == (lhs: TeacherRowItem, rhs: TeacherRowItem) -> Bool {
        return lhs.id == rhs.id && lhs.label == rhs.label && lhs.icon == rhs.icon
    }



    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(label)
        hasher.combine(icon)
        // Note: destinationView is not included
    }
}

struct TeachersListSection: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "pinned", ascending: false), NSSortDescriptor(key: "name", ascending: true)]) var teachers: FetchedResults<TeacherEntity>


        var useColor = Color.red

    @State var height: CGFloat = 44

    var body: some View {
        List {
            let teacherEntities = teachers.map { teacher in
                        // Initialize an array to hold icons
                    var icons: [String] = []

                        // Conditionally add phone, email, and pin icons
                        if let phone = teacher.phone, !phone.isEmpty {
                            icons.append("phone.fill")
                        }
                        if let email = teacher.email, !email.isEmpty {
                            icons.append("envelope.fill")
                        }
                        if teacher.pinned {
                            icons.append("pin.fill")
                        }

                        let title = TitleEnum(rawValue: teacher.title) ?? .none
                        let name = teacher.name ?? "Unknown"
                        let label = title != .none ? "\(title.description) \(name)" : "\(name)"


                        return TeacherRowItem(
                            teacher: teacher,
                            label: label,
                            icon: "person.fill",  // main icon
                            trailingIcons: icons,
                            destinationView: AnyView(TeacherComposer(teacher, color: useColor))
                        )
                    }

            ForEach(Array(teacherEntities.enumerated()), id: \.element) { index, item in
                NavigationLink(value: item) {
                    HStack{
                        HStack{
                            Image(systemName: "person.fill")
                                                        .frame(width: 20, height: 20, alignment: .center)
                                                        .font(.body)
                                                        .symbolRenderingMode(.monochrome)
                                                        .fontWeight(.regular)
                                #if os(visionOS)
                                                        .foregroundColor(useColor.getBrightness() > 0.65 ? useColor.darken(by: 0.5) : Color.white)
                                                        .scaleEffect(0.86)
                                                        .padding(6)

                                                        .background(useColor.darken(by: useColor.getBrightness() > 0.65 ? -0.2 : 0.2).gradient)
                                                        .clipShape(Circle())
                                #else
                                                        .foregroundColor(useColor)
                                #endif
                                                    Text(item.label).foregroundColor(.primary)
                                #if os(visionOS)
                                                        .padding(.leading, 8)
                                #else
                                                        .padding(.leading, 4)
                                #endif
                        }
                                            .frame(maxWidth: .infinity, alignment: .leading)


                        if let trailingIcons = item.trailingIcons{
                            ForEach(trailingIcons, id: \.self){ icon in
                                Image(systemName: icon)
                                    .foregroundColor(.secondary)
                                    .font(Font.caption.bold())

                            }
                        }
                    }


                }

                  .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                    .listRowSeparator(.hidden, edges: [.bottom])
                    .frame(height: 50)
                    .swipeActions {
                        Button(role: .destructive) {
                            DispatchQueue.main.async{
                                withAnimation(.smooth){
                                    viewContext.delete(item.teacher)
                                }
                            }
                        } label: {
                            Image(systemName: "trash")
                        }

                    }
                    .transition(.blur.animation(.smooth))

            }

        }
        .frame(height: height)
        .animation(.smooth, value: height)
        .introspect(.list, on: .iOS(.v17)) { tableView in
            DispatchQueue.main.async{
                withAnimation(.smooth){
                    height = tableView.contentSize.height
                }
            }
        }
        .listRowSpacing(0)
        .listRowSeparator(.hidden, edges: [.bottom])
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .listSectionSeparator(.hidden)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .regularOutline()
    }

    
}

#Preview {
    TeachersListSection()
}


