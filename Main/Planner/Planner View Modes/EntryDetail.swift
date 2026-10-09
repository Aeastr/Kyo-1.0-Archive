//
//  EntryDetail.swift
//  KyoNeo
//
//  Created by Aether on 04/08/2023.
//

import SwiftUI
import AmethystUI

struct EntryDetailSuper: View {
	@ObservedObject var timeSlot: TimeSlot
	@State var currentState: timeState = .upcoming
	@Environment(\.dismiss) var dismiss

	@AppStorage("global_Compact") var global_Compact  = false
	@FetchRequest(sortDescriptors: [NSSortDescriptor(key: "due", ascending: true)]) var tasks: FetchedResults<TaskEntity>
	@FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeSlots: FetchedResults<TimeSlot>

	var body: some View {
		ScrollView{
			LazyVStack{

								let totalTasks = tasks.filter{ item in
									return item.classEntity == timeSlot.classEntity && !item.archived
								}

								if !totalTasks.isEmpty{
									Text("Tasks")
									 .sectionTitle()
								}

								VStack(spacing: global_Compact ? 0 : 8){
									ForEach(totalTasks, id: \.id){ task in
										TaskItem(data: task)
									}
								}.padding(.horizontal, 5)

								Text("Other Instances")
									.sectionTitle()
									.padding(.horizontal, 20)


								let otherInstancesSet = Set(timeSlots.filter { item in
									return item.classEntity == timeSlot.classEntity && item != timeSlot
								}).sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() })


								VStack(spacing: global_Compact ? 0 : 8){
									ForEach(Array(otherInstancesSet), id: \.id){ instance in
										EntryBlock(timeSlot: instance, shownTimeSlot: .constant(nil), viewTimeSlot: .constant(nil), classForTask: .constant(timeSlot.classEntity), shareTimeSlot: .constant(nil), editMode: .constant(false), imageMode: true)
											.allowsHitTesting(false)
										.padding(.horizontal, -15)
									}
								}
							}
			.padding(.horizontal, 17)
		}

	}
}


struct EntryDetail: View {
	var timeSlot: TimeSlot
	var currentState: timeState
	@Environment(\.dismiss) var dismiss
	@Environment(\.colorScheme) var colorScheme

	var size: CGSize
	var safeArea: EdgeInsets

	@State private var offsetY: CGFloat = 0
	@State private var velocityG: CGFloat = 0
	@AppStorage("global_Compact") var global_Compact  = false
	@FetchRequest(sortDescriptors: [NSSortDescriptor(key: "due", ascending: true)]) var tasks: FetchedResults<TaskEntity>

