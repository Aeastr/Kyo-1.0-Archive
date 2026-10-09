//
//  TaskArchive.swift
//  KyoNeo
//
//  Created by Aether on 24/08/2023.
//

import SwiftUI
import AmethystUI

struct TaskArchive: View {
    @State var scrolled: Bool = false

    @State var selectedID: NSObject? = nil
    @AppStorage("global_Compact") var global_Compact  = false
    @State var edit: Bool = false
    @State var selectedTasksEdit: [TaskEntity] = []

    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "due", ascending: true)]) var tasks: FetchedResults<TaskEntity>
    var color: Color = Color.accentColor

    var body: some View {
        ZStack{
        ScrollView{
            ScrollDetector(scrolled: $scrolled)

            LazyVStack{

                VStack{
                    Text("Completed Tasks are automatically archived after 1 day past due date")
                        .font(.caption)
                        .foregroundStyle(.primary.opacity(0.6))


                    Text("Archived Tasks are automatically deleted after 15 days past due date")
                        .font(.caption)
                        .foregroundStyle(.primary.opacity(0.6))
                }

                .padding(10)
                .frame(maxWidth: .infinity)
                .neoSettingsCard()
                .padding(.horizontal, 30)



                let tasksFilter = tasks.filter{ task in
                    return task.archived
                }

                ForEach(Array(tasksFilter.enumerated()), id: \.element) { index, task in
                    if let dueDate = task.due{
                        let calendar = Calendar.current

                        if index == 0 {
                            Text(dueDate, style: .date)
                                .sectionTitle()
                                .padding(.horizontal, 20)
                        } else {
                            if tasksFilter.indices.contains(index - 1) {
                                if let previousDueDate = tasksFilter[index - 1].due {
                                    let components = calendar.dateComponents([.year, .month, .day], from: previousDueDate)
                                    let previousDateOnly = calendar.date(from: components)!

                                    let currentDateComponents = calendar.dateComponents([.year, .month, .day], from: dueDate)
                                    let currentDateOnly = calendar.date(from: currentDateComponents)!

                                    if previousDateOnly != currentDateOnly {
                                        Text(dueDate, style: .date)
                                            .sectionTitle()
                                            .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                        Button {

                            if edit{
                                if selectedTasksEdit.contains(where: { taskItem in
                                    taskItem == task
                                })
                                {
                                    selectedTasksEdit.removeAll { taskItem in
                                        taskItem == task
                                    }
                                }
                                else{
                                    selectedTasksEdit.append(task)
                                }
                            }

                        } label: {



                            HStack{
                                TaskItem(data: task)
                                //                                    Text("task here")
                                    .padding(.horizontal, global_Compact ? 0 : 25)
                                    .transition(.blur.animation(.bouncy))
                                    .allowsHitTesting(!edit)
                                if edit{
                                    Image(systemName: selectedTasksEdit.contains(where: { taskItem in
                                        taskItem == task
                                    })
                                          ?
                                          "checkmark.circle.fill"
                                          :
                                            "circle")
                                    .foregroundStyle(Color(hex: task.classEntity?.color2 ?? "").darken(by: 0.4))
                                    .font(.title3)
                                    .padding(.trailing, edit ? 45 : 0)
                                }
                            }

                            .contentShape(Rectangle())

                        }
                        .buttonStyle(PlannerClassItem())
                        //                                            .animation(.bouncy(duration: 0.35))
                    }

                }
                if tasksFilter.isEmpty{
                    VStack{
                        Text("No Archived Tasks. Tasks that are 20 days old and completed are automatically archived")
                            .font(.caption)
                            .foregroundStyle(.primary.opacity(0.6))

                    }
                    .frame(height: 80)
                    .frame(maxWidth: .infinity)
                    .neoSettingsCard()
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                }

            }

            .animation(.bouncy(duration: 0.35), value: selectedID)
        }
        .safeAreaInset(edge: .top, content: {
            Color.clear
                .frame(height: 100)
        })



//        .safeAreaInset(edge: .bottom) {
//            HStack(spacing: 10){
//
//                Button {
//
//                } label: {
//                    Text("Select")
//                        .scaledFrame(width: nil, height: 20, relativeTo: .body)
//                        .padding(.horizontal, 8)
//                }
//                .buttonStyle(BentoButton(color: color))
//                //                    Button {
//                //
//                //                    } label: {
//                //                        Text("Delete All")
//                //                            .scaledFrame(width: nil, height: 20, relativeTo: .body)
//                //                            .padding(.horizontal, 8)
//                //                    }
//                //                    .buttonStyle(BentoButton(role: .destructive))
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(.horizontal, 25)
//            .padding(.bottom, 20)
//            .padding(.top, 20)
//            .background{
//#if os(iOS) || os(visionOS)
//                ZStack{
//                    if let mask = UIImage(named: "maskbottomtotop") {
//                        // Display the image only if it's successfully loaded
//                        VariableBlurView(gradientMask: mask)
//                            .ignoresSafeArea()
//                    }
//
//                    LinearGradient(gradient: Gradient(colors: [Color.clear, Color("bw").opacity(0.8), Color("bw").opacity(0.9)]), startPoint: .top, endPoint: .bottom)
//                        .ignoresSafeArea()
//                        .scaleEffect(y: 1.3)
//                }
//#endif
//            }
//        }
    }
        .amethystNavigationBar(title: "Task Archive", titleColor: .primary,   tintColor: color, overrideType: .regular, scrolled: $scrolled, inSheet: true){
            Button {
                dismiss()
            } label: {


                Text("Done")
                    .font(.body.weight(.regular))

                    .scaledFrame(width: nil, height: 42, relativeTo: .body, alignment: .leading)
                    .padding(.horizontal, 15)
                    .contentShape(Rectangle())

            }
            .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
            //            .buttonStyle(borderlessButton(color: color, scrolled: $scrolled))
            .transition(.blur)
            .padding(.top, 15)
        }toolbar: {
            let tasksFilter = tasks.filter{ task in
                return task.archived
            }

            ViewThatFits{
                Text("^[\(tasksFilter.count) Archived Task](inflect: true)")
                    .transition(.blur.animation(.smooth))
                Text("")
            }
            .transition(.blur.animation(.smooth))
            .scaledFrame(width: nil, height: 42, relativeTo: .body, alignment: .leading)
            .padding(.top, 15)

        }
    }
}

#Preview {
    TaskArchive()
}
