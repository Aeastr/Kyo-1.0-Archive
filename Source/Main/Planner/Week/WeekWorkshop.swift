//
//  Create Week.swift
//  KyoNeo
//
//  Created by Aether on 23/01/2023.
//

import SwiftUI
import CoreData
import AmethystUI

struct testviewagain: View {


    // Fetch requests for Core Data entities
    var onboardingMode = false
    var entity: Week?
    var editModeBackButton = true

    // Environment variable for managed object context
    @Environment(\.managedObjectContext) private var viewContext

    // Enumeration for focus field
    enum FocusField: Hashable {
    case number
    case none
    }
    enum alertStatusEnum{
        case noDays
        case overlap
        case removeDays
        case error
    }
    @State var alertStatus: alertStatusEnum = .error

    // State variables for alert, scrolling, and highlighting
    @State var alert = false
    @State var alert2 = false
    @State var scrolled: Bool = false
    @State var highlightBox = false
    @State var highlightSelector = false

    @State var weekNameText: String = ""


    // State variable for selected days - used for editing days
//    @State var selectedDays: [dayItemModel] = [
//        dayItemModel(name: "Mon", active: true, number: 0),
//    dayItemModel(name: "Tue", active: true, number: 1),
//    dayItemModel(name: "Wed", active: true, number: 2),
//    dayItemModel(name: "Thu", active: true, number: 3),
//    dayItemModel(name: "Fri", active: true, number: 4),
//    dayItemModel(name: "Sat", active: false, number: 5),
//    dayItemModel(name: "Sun", active: false, number: 6)
//    ]

    // State variable for optional integer value
    @State var number: Int?

    // Environment variable for dismiss action
    @Environment(\.dismiss) var dismiss
    @State var showCurrentWeekSelector: Bool = false

    // Color variable
    var color: Color = .red

    var body: some View {
        Text("test")
    }
}

struct WeekWorkship: View {


    // Fetch requests for Core Data entities
    var onboardingMode = false
    var entity: Week?
    var editModeBackButton = true

    // Environment variable for managed object context
    @Environment(\.managedObjectContext) private var viewContext

    // Enumeration for focus field
    enum FocusField: Hashable {
    case number
    case none
    }
    enum alertStatusEnum{
        case noDays
        case overlap
        case removeDays
        case error
    }
    @State var alertStatus: alertStatusEnum = .error

    // State variables for alert, scrolling, and highlighting
    @State var alert = false
    @State var alert2 = false
    @State var scrolled: Bool = false
    @State var highlightBox = false
    @State var highlightSelector = false

    @State var weekNameText: String = ""


    // State variable for selected days - used for editing days
//    @State var selectedDays: [dayItemModel] = [
//        dayItemModel(name: "Mon", active: true, number: 0),
//    dayItemModel(name: "Tue", active: true, number: 1),
//    dayItemModel(name: "Wed", active: true, number: 2),
//    dayItemModel(name: "Thu", active: true, number: 3),
//    dayItemModel(name: "Fri", active: true, number: 4),
//    dayItemModel(name: "Sat", active: false, number: 5),
//    dayItemModel(name: "Sun", active: false, number: 6)
//    ]

    // State variable for optional integer value
    @State var number: Int?

    // Environment variable for dismiss action
    @Environment(\.dismiss) var dismiss
    @State var showCurrentWeekSelector: Bool = false

    // Color variable
    var color: Color = .red