	@FetchRequest(sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: true)]) var timeSlots: FetchedResults<TimeSlot>

	var body: some View {
		ScrollView{
			VStack(spacing: 0){
				

				SampleView()
					.zIndex(1)
			}
			.background{
#if !os(macOS)
				ScrollDetectorNew { offset, velocity in
					offsetY = -offset
					velocityG = velocity
				} onDraggingEnd: { offset, velocity in
				}
				#endif

			}

		}

	}

	@ViewBuilder
	func HeaderView() -> some View{
		let headerHeight = (size.height * 0.3) + safeArea.top
		let minHeaderHeight = 115 + safeArea.top

		let primaryColour = Color(hex: timeSlot.classEntity?.color1 ?? timeSlot.splitterEntity?.color1 ?? "")
		let secondaryColour = Color(hex: timeSlot.classEntity?.color2 ?? timeSlot.splitterEntity?.color2 ?? "")
		let isBright = primaryColour.isBright()

		let progress = max(min(-offsetY / (headerHeight - (minHeaderHeight + 40)), 1), 0)
		let progress2 = max(min(-offsetY / (headerHeight - (minHeaderHeight + 20)), 1), 0)

		ZStack(alignment: .bottomLeading){
			//			Image("doodle1")
			//										.resizable()
			//										.aspectRatio(contentMode: .fill)
			//										.foregroundStyle(LinearGradient(gradient: Gradient(colors: [isBright ? primaryColour.darken(by: 0.5) : Color.white, Color.clear]), startPoint: .top, endPoint: .bottom))
			//										.opacity(0.15)
			//										.background(LinearGradient(gradient: Gradient(colors: [primaryColour, secondaryColour]), startPoint: .topLeading, endPoint: .bottomTrailing))
			LinearGradient(gradient: Gradient(colors: [primaryColour, secondaryColour]), startPoint: .topLeading, endPoint: .bottomTrailing)
			#if os(visionOS)
				.opacity(0.55)
			#endif
				.animation(.smooth, body: { body in
					body.frame(height: (headerHeight + offsetY) < minHeaderHeight ? minHeaderHeight : (headerHeight + offsetY))
				})
//				.opacity(1 - Double((0.4) * progress))
				.mask{
					LinearGradient(stops: [Gradient.Stop(color: Color.white, location: 0),  Gradient.Stop(color: Color.white.opacity(1), location: 1.0)], startPoint: .top, endPoint: .bottom)
				}
				.overlay{
					Image("doodle1")
						.resizable()
						.aspectRatio(contentMode: .fill)
						.foregroundStyle(LinearGradient(gradient: Gradient(colors: [isBright ? primaryColour.darken(by: 0.5) : primaryColour.lighten(by: colorScheme == .light ? 0.5 : -0.1), Color.clear]), startPoint: .top, endPoint: .bottom))
						.opacity(0.15)
				}
				.background(.ultraThinMaterial)

				.clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

			VStack(alignment: .leading){
				Text((timeSlot.classEntity?.name ?? timeSlot.splitterEntity?.name ?? "Untitled Class").shortenedClassName(maxLength: 16))
					.lineLimit(1)
					
					.font(.largeTitle.weight(.semibold).width(.expanded))
					.frame(maxWidth: .infinity, alignment: .leading)




				Group{
					switch currentState {
					case .error:
						Group{
							Text("State Error")
								.font(.caption.weight(.regular))
						}
					case .upcoming:
						Group{
							Text(timeSlot.startTime ?? "")
								.font(.caption.weight(.regular))
							+
							Text(" - ")
								.font(.caption.weight(.regular))
							+
							Text(timeSlot.endTime ?? "")
								.font(.caption.weight(.regular))
						}
					case .upcomingOnOtherDay:
						Group{
							Text("State Error")
								.font(.caption.weight(.regular))
						}
					case .past:

						Group{
							Text("Ended ")
								.font(.caption.weight(.regular))
							+
							Text(timeSlot.endTime ?? "")
								.font(.caption.weight(.regular))
						}
					case .current:
						HStack{
							Text("\("Remaining") \(TimeFormatter.toDate((timeSlot.endTime ?? "")) ?? Date(), style: .timer)")
								.monospacedDigit()
								.font(.caption.weight(.regular))



							Spacer()
							Text(Image(systemName: "arrow.right"))
								.font(.caption.weight(.light))
							+
							Text(" " + (timeSlot.endTime ?? ""))
								.font(.caption.weight(.regular))
						}.textCase(.uppercase)
							.animation(.smooth)
					case .today:
						Group{
							Text("State Error")
								.font(.caption.weight(.regular))
						}
					default:
						EmptyView()
					}
				}



				if (timeSlot.room != "" || timeSlot.taughtBy != nil) {
					HStack(spacing: 3){
						if let room = timeSlot.room, timeSlot.room != "" && findURL(in: room) == nil{
							Group{
								Text(Image(systemName: "square.split.bottomrightquarter"))
									.font(.caption.weight(.regular))
								+ Text(" ")
									.font(.caption)
								+ Text((room) + (timeSlot.taughtBy != nil ? "," : ""))
									.font(.caption.weight(.regular))
							}
						}
						else if let room = timeSlot.room, findURL(in: room) != nil{
							Group{
								Text(Image(systemName: getIconForURL(room)))
									.font(.caption.weight(.regular))
								+ Text(" ")
									.font(.caption)
								+ Text((cleanUpURLForDisplay(room).shortenedClassName(maxLength: 23)) + (timeSlot.taughtBy != nil ? "," : ""))
									.font(.caption.weight(.regular))
							}
						}
						if timeSlot.taughtBy != nil, let teacher = timeSlot.taughtBy?.name {
							Group{
								Text(Image(systemName: "person"))
									.font(.caption.weight(.regular))
								+ Text(" ")
									.font(.caption)
								+ Text((teacher))
									.font(.caption.weight(.regular))
							}
						}
					}


				}
			}
			.padding(.horizontal, 20)
			.padding(.bottom, 13)
			.foregroundStyle(primaryColour.lighten(by: (0.75) - ((colorScheme == .light ? 1.25 : -4) * max(min(-offsetY / (headerHeight - (minHeaderHeight + 80)), 1), 0))))
		}
		
		.animation(.smooth) { body in
			body
				.frame(height: (headerHeight + offsetY) < minHeaderHeight ? minHeaderHeight : (headerHeight + offsetY))
				.offset(y: -offsetY)

		}

//		.shadow(color: primaryColour.opacity(0.3), radius: 10, y: 2)
		//		.frame(height: (headerHeight + offsetY) < minHeaderHeight ? minHeaderHeight : (headerHeight + offsetY))
	}


	@ViewBuilder
	func SampleView() -> some View{
		LazyVStack{

			let totalTasks = tasks.filter{ item in
				return item.classEntity == timeSlot.classEntity && !item.archived
			}

			if !totalTasks.isEmpty{
				Text("Tasks")
				 .sectionTitle()
			}

			VStack(spacing: global_Compact ? 0 : 8){
				ForEach(totalTasks, id: \.id){ task in
					TaskItem(data: task)
				}
			}.padding(.horizontal, 5)

			Text("Other Instances")
				.sectionTitle()
				.padding(.horizontal, 20)


			var otherInstancesSet = Set(timeSlots.filter { item in
				return item.classEntity == timeSlot.classEntity && item != timeSlot

			})


			VStack(spacing: global_Compact ? 0 : 8){
				ForEach(Array(otherInstancesSet), id: \.id){ instance in
					EntryBlock(timeSlot: instance, shownTimeSlot: .constant(nil), viewTimeSlot: .constant(nil), classForTask: .constant(timeSlot.classEntity), shareTimeSlot: .constant(nil), editMode: .constant(false), imageMode: true)

					.padding(.horizontal, -15)
				}
			}
		}


		Color.clear.frame(height: 900)
	}
}

