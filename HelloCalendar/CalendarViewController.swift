//
//  ViewController.swift
//  HelloCalendar
//
//  Created by B.Mossavi on 1/11/19.
//  Copyright © 2019 B.Mossavi. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Foundation

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    let outsideMonthColor = UIColor(colorWithHexValue: 0xA18BBE)
    let monthColor = UIColor.white
    let selectedMonthColor = UIColor(colorWithHexValue: 0x3a294b)
    let currentDateSelectedViewColor = UIColor(colorWithHexValue: 0x4e3f5d)
    
    let date = Date()
    
    var eventsFromTheServer: [String:String] = [:]
    
    var firstDate: Date?
    var rangeSelectedDates: [Date] = []
    var testCalendar = Calendar.current
    
    let persianCalendar = Calendar(identifier: .persian)
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "hh:mm"
        return dateFormatter
    }()
    
    var persianDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .persian)
//        dateFormatter.locale = Locale(identifier: "fa_IR")
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter
    }()
    
    var data = Data()
    var jsonResult = [String: AnyObject]()
    var eventArray = [Events]()
    
    var dateSelected = 0
    var monthSelected = 0
    var yearSelected = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        calendarView.scrollToDate(Date())
        setupCalendarView()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            
            let serverObjects = self.getServaerEvents()
            
            for (date, event) in serverObjects {
                
                let stringDate = self.persianDateFormatter.string(from: date)
                
                self.eventsFromTheServer[stringDate] = event
                
            }
            
            DispatchQueue.main.async {
                
                self.calendarView.reloadData()
                
            }
            
        }
        
        
//      MARK: GestureRecognizer
//        calendarView.allowsMultipleSelection  = true
//        let panGensture = UILongPressGestureRecognizer(target: self, action: #selector(didStartRangeSelecting(gesture:)))
//        panGensture.minimumPressDuration = 0.5
//        calendarView.addGestureRecognizer(panGensture)
//        calendarView.isRangeSelectionUsed = true
        
//        let doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapCollectionView(gesture:)))
//        doubleTapGesture.numberOfTapsRequired = 2  // add double tap
//        calendarView.addGestureRecognizer(doubleTapGesture)
        
        
        
        //MARK: JSON
        if let path = Bundle.main.path(forResource: "Events", ofType: "json") {

            do {

                data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)

                jsonResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject]

                JSONReader()

            } catch {

                print(error)

            }

        }
        
    }
    
    //MARK: JSONReader
    func JSONReader() {
        
        if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
            
            guard let events = jsonResult["events"] as? [[String: AnyObject]] else { return }

                for event in events {

                    let eventClass = Events()

                    eventClass.holiday = event["holiday"] as! Bool
                    eventClass.year = event["year"] as! Int
                    eventClass.month = event["month"] as! Int
                    eventClass.day = event["day"] as! Int
                    eventClass.type = event["type"] as! String
                    eventClass.title = event["title"] as! String
                    
                    eventArray.append(eventClass)

                }
            
        }
        
    }
    
    
    
    
    //MARK: TapGesture
    @objc func didDoubleTapCollectionView(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: gesture.view!)
        _ = calendarView.cellStatus(at: point)
