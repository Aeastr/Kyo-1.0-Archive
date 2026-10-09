//
//  TaskDetail.swift
//  KyoNeo
//
//  Created by Aether on 14/07/2023.
//

import SwiftUI
import AmethystUI
import CoreMotion

#if canImport(HighlightedTextEditor)
import HighlightedTextEditor
#endif

// matches text between underscores
let betweenUnderscores = try! NSRegularExpression(pattern: "_[^_]+_", options: [])

#if !os(macOS)
struct TaskDetail: View, KeyboardReadable {
    @State private var useMarkdown = false
    @State private var showLinkEdit = false
    @State private var isKeyboardVisible = false
    @Environment(\.openURL) private var openURL
    @Environment(\.managedObjectContext) private var viewContext
    @State private var position: Double = 0.5
    @Environment(\.dismiss) var dismiss
    @ObservedObject var task: TaskEntity
    @State var notes: String = ""
    @State var linktext: String = ""
    @State var scrollValue = 0.0
    @State var showEdit = false

    @State var showArchiveWarning: Bool = false

    init(task: TaskEntity) {
        self.task = task
        if let notes = task.notes{
            self._notes = .init(initialValue: notes)
        }

    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    @AppStorage("navigationFont") var fontDesign: navigationFont = .expanded
    @AppStorage("fontWeightIndex") private var fontWeightIndex: Int = 1
    @AppStorage("fontCaseIndex") private var fontCaseIndex: Int = 0

#if canImport(HighlightedTextEditor)
    private let rules: [HighlightRule] = [
            HighlightRule(pattern: betweenUnderscores, formattingRules: [
                TextFormattingRule(fontTraits: [.traitItalic, .traitBold]),
                TextFormattingRule(key: .foregroundColor, value: UIColor.red),
                TextFormattingRule(key: .underlineStyle) { content, range in
                    if content.count > 10 { return NSUnderlineStyle.double.rawValue }
                    else { return NSUnderlineStyle.single.rawValue }
                }
            ])
        ]
    #endif

    private let motionManager = CMMotionManager()
    private func startMotionUpdates() {
            if motionManager.isDeviceMotionAvailable {
                motionManager.deviceMotionUpdateInterval = 0.1 // Adjust the update interval as needed
                motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
                    guard let motion = motion else { return }
                    // Calculate tilt values from motion data
                    let tiltY = motion.attitude.roll // Adjust this based on your desired axis

                    // Calculate position based on tilt
                    position = (tiltY + 1) / 2 // Adjust the scaling and offset as needed
                }
            }
        }