#if !os(macOS)
/**
 This structure `ScrollDetectorNew` is designed to integrate UIKit's `UIScrollView` capabilities within a SwiftUI `ScrollView`.
 It allows for the monitoring of the scroll offset and velocity, which are not directly accessible in SwiftUI's `ScrollView`.
 This is achieved by utilizing `UIViewRepresentable` to bridge UIKit components within SwiftUI.
 The structure has two main closures: `onScroll` for handling real-time scroll events and `onDraggingEnd` for handling events when the dragging ends.
 */

/// Extracting UIScrollView from SwiftUI ScrollView for monitoring offset and velocity
struct ScrollDetectorNew: UIViewRepresentable {
	/// Closure executed when the scroll view is scrolled.
	var onScroll: (CGFloat, CGFloat) -> ()
	/// Closure executed when the dragging of the scroll view ends, providing offset and velocity.
	var onDraggingEnd: (CGFloat, CGFloat) -> ()

	/// Creates a coordinator to manage the communication between the SwiftUI view and the UIKit view.
	func makeCoordinator() -> Coordinator {
		return Coordinator(parent: self)
	}

	/// Creates a dummy UIView as a placeholder, since the actual UIScrollView will be accessed from the superview hierarchy.
	func makeUIView(context: Context) -> some UIView {
		return UIView()
	}

	/// Updates the UIView and sets up the UIScrollView delegate.
	func updateUIView(_ uiView: UIViewType, context: Context) {
		DispatchQueue.main.async {
			/// Attempt to find the UIScrollView in the superview hierarchy and set its delegate if not already done.
			if let scrollview = uiView.superview?.superview?.superview as? UIScrollView, !context.coordinator.isDelegateAdded {
				/// Setting the delegate for the UIScrollView to handle scroll events.
				scrollview.delegate = context.coordinator
				/// Marking delegate as added to prevent multiple assignments.
				context.coordinator.isDelegateAdded = true
			}
		}
	}

	/// Coordinator class to act as UIScrollViewDelegate and handle scroll-related delegate methods.
	class Coordinator: NSObject, UIScrollViewDelegate {
		/// Reference to the parent `ScrollDetectorNew` structure.
		var parent: ScrollDetectorNew

		private var decelerationTimer: Timer?

		/// Initializer with reference to the parent structure.
		init(parent: ScrollDetectorNew) {
			self.parent = parent
		}

		/// Flag to check if the UIScrollView delegate is already set.
		var isDelegateAdded: Bool = false

		/// Delegate method called when the UIScrollView is scrolled.
		func scrollViewDidScroll(_ scrollView: UIScrollView) {
			/// Invoke the `onScroll` closure with the current vertical offset.



			parent.onScroll(scrollView.contentOffset.y, 0.0)
		}


		func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
			// Invalidate the timer when the user starts dragging again
			decelerationTimer?.invalidate()
		}

		func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
			parent.onDraggingEnd(targetContentOffset.pointee.y, velocity.y)
			//
			//				// Start with the initial velocity
			//				var currentVelocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y / 10
			//
			//				// Use a timer to periodically update the velocity
			//				decelerationTimer?.invalidate()
			//				decelerationTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
			//					guard let self = self else { return }
			//					print("end")
			//
			//					// Apply a deceleration formula
			//					let decelerationFactor = 0.95
			//					currentVelocity *= decelerationFactor
			//
			//					// Update the parent with the new velocity
			//					self.parent.onDraggingEnd(targetContentOffset.pointee.y, currentVelocity)
			//
			//					// Stop the timer if velocity is near zero or user starts dragging again
			//					if abs(currentVelocity) < 0.1 {
			//						self.parent.onDraggingEnd(targetContentOffset.pointee.y, 0.0)
			//						self.decelerationTimer?.invalidate()
			//					}
			//				}
			//				RunLoop.current.add(decelerationTimer!, forMode: .common)
		}
	}
}
#endif
