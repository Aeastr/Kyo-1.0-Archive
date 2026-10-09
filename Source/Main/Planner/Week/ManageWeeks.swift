//
//  ManageWeeks.swift
//  KyoNeo
//
//  Created by Aether on 23/01/2023.
//

import SwiftUI
import AmethystUI

//class CustomNavigationController: UINavigationController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let myView = VariableBlurUIView(gradientMask: UIImage(named: "maskbottomtotop")!)
//        // Configure your view
//        view.insertSubview(myView, at: 0) // Inserts the view at the bottom of the stack
//    }
//}

#if os(iOS) || os(visionOS)
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self

        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
//
//
//        if let backgroundImage = UIImage(named: "doodle1"){
//            appearance.backgroundImage = backgroundImage
//            appearance.backgroundImageContentMode = .scaleAspectFill
//        }
//
//        appearance.backgroundEffect 
        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance

        // Extend the edges beneath the navigation bar
//            edgesForExtendedLayout = .all
//            extendedLayoutIncludesOpaqueBars = true
//
//            // Add your view here
//        let myView = VariableBlurUIView(gradientMask: UIImage(named: "maskbottomtotop")!)
//            // Configure your view (e.g., set frame, add subviews)
//            view.addSubview(myView)
//
//            // Send the view to the back
//            view.sendSubviewToBack(myView)
    }


    func maskImageWithGradient(image: UIImage, gradientColors: [CGColor], gradientLocations: [NSNumber]) -> UIImage? {
        // original image
        let inputImage = image

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: inputImage.size)
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations

        // gradient layer into an image
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let maskLayer = CALayer()
        maskLayer.contents = gradientImage?.cgImage
        maskLayer.frame = CGRect(origin: .zero, size: inputImage.size)

        let maskedImageView = UIImageView(image: inputImage)
        maskedImageView.layer.mask = maskLayer
        maskedImageView.layer.masksToBounds = true

        UIGraphicsBeginImageContextWithOptions(inputImage.size, false, 0)
        maskedImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return maskedImage
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }


}
#endif

/**
 ManageWeeks is a struct conforming to the View protocol that displays and manages
 the list of weeks. It fetches the data for weeks, days, and timeSlots, and
 provides an interface for editing or creating new weeks.
 */
struct ManageWeeks: View {
    // Fetch request properties to retrieve weeks, days, and timeSlots
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeSlots: FetchedResults<TimeSlot>
    
    // Environment properties for managing the view context and dismissing the view
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    // State properties for managing the week creation process and scrolling
    @State var weekCreate = false
    @State var scrollValue = 0.0
    @State var scrolled: Bool = false
    
    // State property for managing the edit mode
    @State var edit = false
    var color: Color = Color("1")
    
    // Main body of the view
    var body: some View {
        
            // ZStack to layer views on top of one another
            ZStack{
                // Background with a NeoDot pattern
                pageTopHue(color: color)
                
                // ScrollView to display the list of weeks
                ScrollView {
                    // Scroll detection view to handle scroll events
                    ScrollDetector(scrolled: $scrolled)
                    
                    // VStack to display the list of weeks
                    VStack(spacing: 0) {
                        // Loop through the fetched weeks
                        ForEach(weeks) { w in
                            // Navigation link to navigate to the WeekWorkship view
                            NavigationLink {
                                WeekWorkship(entity: w, color: color)
                            } label: {
                                // Week item view to display the week details
                                weekItem(entity: w, color: color,  edit: $edit)
                            }
                            // Bounce button style for better user interaction
                            .buttonStyle(bounceButton())
                        }
                    }
                    // Style the VStack with a neo-field card appearance
                    .neoFieldCard(padding: 0)
                    .padding(.horizontal, 20)
                }
                // Assign a coordinate space with the name "scroll" to the ScrollView
                .coordinateSpace(name: "scroll")
                
                // Invisible view to handle the top safe area inset
                .safeAreaInset(edge: .top, content: {
                    Color.clear.frame(height: 85)
                })
                // Custom navigation bar as an overlay
                .overlay(alignment: .top){
                    FluidNavigationBar(title: "Weeks", titleColor: .primary,    tintColor: color, compactMode: true, type: .regular, scrolled: $scrolled) {
                        // Navigation bar content view
                        navBarContent
                    }toolbar: {
                        
                    }
                    
                }
            }
            
            // Hide the built-in navigation bar on iOS devices
#if os(iOS) || os(visionOS)
            .navigationTitle("")
            .navigationBarHidden(true)
#endif

    }
    
