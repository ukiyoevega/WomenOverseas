//
//  calendarView.swift
//  WMO
//
//  Created by jia on 2023/4/20.
//

import SwiftUI

private let dateTextSize: CGFloat = 15
private let earlierDateTextColor = Color(hex: "BDBDBD")
private let dateTextColor = Color(hex: "1E2123")
private let chevronSize: CGFloat = 10
private let numberTextSize: CGFloat = 15
private let weekdayTextSize: CGFloat = 12
private let gridVerticalSpacing: CGFloat = 1
private let highlightCircleWdith: CGFloat = 27
private let dotSize: CGFloat = 4
private let signedDotColor: Color = Color(hex: "D57A58")
private let unsignDotColor: Color = Color(hex: "9EB83B")
private let dotTextSpacing: CGFloat = 8
private let cubeHeight: CGFloat = 36
private let headerDaysSpacing: CGFloat = 10
private let titleDaySpacing: CGFloat = 12

private struct NumberedDate: Identifiable {
  let id = UUID().uuidString
  let day: Int
  let date: Date?
}

struct CustomDatePicker: View {
  @State private var selectedMonth: Int = 0

  @Binding var selectedDate: Date
  @Binding var events: [Topic]

  private var currentMonthDate: Date {
    let current = Calendar.current.date(byAdding: .month, value: selectedMonth, to: Date())
    return current ?? Date()
  }

  private var numberedDates: [NumberedDate] {
    var days = currentMonthDate.daysInMonth.compactMap { date -> NumberedDate in
      let day = Calendar.current.component(.day, from: date)
      let dateValue =  NumberedDate(day: day, date: date)
      return dateValue
    }
    let firstWeekday = Calendar.current.component(.weekday, from: days.first?.date ?? Date())
    for _ in 0..<firstWeekday - 1 {
      days.insert(NumberedDate(day: 0, date: nil), at: 0)
    }
    return days
  }

  var body: some View {
    VStack(spacing: headerDaysSpacing) {
      calendarHeader()
      LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: gridVerticalSpacing) {
        ForEach(numberedDates) { numberedDate in
          CubeView(cube: numberedDate)
            .onTapGesture {
              if let date = numberedDate.date {
                selectedDate = date
              }
            }
        }
      }
    }
    .padding()
    .background(Color.white)
    .onChange(of: selectedMonth) { newValue in
      selectedDate = currentMonthDate
    }
  }

  @ViewBuilder
  private func CubeView(cube: NumberedDate) -> some View {
    let isSelectedDate = Calendar.current.isDate(cube.date ?? selectedDate, inSameDayAs: selectedDate)
    let isToday = Calendar.current.isDate(cube.date ?? selectedDate, inSameDayAs: Date())
    var isEarlierDate = cube.date == nil ? true : (cube.date! < Date() && !isToday)
    VStack(spacing: dotTextSpacing) {
      let cubeEvents = events.filter { topic in
        if let startDate = topic.eventStartDate {
          return Calendar.current.isDate(startDate, inSameDayAs: cube.date ?? Date())
        }
        return false
      }
      let dateTextColor = isEarlierDate ? earlierDateTextColor : dateTextColor
      Text("\(cube.day)")
        .opacity(cube.day > 0 ? 1 : 0)
        .font(.system(size: numberTextSize, weight: .medium))
        .foregroundColor(isSelectedDate ? .white : dateTextColor) // selected day -> white text
        .background(
          Circle()
            .fill(Color.eventHighlight)
            .frame(width: highlightCircleWdith, height: highlightCircleWdith)
            .opacity(cube.day > 0 && isSelectedDate ? 1 : 0)
        ) // selected day -> blue highlight
        .frame(maxWidth: .infinity)
      HStack(spacing: dotSize) {
        ForEach(cubeEvents) { event in
          Circle()
            .fill(unsignDotColor)
            .frame(width: dotSize, height: dotSize)
        }
      }
    }
    .frame(height: cubeHeight, alignment: .top)
  }

  @ViewBuilder
  private func calendarHeader() -> some View {
    VStack(spacing: titleDaySpacing) {
      HStack() {
        Button {
          selectedMonth -= 1
        } label: {
          Image(systemName: "chevron.left")
            .foregroundColor(.black)
            .font(Font.system(size: chevronSize))
        }
        Spacer()
        Text(selectedDate.calendarTitle)
          .font(Font.system(size: dateTextSize, weight: .bold))
          .foregroundColor(.black)
        Spacer()
        Button {
          selectedMonth += 1
        } label: {
          Image(systemName: "chevron.right")
            .foregroundColor(.black)
            .font(Font.system(size: chevronSize))
        }
      }
      HStack() {
        ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
          Text(String(day.first ?? "A"))
            .font(.system(size: weekdayTextSize, weight: .medium))
            .frame(maxWidth: .infinity)
            .foregroundColor(.black)
        }
      }
    }
  } // header
}

#if DEBUG
struct calendarView_Previews: PreviewProvider {
  static var previews: some View {
    CustomDatePicker(selectedDate: .constant(Date()), events: .constant([]))
  }
}
#endif