    // The initializer for the Week view.
    init(onboardingMode: Bool = false, entity: Week? = nil, editModeBackButton: Bool = true ,color: Color) {
        // Set the color property from the input.
        self.onboardingMode = onboardingMode
        self.color = color
        self.editModeBackButton = editModeBackButton
        // Check if the entity passed is not nil.
        if let WeekEntity = entity {
            // Set the entity property to the given WeekEntity.
            self.entity = WeekEntity
            // Set the initial value of the number property using the WeekEntity's number.
            self._number = .init(initialValue: Int(WeekEntity.number))
            self._weekNameText = .init(initialValue: WeekEntity.name ?? "")
            print("setting number \(WeekEntity.number)")
            print("setting number check \(self._number)")

            // Check if the WeekEntity has an associated set of days.
//            if let daysSet = WeekEntity.days {
//                // Set the initial value of the selectedDays property using the days in the daysSet.
//                self._selectedDays = .init(initialValue:
//                    [
//                        dayItemModel(name: "Mon", active: daysSet.contains(where: { ($0 as! Day).name == "Mon" })),
//                        dayItemModel(name: "Tue", active: daysSet.contains(where: { ($0 as! Day).name == "Tue" })),
//                        dayItemModel(name: "Wed", active: daysSet.contains(where: { ($0 as! Day).name == "Wed" })),
//                        dayItemModel(name: "Thu", active: daysSet.contains(where: { ($0 as! Day).name == "Thu" })),
//                        dayItemModel(name: "Fri", active: daysSet.contains(where: { ($0 as! Day).name == "Fri" })),
//                        dayItemModel(name: "Sat", active: daysSet.contains(where: { ($0 as! Day).name == "Sat" })),
//                        dayItemModel(name: "Sun", active: daysSet.contains(where: { ($0 as! Day).name == "Sun" }))
//                    ]
//                )
//            } else {
//                // Handle the case when no days are found.
//            }
        }

    }
    
    // This is the main view of the app, which consists of various UI components.
    var body: some View {
        // ZStack is used to layer views on top of one another.
        ZStack{
            // The background of the view is a NeoDot pattern with the specified color.

            // The main content of the view is a scrollable area.
            ScrollView{
                // This view detects and reports scrolling events.
                ScrollDetector(scrolled: $scrolled)
                // This view handles user input for numeric data.
                nameInput
                // This view allows users to select days of the week.

//                daysSelection
//                if let entity = entity{
//
//                    Text("Danger Zone")  // Displaying the text "Days"
//                        .textCase(.uppercase)  // Setting the text case to uppercase
//                        .sectionTitle(bottomPadding: 2)  // Applying a section title style with a bottom padding of 2
//                        .padding(.horizontal, 20)
//                        .foregroundStyle(Color("splitter"))
//                    Menu(content: {
//                        Button(role: .destructive) {
//                            deleteWeek(week: entity)
//
//                        } label: {
//                            Label("Delete", systemImage: "trash.fill")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                        }
//                        Button {
//
//                        } label: {
//                            Text("Cancel")
//                        }
//
//                    }, label: {
//
//                            Label("Delete", systemImage: "trash.fill")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                    })
//                    .buttonStyle(PolishedButton(role: .destructive))
//                    .padding(.horizontal, 20)
//                }
            }
            .shadow(color: .primary.opacity(0.04), radius: 15, x: 0, y: 3)
            // This assigns a coordinate space with the name "scroll" to the ScrollView.
            .coordinateSpace(name: "scroll")

            // This creates a clear (invisible) view with a height of 85 points at the top of the safe area.
            // This creates a clear (invisible) view with a height of 70 points at the bottom of the safe area.
            .safeAreaInset(edge: .top, content: {
                Color.clear.frame(height: 70)
            })
            // This adds a custom navigation bar as an overlay to the view.
            .amethystNavigationBar(title: entity == nil ? "New Week" : "Week \(number ?? -1)", titleColor: .primary,   tintColor: color, overrideType: entity == nil ? .regular : editModeBackButton ? .back : .regular, scrolled: $scrolled, content: {
                navBarContent
            }, toolbar: {

            })

            // These modifiers are specific to iOS and hide the built-in navigation bar.
    #if os(iOS) || os(visionOS)
            .navigationBarTitle("")
            .navigationBarHidden(true)
    #endif
        }
        .onDisappear{
            updateWeek()
        }
#if os(iOS) || os(visionOS)
//        .fullScreenCover(isPresented: $showCurrentWeekSelector) {
//            SetupAutomaticWeeks(color: color, navType: .regular, weekWizard: weekWizard, index: .constant(0))
//                .onDisappear{
//                    dismiss()
//                }
//        }
        #else
        .sheet(isPresented: $showCurrentWeekSelector) {
            SetupAutomaticWeeks(color: color, navType: .regular, weekWizard: weekWizard, index: .constant(0))
                .onDisappear{
                    dismiss()
                }
                .presentationCornerRadius(25)
        }
        #endif
    }