    // Navigation bar content view
    var navBarContent: some View{
        // HStack to hold the navigation buttons
        HStack(spacing: 13){
            // Edit, Create, and Done buttons based on the edit mode
            if !edit{
                // Edit button to enable edit mode
//                Button {
//                    withAnimation(.smoothCard){
//                        edit = true
//                    }
//                } label: {
//                    Text("Edit")
//                        .font(.body.weight(.regular))
//
//                    .scaledFrame(width: 60, height: 40, relativeTo: .body)
//                }
//                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
//
//                // Create button to toggle the week creation process
//                Button {
//                    weekCreate.toggle()
//                } label: {
//                    Image(systemName: "plus")
//
//                    .scaledFrame(width: 40, height: 40, relativeTo: .body)
//                }

//                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))

                // Done button to dismiss the view
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.body.weight(.regular))

                    .scaledFrame(width: 70, height: 40, relativeTo: .body)
                }
                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))

#if os(iOS) || os(visionOS)
                // Full-screen cover for the week creation process on iOS devices
                .fullScreenCover(isPresented: $weekCreate) {
                    WeekWorkship(color: color)
                }
#endif
            }
            else{
                // Done button to exit the edit mode
                Button {
                    withAnimation(.smoothCard){
                        edit = false
                    }
                } label: {
                    
                        Text("Done")
                            .font(.body.weight(.regular))

                            .scaledFrame(width: 70, height: 40, relativeTo: .body)

                }
                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
            }
        }
        .fixedSize()
    }
    
 
}


