//
//  TeacherComposer.swift
//  KyoNeo
//
//  Created by Aether on 05/05/2024.
//

import SwiftUI
import AmethystUI
import MessageUI

struct TeacherComposer: View {
    var color: Color
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var teacher: TeacherEntity

    @State var scrolled: Bool = false

    init(_ teacher: TeacherEntity, color: Color  = .accentColor) {
        self.teacher = teacher
        self.color = color
        self._name = .init(initialValue: teacher.name ?? "")
        self._email = .init(initialValue: teacher.email ?? "")
        self._phone =  .init(initialValue: teacher.phone ?? "")
        self._selectedTitleEnum = .init(initialValue: TitleEnum(rawValue: teacher.title) ?? .none)
    }

    @State var result: Result<MFMailComposeResult, Error>? // For handling email composer status
        @State var isShowingMailView = false
    @State var editTeacher = false
    @State var name: String
    @State var email: String
    @State var phone: String
    @State var selectedTitleEnum: TitleEnum = .none

    var body: some View {
        ScrollView {
            ScrollDetector(scrolled: $scrolled)
                .frame(height: 0)
            VStack{
                
                GroupSection(label: "Title") {

                    HStack(spacing: 0) {
                        Image(systemName: "person.fill")
                            .font(Font.body.weight(.semibold))
                            .foregroundStyle(.primary)
                            .padding(.leading, 3)
                            .padding(.trailing, 5)


                        let titleCategories: [(key: String, value: [TitleEnum])] = {
                                TitleEnum.groupedByCategory.sorted { (a, b) in
                                    if a.key == "Honorific" && b.key != "Honorific" {
                                        return true
                                    } else if b.key == "Honorific" && a.key != "Honorific" {
                                        return false
                                    }
                                    return a.key < b.key
                                }
                            }()

                        Picker("Title", selection: $selectedTitleEnum) {
                            ForEach(titleCategories, id: \.key) { category, titles in
                                           Section(header: Text(category)) {
                                               ForEach(titles, id: \.self) { title in
                                                   Text(title.description)
                                                       .tag(title)
                                               }
                                           }
                                       }.frame(maxWidth: .infinity, alignment: .leading)
                        }

                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .pickerStyle(.menu)
                        .tint(color)

                        .onChange(of: selectedTitleEnum, initial: false) {
                            teacher.title = selectedTitleEnum.rawValue

                            do {
                                      try viewContext.save()

                                  } catch {
                                      let nsError = error as NSError
                                      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                  }

                        }
                        //                        .onChange(of: scrollAmmount) { oldValue, newValue in
                        //
                        //                            if newValue > oldValue {
                        //
                        //                                focusedField = false
                        //                            }
                        //                        }
                    }
                    .padding(.vertical, -4)
                    .neoSettingsCard()

                }
                .padding(.horizontal, 20)

                GroupSection(label: "Name") {

                    HStack(spacing: 0) {
                        Image(systemName: "character.textbox")
                            .font(Font.body.weight(.semibold))
                            .foregroundStyle(.primary)
                            .padding(.leading, 3)
                            .padding(.trailing, 5)


                        TextField("Teachers Name..", text: $name)
                            .padding(.leading, 3)
                            .textContentType(.name)
                            .onChange(of: name, initial: false) {
                                teacher.name = name

                                do {
                                          try viewContext.save()

                                      } catch {
                                          let nsError = error as NSError
                                          fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                      }
                            }
#if !os(macOS)
                            .keyboardType(.asciiCapable)
#endif

                        //                        .onChange(of: scrollAmmount) { oldValue, newValue in
                        //
                        //                            if newValue > oldValue {
                        //
                        //                                focusedField = false
                        //                            }
                        //                        }
                    }


                    .neoSettingsCard()

                }
                .padding(.horizontal, 20)

                GroupSection(label: "Contact") {

                    HStack(spacing: 0) {
                        Image(systemName: "envelope.fill")
                            .font(Font.body.weight(.semibold))
                            .foregroundStyle(.primary)
                            .padding(.leading, 3)
                            .padding(.trailing, 5)


                        TextField("Email", text: $email)
                            .padding(.leading, 3)
                            .textContentType(.name)
                            .onChange(of: email, initial: false) {
                                teacher.email = email

                                do {
                                          try viewContext.save()

                                      } catch {
                                          let nsError = error as NSError
                                          fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                      }
                            }
#if !os(macOS)
                            .keyboardType(.asciiCapable)
#endif

                        //                        .onChange(of: scrollAmmount) { oldValue, newValue in
                        //
                        //                            if newValue > oldValue {
                        //
                        //                                focusedField = false
                        //                            }
                        //                        }
                    }


                    .neoSettingsCard()

                    HStack(spacing: 0) {
                        Image(systemName: "phone.fill")
                            .font(Font.body.weight(.semibold))
                            .foregroundStyle(.primary)
                            .padding(.leading, 3)
                            .padding(.trailing, 5)


                        TextField("Phone", text: $phone)
                            .padding(.leading, 3)
                            .textContentType(.name)
                            .onChange(of: phone, initial: false) {
                                teacher.phone = phone

                                do {
                                          try viewContext.save()

                                      } catch {
                                          let nsError = error as NSError
                                          fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                      }
                            }
#if !os(macOS)
                            .keyboardType(.asciiCapable)
#endif

                        //                        .onChange(of: scrollAmmount) { oldValue, newValue in
                        //
                        //                            if newValue > oldValue {
                        //
                        //                                focusedField = false
                        //                            }
                        //                        }
                    }


                    .neoSettingsCard()

                }
                .padding(.horizontal, 20)

//                GroupSection(label: "Link Contact") {
//
//                    HStack(spacing: 0) {
//                        Image(systemName: "person.crop.circle")
//                            .font(Font.body.weight(.semibold))
//                            .foregroundStyle(.primary)
//                            .padding(.leading, 3)
//                            .padding(.trailing, 5)
//
//
//                        Button {
//
//                        } label: {
//                            Text("Link")
//                        }
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .tint(color)
//
//                    }
//
//
//                    .neoSettingsCard()
//
//                }
//                .padding(.horizontal, 20)


//                Button {
//                    teacher.pinned.toggle()
//                } label: {
//                    Text("toggle pinned")
//                }
//
//
//                    Button {
//                        teacher.phone = "0000"
//                    } label: {
//                        Text("add test number")
//                    }
//
//
//                    Button {
//                        teacher.email = "0000"
//                    } label: {
//                        Text("add test email")
//                    }
//
//
//                    Button {
//                        teacher.phone = nil
//                    } label: {
//                        Text("remove number")
//                    }
//
//                    Button {
//                        teacher.email = nil
//                    } label: {
//                        Text("remove email")
//                    }
            }
            .frame(maxWidth: .infinity)
        }
        .coordinateSpace(name: "scroll")
        .safeAreaInset(edge: .top, content: {
            AdjustableInset().padding(.bottom, -10)
        })
        .amethystNavigationBar(title: getTitle() , tintColor: color, /*overrideType: .regular,*/ scrolled: $scrolled, linelimit: 1,  content: {
            HStack(spacing: 10){

                Button(action: {
                    teacher.pinned.toggle()

                    do {
                              try viewContext.save()

                          } catch {
                              let nsError = error as NSError
                              fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                          }
                }, label: {
                    Image(systemName: teacher.pinned ? "pin.slash" : "pin")
                        .scaledFrame(width: 44, height: 44, relativeTo: .body)
                })
                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
            }
        }, toolbar: {

        })
        .animation(.smooth, value: teacher.name)


        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack{
                            if let phone = teacher.phone, !phone.isEmpty {
                                Button(action: {
                                    makePhoneCall(phoneNumber: phone)
                                }, label: {
                                    Label("Phone", systemImage: "phone.fill")
                                        .frame(maxWidth: .infinity)
                                })
                                .buttonStyle(PolishedButton(color: color, background: true))
                                .transition(.blur.animation(.smooth))
                            }

                            if let email = teacher.email, !email.isEmpty {
                                Button(action: {
                                    self.isShowingMailView = true
                                }, label: {
                                    Label("Email", systemImage: "envelope.fill")
                                        .frame(maxWidth: .infinity)
                                })
                                .buttonStyle(PolishedButton(color: color, background: true))
                                .transition(.blur.animation(.smooth))
                                .hueRotation(Angle(degrees: 10))
                            }

            }
            .padding(.horizontal, 25)
            .padding(.bottom)
            .animation(.smooth, value: teacher.phone)
            .animation(.smooth, value: teacher.email)
        }
        .sheet(isPresented: $isShowingMailView) {
                    if MFMailComposeViewController.canSendMail() {
                        MailView(result: $result, recipients: [teacher.email ?? ""], subject: "Message from App")

                    } else {
                        Text("Error sending email")
                    }
                }
        .sheet(isPresented: $editTeacher) {
                    if MFMailComposeViewController.canSendMail() {
                        MailView(result: $result, recipients: [teacher.email ?? ""], subject: "Message from App")

                    } else {
                        Text("Error sending email")
                    }
                }

        .symbolVariant(.fill)
    }

    private func makePhoneCall(phoneNumber: String) {
            guard let url = URL(string: "tel://\(phoneNumber)"),
                  UIApplication.shared.canOpenURL(url) else {
                      return
                  }
            UIApplication.shared.open(url)
        }

    private func getTitle() -> String{
        return teacher.name != "" ? "\(selectedTitleEnum != .none ? (selectedTitleEnum.description + " ") : "")\(teacher.name ?? "Teacher")" : "Teacher"
    }
}

struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var result: Result<MFMailComposeResult, Error>?
    var recipients: [String]
    var subject: String
    var body: String = ""

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentationMode: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(presentationMode: Binding<PresentationMode>, result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentationMode = presentationMode
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer {
                $presentationMode.wrappedValue.dismiss()
            }
            if let error = error {
                self.result = .failure(error)
                return
            }
            self.result = .success(result)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(presentationMode: presentationMode, result: $result)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(recipients)
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: UIViewControllerRepresentableContext<MailView>) {
        // No action required here
    }
}