    // This view represents a custom number input field.
    var nameInput: some View {
        // VStack is used to stack views vertically.
        VStack {
            // The title of the input field, in uppercase.
            Text("Name")
                .textCase(.uppercase)
                .sectionTitle()
                .foregroundStyle(Color("splitter"))

            // Horizontal stack to hold the input field and related UI elements.
            HStack(spacing: 0) {
                // Icon for the input field.
                Image(systemName: "character.cursor.ibeam")
                    .font(Font.body.weight(.bold))
                    .foregroundColor(color)
                    .padding(.leading, 13)
                    .padding(.trailing, 5)

                TextField("Enter a name", text: $weekNameText)
                    .onSubmit {
                        updateWeek()
                    }

                // Custom number field with a placeholder, bound to a number variable.
//                CustomNumberField(placeholder: "Enter week number", number: $number, maxLength: 2)
//                    .keyboardType(.numberPad)
//                    .foregroundStyle(.primary)


    #if os(iOS) || os(visionOS)
                // iOS-specific modifiers for the input field.
                .autocapitalization(.none)
                .textContentType(.name)
                .submitLabel(.done)
    #endif

                // Modifiers to disable autocorrection and text content type.
                .textContentType(.none)
                .autocorrectionDisabled(true)

            } // End of HStack

            // Styles the number input field as a card with a neo-field appearance.
            .neoFieldCard()

        } // End of VStack

        // Adds horizontal padding to the VStack.
        .padding(.horizontal, 20)
    }

//    var daysSelection: some View {  // Declaring a computed property called daysSelection of type some View
//        VStack {  // Creating a vertical stack view
//            Text("Days")  // Displaying the text "Days"
//                .textCase(.uppercase)  // Setting the text case to uppercase
//                .sectionTitle(bottomPadding: 2)  // Applying a section title style with a bottom padding of 2
//                .foregroundStyle(Color("splitter"))
//
//            VStack(spacing: 0) {  // Creating another vertical stack view with zero spacing between its elements
//                ForEach(selectedDays) { selectedDay in  // Looping through each element in the selectedDays array
//                    dayItem(name: selectedDay.name, color: color, itemNum: selectedDays.firstIndex(where: { item in
//                        item.name == selectedDay.name
//                    }) ?? 0, selectedDays: $selectedDays)  // Creating a dayItem view with the given parameters
//                    if selectedDay.name != "Sun" {  // Checking if the name of the selected day is not "Sun"
//                        Divider()  // Displaying a divider line
//                    }
//                }
//
//            }
//            .padding(.vertical, 3)  // Adding vertical padding of 3
//            .padding(.horizontal, 3)  // Adding horizontal padding of 3
//            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
//            .background {
//                Color("NeoButton").opacity(0.6)
//                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
//                    .regularOutline()
//
//            }
//             // Clipping the view's shape to a rounded rectangle with a continuous corner style
//
//            
//
//        }
//        .padding(.horizontal, 20)  // Adding horizontal padding of 25
//    }

    