struct weekItem: View {
    var entity: Week
    var color: Color
    @State var dragX: Double = 0.0
    @State var dragXOffset: Double = 0.0
    @State var mid = false
    @State var hideItem = false
    @State var confirmDelete: Bool = false
    @State var haptic = false
    @State var width = 0.0
    @State var dragged = false
    @Binding var edit: Bool
    @State var enableShadow = true
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("automaticWeek") var automaticWeek = true
    @AppStorage("askToSetUpAutoSwitch") var askToSetUpAutoSwitch : Bool = true

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeSlots: FetchedResults<TimeSlot>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    
    var body: some View {
        if !hideItem{
            GeometryReader { geo in
                
                
                HStack(alignment: .center, spacing: 0) {
                    if #available(iOS 16.0, *) {
                        Image(systemName: "calendar")
                        
                            .fontWeight(.bold)
                            .foregroundColor(color)
                            .padding(.leading, 13)
                            .padding(.trailing, 6)
                    } else {
                        
                        Image(systemName: "calendar")
                        
                        
                            .foregroundColor(color)
                            .padding(.leading, 13)
                            .padding(.trailing, 6)
                    }
                    if let name = entity.name{
                        Text(name.capitalized(with: .autoupdatingCurrent) + " - ")
                            .foregroundColor(.primary)
#if os(iOS) || os(visionOS)
                            .autocapitalization(.none)
                            .textContentType(.name)
                            .transition(.blur)
                            .animation(.smooth, value: entity.name)

#endif
                    }

                        Text("Week \(entity.number)")
                            .foregroundColor(.primary)
                            .opacity(entity.name != nil ? 0.6 : 1)
#if os(iOS) || os(visionOS)
                            .autocapitalization(.none)
                            .textContentType(.name)
                            .animation(.smooth, value: entity.name)

#endif



                    Spacer()

                    Text(WeekWizard(customMessage: "from week Item (manage weeks likely)").getCurrentWeek() ?? 0 == entity.number ? "Current Week" : "")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.trailing, 2)
                        .foregroundStyle(color)


                    Image(systemName: "chevron.forward")
                    
                        .font(Font.body.bold())
                        .foregroundColor(color)
                        .padding(.leading, 6)
                        .padding(.trailing, 13)
                    
                }
                
                .frame(minHeight:  50)

                .contentShape(Rectangle())
                .offset(x: edit ? -100 : dragX + dragXOffset)
                .background(
                    
                    
                    HStack{
                        Spacer()
                        ZStack(alignment: .leading) {
                            Color.red
                        }
                        
                        .frame(width:
                                
                                edit ?
                               80
                               :
                                dragged ?
                               (-(dragX + dragXOffset)) < 80 ?
                               80:
                                (-(dragX + dragXOffset)) > geo.size.width ?
                               geo.size.width
                               :
                                -(dragX + dragXOffset)
                               
                               :
                                
                                80
                        )
                        
                        
                        //  .frame(height: 70 )
                        
                        
                        //    .frame(minHeight: 50)
                        .onTapGesture {
                            withAnimation(.smoothCard){
                                
                                // dragX = -500.0
                                
                                confirmDelete = true
                                dragX = -(geo.size.width)
                                dragXOffset = 0
                            }
                        }
                        .overlay{
                            HStack{
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .opacity(dragged || edit ? 1 : 0)
                        }
                        
                    } .opacity(dragged || edit ? 1 : 0)
                    
                    
                )
                
//                .gesture(
//                    
//                    DragGesture(minimumDistance: 30)
//                    
//                        .onChanged({ drag in
//                            print(drag.translation.width)
//                            if drag.translation.width > -250 - dragXOffset{
//                                withAnimation(.linear){
//                                    dragged = true
//                                    dragX = drag.translation.width / 1.7
//                                    haptic = false
//                                }
//                            }
//                            if drag.translation.width < -250 - dragXOffset{
//                                withAnimation(.linear){
//                                    dragX = drag.translation.width * 1.3
//                                    haptic = true
//                                }
//                            }
//                            withAnimation(.smoothCard){
//                                
//                                
//                                
//                            }
//                        })
//                        .onEnded({ drag in
//                            
//                            haptic = false
//                            if drag.translation.width < -70 && drag.translation.width > -250 - dragXOffset{
//                                withAnimation(.smoothCard){
//                                    dragX = 0.0
//                                    dragXOffset = -100
//                                    
//                                }
//                            }
//                            else if drag.translation.width > -250 - dragXOffset {
//                                withAnimation(.closeCard){
//                                    dragX = 0.0
//                                    dragXOffset = 0.0
//                                    dragged = false
//                                }
//                            }
//                            
//                            else if drag.translation.width < -250 - dragXOffset {
//                                withAnimation(.smoothCard){
//                                    
//                                    // dragX = -500.0
//                                    
//                                    confirmDelete = true
//                                    confirmDelete = true
//                                    dragX = -(geo.size.width)
//                                    dragXOffset = 0
//                                }
//                            }
//                            
//                            
//                        })
//                )
                
                
            }
            .frame(minHeight:  50)
            #if os(iOS) || os(visionOS)
            .actionSheet(isPresented: $confirmDelete) {
                ActionSheet(
                    title: Text("Are you sure you want to delete week \(entity.number)? This will delete any days in week \(entity.number) and their entries"),
                    buttons: [
                        .destructive(Text("Delete \(entity.number)")) {
                            withAnimation(.closeCard){
                                dragged = false
                                hideItem = true
                                deleteWeek(week: entity)
                            }
                            
                        },
                        
                            .cancel(){
                                withAnimation(.closeCard){
                                    dragged = false
                                    dragX = 0.0
                                    dragXOffset = 0.0
                                }
                            }
                    ]
                )
            }
            #else
            .popover(isPresented: $confirmDelete, arrowEdge: .bottom) {
                    VStack {
                        Text("Are you sure you want to delete week \(entity.number)? This will delete any days in week \(entity.number) and their entries")
                            .padding()

                        HStack {
                            Button("Delete \(entity.number)") {
                                withAnimation(.closeCard) {
                                    // Reset any necessary variables here
                                    deleteWeek(week: entity)
                                    confirmDelete = false
                                }
                            }
                            .foregroundColor(.red) // For a destructive appearance

                            Spacer()

                            Button("Cancel") {
                                withAnimation(.closeCard) {
                                    // Reset any necessary variables here
                                    confirmDelete = false
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(width: 300) // Adjust the popover width as needed
                }
            #endif
            .onChange(of: haptic) { newValue in
#if os(iOS)
                let impactMed = UIImpactFeedbackGenerator(style: .soft)
                impactMed.impactOccurred()
                #endif

            }
            
            
        }
        
    }
    
    private func deleteWeek(week: Week){
        print("attempting to delete week")
        deleteWeekContents(week: week)
        
        viewContext.delete(week)

        automaticWeek = false
        askToSetUpAutoSwitch = true
        if let fallback = weeks.last?.number {
            var weekWizard = WeekWizard(customMessage: "from week item delete func")
            weekWizard.fallback(Int(fallback))
        }
        do {
            try viewContext.save()
            print("deleted week entry")
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
    }
    
    private func deleteWeekContents(week: Week){
        print("deleting week days")
        for day in days{
            
            if day.week == week{
                deleteDayContents(week: week, day: day)
                viewContext.delete(day)
                print("deleted \(day.name) in week \(week.number)")
            }
        }
        do {
            try viewContext.save()
            print("deleted day entrys")
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func deleteDayContents(week: Week, day: Day){
        print("delete timeslots in days")
        for timeSlot in timeSlots {
            let timeSlotDay = timeSlot.day ?? Day()
            
            if timeSlotDay == day{
                let timeSlotDayWeek = timeSlotDay.week
                
                if timeSlotDayWeek == week{
                    viewContext.delete(timeSlot)
                    
                }
            }
        }
        do {
            try viewContext.save()
            print("deleted day entrys")
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
