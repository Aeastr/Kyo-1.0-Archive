//
//  WeeksView.swift
//  KyoWatch Watch App
//
//  Created by Aether on 03/11/2023.
//

import SwiftUI

struct WeeksView: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var weeks: FetchedResults<Week>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>
    @Environment(\.managedObjectContext) private var viewContext
    @State var showDays: Bool = false
    var body: some View {
        TabView {
            ForEach(weeks, id: \.self) { entity in
                VStack(spacing: 10){
                    HStack(spacing: 7){
                        Text(entity.name ?? "\(entity.number ?? -1)")
                            .fontWeight(.semibold)
                    }
                    .font(.title3)

                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 7)
                    .font(.caption2)
                    Group{
                        if entity.name != nil{
                            Text("Week \(entity.number ?? -1)")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 7)
                    .font(.footnote)
                    Group{
                        Text("Synced from Phone")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 7)
                    .font(.footnote)
                    Spacer()

//                    Button(action: {
//
//                        let daysToDelete = days.filter({ day in
//                            day.week?.id == entity.id
//                        })
//
//                        for day in daysToDelete{
//                            viewContext.delete(day)
//                        }
//
//                        viewContext.delete(entity)
//                        do {
//                            try viewContext.save()
//                            print("Data saved to Core Data")
//                        } catch {
//                            print("Failed to save data: \(error.localizedDescription)")
//                        }
//
//                    }, label: {
//                        Text("Delete Week")
//                    })

                }.safeAreaInset(edge: .bottom) {
                    HStack{
                        NavigationLink(destination: {
                            DaysView(weekEntity: entity)
                        }, label: {
                            Text("Days")
                        })
                                            Button(action: {

                                                let daysToDelete = days.filter({ day in
                                                    day.week?.id == entity.id
                                                })

                                                for day in daysToDelete{
                                                    viewContext.delete(day)
                                                }

                                                viewContext.delete(entity)
                                                do {
                                                    try viewContext.save()
                                                    print("Data saved to Core Data")
                                                } catch {
                                                    print("Failed to save data: \(error.localizedDescription)")
                                                }

                                            }, label: {
                                                Text("Delete")
                                            })
                    }
                }

            }


        }
        .tabViewStyle(.verticalPage)
        .navigationTitle("Weeks")
    }
}

struct DaysView: View {
    let weekEntity: Week
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "number", ascending: true)]) var days: FetchedResults<Day>
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        let daysToShow = days.filter({ day in
            day.week?.id == weekEntity.id
        })

            List{
                ForEach(daysToShow, id: \.self) { entity in
                    VStack{

                            Text(entity.name ?? "Untitled")
                }


            }
            .navigationTitle("Week \(weekEntity.number)")

                Button(action: {
                    for day in daysToShow{
                        viewContext.delete(day)
                    }

                    do {
                        try viewContext.save()
                        print("Data saved to Core Data")
                    } catch {
                        print("Failed to save data: \(error.localizedDescription)")
                    }
                }, label: {
                    Text("remove all")
                })
    }
}
}

#Preview {
    WeeksView()
}