    var navBarContent: some View{
        
        HStack(spacing: 13){
            if !editModeBackButton{
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundColor(scrolled ? .primary : color)
                        .font(.body.weight(.regular))
                        .padding(11)
                }
            }
            if !editModeBackButton{
                Button {
                    if entity == nil {

                    }
                    else{
                        if willRemoveDays(){
                            alertStatus = .removeDays
                            alert = true
                        }
                        else{
                            updateWeek()
                            dismiss()
                        }
                    }
                    
                } label: {
                    Text(entity == nil ? "Create":"Save")
                        .font(.body.weight(.regular))
                    
                        .scaledFrame(width: entity == nil ?  80 : 70, height: 40, relativeTo: .body)
                    
                    
                }
                .buttonStyle(NavigationButton(color: color, scrolled: $scrolled))
//                .alert(isPresented: $alert) {
//                    switch alertStatus {
//                    case .noDays:
//                        return Alert(title: Text("Please select at least 1 day"), dismissButton: .default(Text("OK")))
//                    case .overlap:
//                        return Alert(title: Text("This week already exists"), primaryButton: .destructive(Text("Replace"), action: {
//                            
//                            replaceWeek(week: deleteWeek)
//                        }), secondaryButton: .cancel())
//                    case .removeDays:
//                        return Alert(title: Text("This will remove any entries within \(getRemovedDayNames() ?? "error")"), primaryButton: .destructive(Text("Ok"), action: {
//                            
//                            updateWeek()
//                            dismiss()
//                        }), secondaryButton: .cancel())
//                    case .error:
//                        return Alert(title: Text("Unknown error occured"), dismissButton: .default(Text("OK")))
//                    }
//                }
            }

        }


    }












    private func updateWeek() {
        /**
         * The purpose of this private function is to update the properties of the week entity,
         * including the week number, and then call the updateDaysForCurrentWeek() function to update the associated days.
         */

        if let weekEntity = entity {
            /**
             * If the week entity exists, proceed with the update.
             */

            if let selectedNumber = number {
                /**
                 * If a selectedNumber is provided and it is different from the current week number,
                 * update the week number in the entity.
                 */
                if selectedNumber != weekEntity.number {
                    entity?.number = Int64(selectedNumber)
                }
                if weekNameText != ""{
                    entity?.name = weekNameText
                }
                else{
                    entity?.name = nil
                }

            }

            if weekNameText != ""{
                entity?.name = weekNameText
            }
            else{
                entity?.name = nil
            }

            print("test")

            updateDaysForCurrentWeek()  // Call the updateDaysForCurrentWeek() function to update the associated days.
        }
    }
    func updateDaysForCurrentWeek() {
        /**
         * The purpose of this function is to update the days associated with the current week entity.
         * It adds or removes Day entities based on the selectedDays array.
         */

        guard let weekEntity = entity else { return }
        /**
         * If the week entity does not exist, return and stop the function execution.
         */

        guard let currentDays = weekEntity.days else { return }
        /**
         * Retrieve the current days associated with the week entity.
         * If there are no current days, return and stop the function execution.
         */

//        for selectedDay in selectedDays {
//            /**
//             * Iterate through each selected day to check if it needs to be added or removed.
//             */
//
//            let matchingDay = currentDays.first { ($0 as! Day).name == selectedDay.name }
//            /**
//             * Find a matching day in the current days based on the name of the selected day.
//             */
//
//            if selectedDay.active && matchingDay == nil {
//                /**
//                 * If the selected day is active (selected) and there is no matching day in the current days,
//                 * create a new Day entity, set its properties, and add it to the days relationship of the week entity.
//                 */
//                let newDay = Day(context: viewContext)
//                newDay.id = UUID()
//                newDay.number = Int16(selectedDay.number)
//                newDay.name = selectedDay.name
//                weekEntity.addToDays(newDay)
//            } else if !selectedDay.active && matchingDay != nil {
//                /**
//                 * If the selected day is not active (not selected) and there is a matching day in the current days,
//                 * remove the matching Day entity from the days relationship of the week entity and delete the entity.
//                 */
//                weekEntity.removeFromDays(matchingDay as! Day)
//                viewContext.delete(matchingDay as! Day)
//            }
//        }

        do {
            try viewContext.save()  // Save the changes made to the managed object context
        } catch {
            /**
             * If an error occurs while saving the changes to the managed object context,
             * print an error message indicating the failure to save.
             */
            print("Error saving managed object context: \(error)")
        }
    }
    func willRemoveDays() -> Bool {
        /**
         * The purpose of this function is to check if any days will be removed based on the selectedDays array.
         * It returns a boolean value indicating whether days will be removed or not.
         */

        guard let weekEntity = entity else { return false }
        /**
         * If the week entity does not exist, return false.
         */

        guard let currentDays = weekEntity.days else { return false }
        /**
         * Retrieve the current days associated with the week entity.
         * If there are no current days, return false.
         */

//        for selectedDay in selectedDays {
//            /**
//             * Iterate through each selected day to check if it needs to be removed.
//             */
//
//            let matchingDay = currentDays.first { ($0 as! Day).name == selectedDay.name }
//            /**
//             * Find a matching day in the current days based on the name of the selected day.
//             */
//
//            if !selectedDay.active && matchingDay != nil {
//                /**
//                 * If the selected day is not active (not selected) and there is a matching day in the current days,
//                 * it indicates that a day will be removed.
//                 * Return true to indicate that days will be removed.
//                 */
//                return true
//            }
//        }

        /**
         * If no day will be removed, return false.
         */
        return false
    }
    func getRemovedDayNames() -> String? {
        /**
         * The purpose of this function is to retrieve the names of the days that will be removed
         * based on the selectedDays array and the current days associated with the week entity.
         * It returns a string containing the names of the removed days, or nil if no days will be removed.
         */

        guard let weekEntity = entity else { return nil }
        /**
         * If the week entity does not exist, return nil.
         */

        guard let currentDays = weekEntity.days else { return nil }
        /**
         * Retrieve the current days associated with the week entity.
         * If there are no current days, return nil.
         */

        var removedDayNames: [String] = []
        /**
         * Create an empty array to store the names of the removed days.
         */

//        for selectedDay in selectedDays {
//            /**
//             * Iterate through each selected day to check if it needs to be removed.
//             */
//
//            let matchingDay = currentDays.first { ($0 as! Day).name == selectedDay.name }
//            /**
//             * Find a matching day in the current days based on the name of the selected day.
//             */
//
//            if !selectedDay.active && matchingDay != nil {
//                /**
//                 * If the selected day is not active (not selected) and there is a matching day in the current days,
//                 * add the name of the removed day to the removedDayNames array.
//                 */
//                removedDayNames.append((matchingDay as! Day).name!)
//            }
//        }

        /**
         * Combine the removedDayNames array into a single string based on the count of removed days.
         */

        switch removedDayNames.count {
        case 0:
            /**
             * If there are no removed days, return nil.
             */
            return nil
        case 1:
            /**
             * If there is only one removed day, return its name.
             */
            return removedDayNames[0]
        case 2:
            /**
             * If there are two removed days, return a string with their names separated by 'and'.
             */
            return "\(removedDayNames[0]) and \(removedDayNames[1])"
        default:
            /**
             * If there are more than two removed days, create a string with their names separated by commas and 'and'.
             * For example, "Monday, Tuesday, and Wednesday".
             */
            let lastDayName = removedDayNames.removeLast()
            let otherDayNames = removedDayNames.joined(separator: ", ")
            return "\(otherDayNames), and \(lastDayName)"
        }
    }

}