//        print(cellState!.date)
    }
    
    //MARK: TapGesture
    @objc func didStartRangeSelecting(gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: gesture.view!)
        rangeSelectedDates = calendarView.selectedDates
        if let cellState = calendarView.cellStatus(at: point) {
            let date = cellState.date
            if !rangeSelectedDates.contains(date) {
                let dateRange = calendarView.generateDateRange(from: rangeSelectedDates.first ?? date, to: date)
                for aDate in dateRange {
                    if !rangeSelectedDates.contains(aDate) {
                        rangeSelectedDates.append(aDate)
                    }
                }
                calendarView.selectDates(from: rangeSelectedDates.first!, to: date, keepSelectionIfMultiSelectionAllowed: true)
            } else {
                let indexOfNewlySelectedDate = rangeSelectedDates.index(of: date)! + 1
                let lastIndex = rangeSelectedDates.endIndex
                let followingDay = persianCalendar.date(byAdding: .day, value: 1, to: date)!
                calendarView.selectDates(from: followingDay, to: rangeSelectedDates.last!, keepSelectionIfMultiSelectionAllowed: false)
                rangeSelectedDates.removeSubrange(indexOfNewlySelectedDate..<lastIndex)
            }
        }
        
        if gesture.state == .ended {
            rangeSelectedDates.removeAll()
        }
    }
    
    
    
    func setupCalendarView() {
        
        // Setup Calendar Spacing
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        // Setup Labels
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        calendarView.semanticContentAttribute = .forceRightToLeft
        
    }
    
    
    
    
    //MARK: Handle Cell Text Color    
    func handleCellTextColor(cell: JTAppleCell?, cellState: CellState){
        guard let validCell = cell as? CustomCell else { return }
        if cellState.isSelected {
            validCell.dateLabel.textColor = selectedMonthColor
        } else {
            let today = Date()
            persianDateFormatter.dateFormat = "yyyy MM dd"
            let todayDateStr = persianDateFormatter.string(from: today)
            persianDateFormatter.dateFormat = "yyyy MM dd"
            let cellDateStr = persianDateFormatter.string(from: cellState.date)
            
            if todayDateStr == cellDateStr {
                validCell.dateLabel.textColor = UIColor.yellow
            } else {
                if cellState.dateBelongsTo == .thisMonth {
                    validCell.dateLabel.textColor = monthColor
                } else { //i.e. case it belongs to inDate or outDate
                    validCell.dateLabel.textColor = outsideMonthColor
                }
            }
        }
    }
    
    
    
    
    //MARK: Handle Cell Selected
    func handleCellSelected(view: JTAppleCell?, cellState: CellState) {
        
        guard let validCell = view as? CustomCell else { return }
        
        switch cellState.selectedPosition() {
            
        case .full:
            validCell.selectedView.isHidden = false
            validCell.selectedView.backgroundColor = UIColor.yellow
            // Or you can put what ever you like for your rounded corners, and your stand-alone selected cell
            
        case .middle:
            validCell.selectedView.isHidden = false
            validCell.selectedView.backgroundColor = UIColor.blue
            validCell.dateLabel.textColor = UIColor.white// Or what ever you want for your dates that land in the middle
            
        case .left:
            validCell.selectedView.isHidden = false
            validCell.selectedView.backgroundColor = UIColor.yellow
            validCell.dateLabel.textColor = UIColor.black
            
        case .right:
            validCell.selectedView.isHidden = false
            validCell.selectedView.backgroundColor = UIColor.yellow
            validCell.dateLabel.textColor = UIColor.black
            
        default:
            validCell.selectedView.isHidden = true
            validCell.selectedView.backgroundColor = nil // Have no selection when a cell is not selected
        }
        
        dateSelected = Int(validCell.dateLabel.text!)!
        
        let events = Events(year: yearSelected, month: monthSelected, day: dateSelected)
        
        findEvent(events: events)

    }
    
    
    
    
    
    //MARK: Year and Month Label
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        
//        persianDateFormatter.dateFormat = "yyyy MM dd"
        
        let date = visibleDates.monthDates.first!.date
        
        self.dateFormatter.dateFormat = "yyyy"
        self.year.text = self.dateFormatter.string(from: date)
        
        let yearFormat = self.dateFormatter.string(from: date)
        
        yearSelected = Int(yearFormat)!
        
        
        self.persianDateFormatter.dateFormat = "MMMM"
        self.month.text = monthTranslate(monthString: self.persianDateFormatter.string(from: date))
        
        self.persianDateFormatter.dateFormat = "M"
        
        let monthFormat = self.persianDateFormatter.string(from: date)
        
        monthSelected = Int(monthFormat)!
        
    }
    
    func findEvent(events: Events) {
        
        for event in eventArray {
            
            if event.year == events.year && event.month == events.month && event.day == events.day {
                
                print("day: \(events.day) month: \(monthSelected) year: \(yearSelected)")
                
                print("\(event.title)")
                
                titleLabel.text = event.title
                
                break
                
            } else {
                
            }
            
        }
        
    }
    
    func monthTranslate(monthString: String) -> String {
        
        var persianMonth = ""
        
        switch monthString {
            
        case "Farvardin" :
         
            persianMonth = "فروردین"
            
        case "Ordibehesht" :
            
            persianMonth = "اردیبهشت"
            
        case "Khordad" :
            
            persianMonth = "خرداد"
            
        case "Tir" :
            
            persianMonth = "تیر"
            
        case "Mordad" :
            
            persianMonth = "مرداد"
            
        case "Shahrivar" :
            
            persianMonth = "شهریور"
            
        case "Mehr" :
            
            persianMonth = "مهر"
            
        case "Aban" :
            
            persianMonth = "آبان"
            
        case "Azar" :
            
            persianMonth = "آذر"
            
        case "Dey" :
            
            persianMonth = "دی"
            
        case "Bahman" :
            
            persianMonth = "بهمن"
            
        case "Esfand" :
            
            persianMonth = "اسفند"
            
        default:
            
            persianMonth = ""
            
        }
        
        return persianMonth
        
    }
    
    func configureCell(cell: JTAppleCell?, cellState: CellState) {
        
        guard let myCustomCell = cell as? CustomCell else { return }
        
        dateFormatter.dateFormat = "yyyy MM dd"
        
        handleCellEvents(cell: myCustomCell, cellState: cellState)
        
    }
    
    func handleCellEvents(cell: CustomCell, cellState: CellState) {
        
        cell.eventDotView.isHidden = !eventsFromTheServer.contains { $0.key == persianDateFormatter.string(from: cellState.date)}
        
    }
    
    func getServaerEvents() -> [Date:String] {

        persianDateFormatter.dateFormat = "yyy MM dd"

        return [

            persianDateFormatter.date(from: "1397 12 21")!: "Happy Birth Day",
            
            persianDateFormatter.date(from: "1397 12 22")!: "Chrismas Special",
            
            persianDateFormatter.date(from: "1397 12 23")!: "this lib is awesome",
            
            persianDateFormatter.date(from: "1397 12 24")!: "I got a cat"

        ]

    }
    
}





extension CalendarViewController: JTAppleCalendarViewDataSource {
    
    //MARK: configure calendar
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.timeZone = persianCalendar.timeZone
//        dateFormatter.locale = Locale(identifier: "fa_IR")
        dateFormatter.calendar = persianCalendar
        
//        print(dateFormatter.string(from: date))
        
        let startDate = dateFormatter.date(from: "1395/01/01")!
        let endDate = dateFormatter.date(from: "1399/12/28")!
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 6,
                                                 calendar: persianCalendar,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .tillEndOfGrid,
                                                 firstDayOfWeek: .saturday)
        
        return parameters
        
    }
    
    
    //MARK: willDisplay
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        handleCellSelected(view: cell, cellState: cellState)
    }
    
}

extension CalendarViewController: JTAppleCalendarViewDelegate {
    
    //MARK: Cell
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.dateLabel.text = cellState.text
        
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
        
        return cell
        
    }
    
    //MARK: SelectDate
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
        
        //MARK: Range Selection
        if firstDate != nil {
            calendarView.selectDates(from: firstDate!, to: date,  triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
        } else {
            firstDate = date
        }
        
    }
    
    //MARK: DidselectDate
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
    
}

extension UIColor {
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