    var body: some View {
        ScrollView {
            let brightness1 =  Color(hex: task.classEntity?.color1 ?? "98C6D1" ).getBrightness()
            let c1 = Color(hex: task.classEntity?.color1 ?? "98C6D1" )
            VStack{

            VStack(alignment: .leading, spacing: 8){
                if let title = task.label{
                    Text(title)

                        .font(.system(.largeTitle, design: fontDesign.design, weight: fontWeights[min(max(fontWeightIndex, 0), 3)].weight).width(fontDesign.wdith))
                        .textCase(fontCaseIndex == 1 ? .uppercase : fontCaseIndex == 2 ? .lowercase : nil)
                    if let dueDate = getDue(),let dueTime = task.due {


                        Text("Due \(dueTime, style: .time) \(dueDate)")
                            .font(.headline)
                            .fontWeight(.regular)
                    }
                    Divider()
                    if let taskTypeTitle = task.taskType?.title {

                        Text((task.classEntity?.name ?? "") + " - " + (taskTypeTitle))
                        //                                        .contentTransition(.opacity)
//                            .textCase(.uppercase)
                            .font(.headline)
                            .fontWeight(.medium)


                    }

                }
            }
            .frame(maxWidth: .infinity, minHeight: 200, alignment: .bottomLeading)
        }
            .foregroundColor(brightness1 > 0.82 ? c1.darken(by: 0.5) : Color.white)
            .padding(20)
            .padding(.top, 80)
            .background{
                ZStack{
                    LinearGradient(gradient: Gradient(colors: [Color(hex: task.classEntity?.color1 ?? "98C6D1"), Color(hex: task.classEntity?.color2 ?? "98C6D1")]), startPoint: .topLeading, endPoint: .bottomTrailing).opacity(task.muted ? 0.5 : 1)

                    VStack{
                        Image("doodle1")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .scaleEffect(1.2)
                            .foregroundStyle(LinearGradient(gradient: Gradient(stops: [
                                Gradient.Stop(color: Color.black.opacity(0.2), location: position - 0.17),
                                Gradient.Stop(color: Color.black.opacity(0.8), location: CGFloat(position)),
//                                Gradient.Stop(color: Color.white.opacity(0.4), location: CGFloat(position + 0.08)),
                                Gradient.Stop(color: Color.black.opacity(0.2), location: position + 0.17)
                            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
)
                            .opacity(0.3)
                            .blendMode(.overlay)
                    }
                    .animation(.smooth, value: position)



                }

            }
            .mask(
                RoundedRectangle(cornerRadius: 0, style: .continuous)
                    .transition(.identity)
            )
            HStack{
                Text("Notes")
                    .sectionTitle()
//                Button {
//                    useMarkdown.toggle()
//                } label: {
//                    Text(useMarkdown ? "Use Plain Text" : "Use Markdown")
//                        .framelessSectionTitle()
//                        .frame(maxWidth: .infinity, alignment: .trailing)
//                        .dynamicTypeSize(.large ... .xLarge)
//                        .foregroundStyle(c1)
//                }
                .onChange(of: task.notes) { change in
                    if let tnotes = task.notes{
                      notes = tnotes
                    }
                }

            }
            .padding(.horizontal, 20)
            HStack{
                if useMarkdown{
#if !os(visionOS) && !targetEnvironment(macCatalyst)
                    HighlightedTextEditor(text: $notes, highlightRules: .markdown)
                        .frame(minHeight: 100, idealHeight: 200, maxHeight: 400)
                        .onChange(of: notes){ change in
                            task.notes = notes
                            do {
                                try viewContext.save()
                            } catch {
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                            }
                        }
                        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
                            if !showEdit{
                                print("Is keyboard visible? ", newIsKeyboardVisible)
                                isKeyboardVisible = newIsKeyboardVisible
                            }
                                            }
                        .padding(.horizontal, 12)
                    #endif
                }
                else{
                    TextField("Add some notes about the task..", text: $notes,axis: .vertical)
                        .onChange(of: notes){ change in
                            task.notes = notes
                            do {
                                try viewContext.save()
                            } catch {
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                            }
                        }
                                        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
                                            if !showEdit{
                                                print("Is keyboard visible? ", newIsKeyboardVisible)
                                                isKeyboardVisible = newIsKeyboardVisible
                                            }
                                                            }
                        .padding(.horizontal, 12)
                }




            }
            .neoFieldCard()
            .padding(.horizontal, 20)
//            TextField("Add some notes about the task..", text: $notes,axis: .vertical)
//



            Text("Link")
                .onAppear{
                    linktext = task.link ?? ""
                }
                .sectionTitle()
                .padding(.horizontal, 20)
                .alert("Link", isPresented: $showLinkEdit) {
                    TextField("Enter a link here", text: $linktext)

                    Button {
                        task.link = linktext

                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    } label: {
                        Text("Done")
                    }
                    Button(role: .cancel) {

                    } label: {
                        Text("Cancel")
                    }

                } message: {
                }




                Menu {
                    

                    Button {
                        showLinkEdit.toggle()
                    } label: {
                        Text(task.link != nil ? "Edit Link" : "Add Link")

                    }
                    Button {
                        task.link = nil

                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    } label: {
                        Text("Remove Link")
                    }

                } label: {
//                    if let link = task.link, let urlString = findURL(in: link){
                    let link = task.link
                    let urlString = (link != nil ? findURL(in: link!) != nil ? findURL(in: link!) : "Invalid Link. Tap to edit" : "Add Link")
                    Label(cleanUpURLForDisplay(urlString!), systemImage: (link != nil ? findURL(in: link!) != nil ? getIconForURL(link!) : "exclamationmark.triangle" : "plus"))
                            .lineLimit(1)
                            .contentTransition(.numericText())
                            .animation(.smooth)
                            .frame(maxWidth: .infinity)
                            .padding(.leading, 13)
                            .padding(.trailing, 5)
                            .neoFieldCard()
                            .padding(.horizontal, 20)
                            .foregroundStyle(c1)

                } primaryAction: {
                    if let link = task.link, let urlString = findURL(in: link){
                        if let url = URL(string: urlString) {
                            // Implicitly calls openURL.callAsFunction(url) { ... }
                            openURL(url) { accepted in
                                if !accepted{
                                    if let formattedURL = URL(string: formatLink(urlString)){
                                        openURL(formattedURL)
                                    }
                                }
                            }
                        }
                    }
                    else{
                        showLinkEdit.toggle()
                    }
                }


//            else{
//
//                Button {
//                    showLinkEdit.toggle()
//
//                } label: {
//                    if task.link == "" || task.link == nil{
//                        Label("Add Link", systemImage: "link")
//                            .lineLimit(1)
//
//                            .frame(maxWidth: .infinity)
//                            .padding(.leading, 13)
//                            .padding(.trailing, 5)
//                            .neoFieldCard()
//                            .padding(.horizontal, 20)
//                    }
//                    else{
//                        Label("Invalid Link, Tap to edit", systemImage: "link")
//                            .lineLimit(1)
//
//                            .frame(maxWidth: .infinity)
//                            .padding(.leading, 13)
//                            .padding(.trailing, 5)
//                            .neoFieldCard()
//                            .padding(.horizontal, 20)
//                    }
//                }
//            }

        }
        .coordinateSpace(name: "scroll")
        // create a toolbar at the root of our form

        
        .toolbar {
            // set the placement of the toolbard to the keyboard
            #if !os(visionOS)
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                // create a keyboard dismiss button
                Button {
                    // dismiss the keyboard on press
                    hideKeyboard()
                } label: {
                    Text("Dismiss")
                }
            }
            #endif
        }
        .safeAreaInset(edge: .bottom) {
            let c1 = Color(hex: task.classEntity?.color1 ?? "98C6D1" )
            HStack{
                if !isKeyboardVisible{
                Button {
                    withAnimation(.smooth){
                        if task.completed == false{
                            if TaskArchiver().getArchivingAction(for: task) == .none{




                                    withAnimation(.smooth){
                                        task.completed.toggle()
                                        do {
                                            try viewContext.save()
                                        } catch {
                                            let nsError = error as NSError
                                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                        }
                                    }

                            }
                            else{
                                print("show warning")
                                showArchiveWarning.toggle()
                            }
                        }
                        else{
                            task.archived = false


                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                // Action to be executed after the random delay


                                withAnimation(.smooth){
                                    task.completed.toggle()
                                    do {
                                        try viewContext.save()
                                    } catch {
                                        let nsError = error as NSError
                                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                    }
                                }
                            }
                        }
                    }

                } label: {
                    Label( task.completed ? "Mark Uncomplete" : "Mark Done", systemImage:  task.completed ? "arrow.uturn.backward.circle" : "checkmark")
                        .scaledFrame(width: nil, height: 20, relativeTo: .body)
                        .frame(maxWidth:  .infinity)


                }
                .buttonStyle(PolishedButton(color: c1, background: !task.completed))
        

                Button {
                    showEdit.toggle()
                } label: {
                    Text("Edit")
                        .scaledFrame(width: nil, height: 20, relativeTo: .body)
                        .padding(.horizontal, 8)
                }

                .buttonStyle(PolishedButton(color: c1, background: false))
                .sheet(isPresented: $showEdit) {

                    TaskWorkshop(entity: task)
                        .presentationCornerRadius(25)
                        .interactiveDismissDisabled()
                }
//                Button {
//
//                } label: {
//                    Text("Delete")
//                        .scaledFrame(width: nil, height: 20, relativeTo: .body)
//                        .padding(.horizontal, 8)
//                }
//                .buttonStyle(PolishedButton(color: Color.red, background: true))

            }
                else if useMarkdown{

                    Button {
                        hideKeyboard()
                    } label: {
                        Text("Done")
                            .padding(.horizontal)

                    }
                    .buttonStyle(BentoButton())

                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .transition(.blur.animation(.smooth))
            .animation(.smooth, value: isKeyboardVisible)
            .dynamicTypeSize(.medium ... .xxLarge)
            .padding(.horizontal,isKeyboardVisible ? 7 : 25)
            .padding(.bottom, isKeyboardVisible ? 7 : 20)
            .padding(.top, 20)
            .background{
                ZStack{
                    if let mask = UIImage(named: "maskbottomtotop") {
                        // Display the image only if it's successfully loaded
                        VariableBlurView(gradientMask: mask)
                            .ignoresSafeArea()
                    }

                    LinearGradient(gradient: Gradient(colors: [Color.clear, Color(.systemBackground), Color(.systemBackground), Color(.systemBackground)]), startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)

        }
        .alert("Warning", isPresented: $showArchiveWarning, actions: {
                   Button(role: .destructive) {



                           withAnimation(.smooth){
                               task.completed.toggle()
                               do {
                                   try viewContext.save()
                               } catch {
                                   let nsError = error as NSError
                                   fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                               }
                           }


                       DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                           let taskArchiver = TaskArchiver()
                           taskArchiver.performArchivingAction(for: task)
                       }
                   } label: {
                       Text("Complete and Archive")
                   }
                   Button() {
                       task.doNotArchive = true


                           // Action to be executed after the random delay


                           withAnimation(.smooth){
                               task.completed.toggle()
                               do {
                                   try viewContext.save()
                               } catch {
                                   let nsError = error as NSError
                                   fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                               }
                           }



                   } label: {
                       Text("Complete and Keep")
                   }

               }, message: {
                   let taskArchiver = TaskArchiver()
                   let archivingAction = taskArchiver.getArchivingAction(for: task)

                   VStack(alignment: .leading) {


                       if archivingAction != .none {
                           Text("\(archivingAction.warning)")
                               .foregroundColor(.red)
                       } else {
                           Text("No action needed.")
                               .foregroundColor(.green)
                       }
                   }
               })
//        .overlay(alignment: .topTrailing) {
//            Button {
//                task.notes = notes
//                do {
//                    try viewContext.save()
//                } catch {
//                    let nsError = error as NSError
//                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//                }
//
//                dismiss()
//            } label: {
//                Image(systemName: "xmark")
//                    .scaledFrame(width: 40, height: 40, relativeTo: .body, alignment: .center)
//            }
//            .buttonStyle(NavigationButton(color: .primary, scrolled: .constant(false)))
//            .padding()
//            .padding(.horizontal, 5)
//
//        }

//        .onAppear {
//                    startMotionUpdates()
//                }
//                .onDisappear {
//                    stopMotionUpdates()
//                }
        
    }
    private func stopMotionUpdates() {
            motionManager.stopDeviceMotionUpdates()
        }
    func getDue() -> String?{
        if let dueDate = task.due {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, dd"
            return formatter.string(from: dueDate)
        }
        else{
            return nil
        }
    }
}
#else
struct TaskDetail: View {
    init(task: TaskEntity) {
        
    }
    var body: some View {
        Text("Error")
    }
}
#endif

//struct TaskDetail: View {
//    var namespace : Namespace.ID
//    @Environment(\.managedObjectContext) private var viewContext
//    @State var currentState: timeState = .upcoming
//    @State var currentlyActive: Bool = false
//    @State var past: Bool = false
//    @State var showNeoItemEdit = false
//    @Binding var edit: Bool
//    @State var expandedMode: Bool = false
//    var data: TaskEntity
//    @AppStorage("countdownOnlyCurrent") var countdownOnlyCurrent = true
//
//    @State var viewState: CGSize = .zero
//
//    @State var showCheck = false
//
//    @Binding var show: Bool
//    @Environment(\.colorScheme) var colorScheme
//
//    var body: some View {
//        ScrollView {
//            VStack{
//                VStack(alignment: .leading, spacing: 4) {
//                    HStack(spacing: 11) {
//                        ZStack{
//                            HStack(spacing: 3){
//                                Image(systemName: data.classEntity == nil ? data.icon ?? "square" :data.classEntity?.icon ?? "square")
//                                    .symbolRenderingMode(.hierarchical)
//                                    .font(.system(size: 15))
//                                    .rotationEffect(Angle(degrees: -45))
//                                Image(systemName: data.taskType?.icon ?? "")
//                                    .symbolRenderingMode(.hierarchical)
//                                    .font(.system(size: 15))
//                                    .rotationEffect(Angle(degrees: -45))
//                                    .shadow(color: .white, radius: 5)
//                            }
//                            .padding(7)
//                            .rotationEffect(Angle(degrees: 45))
//                        }
//                        
//                        .frame(width: 45, height: 45)
//                        .shadow(color: Color(hex: data.classEntity?.color1 ?? "98C6D1").opacity(0.2), radius: 3, y: 3)
//                        .background(.white)
//                        .clipShape(RoundedRectangle(cornerRadius: 14,style: .continuous))
//                        .foregroundColor(getColour())
//                        // .matchedGeometryEffect(id: "\(data.id)-icon", in: namespace)
//                        
//                        VStack(alignment: .leading, spacing: 3){
//                            Text(!data.completed ? "\((data.label ?? "Untitled")), DUE \(data.due ?? Date(), style: .time)" : "\((data.label ?? "Untitled")), Complete")
//                                .textCase(.uppercase)
//                                .lineLimit(2)
//                                .font(.system(size: 15, weight: .semibold))
//                                .minimumScaleFactor(0.5)
//                                .foregroundColor(Color.white)
//                                .lineSpacing(2)
//                                // .matchedGeometryEffect(id: "\(data.id)-title", in: namespace)
//                            Text((data.classEntity?.name ?? "") + " - " + (data.taskType?.title ?? ""))
//                                .textCase(.uppercase)
//                                .font(.caption)
//                                .lineLimit(2)
//                                .minimumScaleFactor(0.5)
//                                .foregroundColor(Color.white)
//                                .lineSpacing(2)
//                                // .matchedGeometryEffect(id: "\(data.id)-class", in: namespace)
//                            
//                        }
//                        
//                        Spacer()
//                        Group{
//                            //Text(data.due ?? Date(), style: .time)
//                        }
//                        
//                        .textCase(.uppercase)
//                        .foregroundColor(Color.white)
//                        .font(.footnote.weight(.semibold))
//                        .multilineTextAlignment(.trailing)
//                        Button {
//                            withAnimation(.smoothCard){
//                                show = false
//                            }
//                        } label: {
//                            Image(systemName: "xmark")
//                                .symbolRenderingMode(.hierarchical)
//                                .font(.system(size: 19))
//                                .padding(7)
//                            
//                                .frame(width: 35, height: 35)
//                                .shadow(color: Color(hex: data.classEntity?.color1 ?? "98C6D1").opacity(0.2), radius: 3, y: 3)
//                                .background(.white)
//                                .clipShape(RoundedRectangle(cornerRadius: 25,style: .continuous))
//                                .foregroundColor(getColour())
//                                .regularOutline(cornerRadius: 25)
//                        }
//                        .buttonStyle(bounceButton())
//                        // .matchedGeometryEffect(id: "\(data.id)-checkmarkbutton", in: namespace)
//                        
//                    }
//                    
//                }
//                .padding(.leading, 11)
//                .padding(.trailing, 13)
//                .padding(.vertical, 10)
//                .padding(.top, 200)
//                .padding()
//                //            .padding(.bottom, expandedMode ? 40 : 0)
//                //   .shadow(color: Color(hex: data.classEntity?.color1 ?? "98C6D1").opacity(currentState == .current ? 0.6 : 0.3), radius: currentState == .current ? 10 : 4, x:0, y: currentState == .current ? 8 : 4)
//                .background{
//                    LinearGradient(gradient: Gradient(colors: [Color(hex: data.classEntity?.color1 ?? "98C6D1"), Color(hex: data.classEntity?.color2 ?? "98C6D1")]), startPoint: .topLeading, endPoint: .bottomTrailing)
//                        // .matchedGeometryEffect(id: "\(data.id)-bg", in: namespace)
//                        .transition(.identity)
//                        .shadow(color: Color(hex: data.classEntity?.color1 ?? "98C6D1").opacity(0.15), radius: 5, x:0, y: 6)
//                }
//                .mask(
//                    RoundedRectangle(cornerRadius: 25, style: .continuous) // .matchedGeometryEffect(id: "\(data.id)-bgmask", in: namespace).transition(.identity)
//                )
//
//                Text(data.notes ?? "")
//                    .transition(.asymmetric(insertion: .opacity.animation(.smooth.delay(1)), removal: .opacity.animation(.smooth(duration: 0.1))))
//            }
//        }
//        .gesture(drag)
//        
//            .offset(x: viewState.width, y: viewState.height)
//
// .ignoresSafeArea()
//
//        // .shadow(color: Color(fadeHex: data.color1 ?? "98C6D1"), radius: currentState == .current ? 10 : 0, x:0, y: currentState == .current ? 8 : 0)
//
//    }
//
//    var drag: some Gesture {
//        DragGesture()
//            .onChanged { value in
//                withAnimation(.smooth){
//                    viewState = CGSize(width: value.translation.width, height: value.translation.height)
//                }
//            }
//            .onEnded { value in
//                withAnimation(.smooth){
//                    viewState = .zero
//                    show = false
//                }
//            }
//    }
//
//    private func getColour() -> Color {
//        let classColor = Color(hex: data.classEntity?.color1 ?? "98C6D1")
//        let accentn = (
//
//
//            classColor
//                .darken(by: colorScheme == .light ?
//                        checkColor(color: classColor) ?
//                        getPercent(color: classColor)
//                        :
//                            0
//                        :
//                            0)
//        )
//        return accentn
//    }
//
//    private func checkColor(color: Color)-> Bool{
//
//        return color.isLight() ?? true
//
//    }
//
//    private func getPercent(color: Color) -> Double{
//
//        return Double(color.getBrightness()) * 0.2
//
//    }
//
//}