struct dayItem: View {
    var name: String
    var color: Color
    var itemNum: Int = 0
    @Binding var selectedDays: [dayItemModel]
    /**
     * The selectedDays array is passed as a binding to allow the state to be updated by this view.
     */

    var body: some View {

        Button {
            /**
             * When the button is pressed, toggle the active state of the corresponding dayItemModel in the selectedDays array.
             * If only one day is selected and it is being toggled off, prevent the toggle from happening.
             * Use withAnimation to animate the state change.
             */
            if selectedDays.filter({ $0.active }).count > 1 || !selectedDays[itemNum].active {
                withAnimation(.linear(duration: 0.1)){
                    selectedDays[itemNum].active.toggle()
                }

            }
        } label: {

            HStack(spacing: 0) {
                /**
                 * Create an HStack to display the day name, strikethrough if not active, and a checkmark or dashed circle to indicate the active state.
                 */

                Image(systemName: "calendar")
                    .font(Font.body.weight(.bold))
                    .foregroundColor(color)
                    .padding(.leading, 13)
                    .padding(.trailing, 6)
                    /**
                     * Display a calendar icon on the left side of the HStack.
                     */

                Text(name)
                    .strikethrough(selectedDays[itemNum].active ? false : true)
                    .foregroundColor(.primary)
                    #if os(iOS) || os(visionOS)
                        .autocapitalization(.none)
                        .textContentType(.name)
                    #endif
                    /**
                     * Display the day name as text, with a strikethrough if the day is not active.
                     * Apply platform-specific modifiers for iOS to disable autocapitalization and set the text content type to name.
                     */

                Spacer()

                Image(systemName: selectedDays[itemNum].active ? "checkmark.circle.fill" : "circle.dashed")
                    .font(Font.body.weight(.bold))
                    .foregroundColor(color)
                    .padding(.leading, 5)
                    .padding(.trailing, 13)
                    /**
                     * Display a checkmark circle or dashed circle on the right side of the HStack to indicate the active state.
                     */

            }
            .frame(minHeight: 50)
            /**
             * Set the frame and background color of the HStack.
             */
            .contentShape(Rectangle())
        }
        .buttonStyle(bounceButton())
        /**
         * Apply a custom button style to create a bounce effect when the button is pressed.
         */
    }
}

struct CustomNumberField: View {
    var placeholder: String
    @Binding var number: Int?
    var maxLength: Int
    @State var firstLoad = true
    @State private var text: String = ""

    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)],
                  predicate: NSPredicate(format: "singleDayWeek == nil OR singleDayWeek == %@", NSNumber(value: false))
    ) var weeks: FetchedResults<Week>


    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true),
                                    // Add more sort descriptors if needed
                                   ],
                  predicate: NSPredicate(format: "singleDayWeek == %@", NSNumber(value: true))
    ) var singleDayweeks: FetchedResults<Week>

    var body: some View {
        TextField(placeholder, text: $text)
            .textContentType(.none)
            .onReceive(text.publisher.collect()) { newText in
                if !firstLoad{
                    /**
                     * This CustomNumberField view is used in the numberField previously mentioned
                     * It provides a custom number input field with a specified maximum length and validation.
                     * The binding to the 'number' variable allows the entered number to be accessed externally.
                     * The 'placeholder' parameter is used as the placeholder text for the TextField.
                     */
                    self.text = "\(number ?? 0)"
                    let filtered = newText.filter { "0"..."9" ~= $0 }
                    /**
                     * Filter the input text to allow only digits (0-9).
                     */

                    if filtered.count <= maxLength {
                        /**
                         * If the filtered text length is less than or equal to the maximum length,
                         * convert the filtered text to an integer value.
                         * If the integer value is greater than 52, set the text to "52" to enforce the maximum value.
                         * Otherwise, set the text to the filtered text.
                         */
                        let intValue = Int(String(filtered)) ?? 0
                        if intValue > 52 {
                            self.text = "52"
                        } else {
                            self.text = String(filtered)
                        }
                    } else {
                        /**
                         * If the filtered text length exceeds the maximum length,
                         * set the text to the prefix of the filtered text with the maximum length.
                         */
                        self.text = String(filtered.prefix(maxLength))
                    }

                    self.number = Int(self.text)
                    /**
                     * Update the 'number' binding with the parsed integer value from the text.
                     */
                }
            }
            .onAppear{
                if let number = number{
                    print("setting number box \(number)")
                    self.text = "\(number)"
                }
                else{
                    print("setting number box \(weeks.count + 1)")
                        self.text = "\(weeks.count + 1)"
                }
                firstLoad = false

            }
    }
}

