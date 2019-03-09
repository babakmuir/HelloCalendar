//
//  PageViewController.swift
//  HelloCalendar
//
//  Created by B.Mossavi on 1/20/19.
//  Copyright © 2019 B.Mossavi. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {
    var vc: CalendarViewController!
    override func viewDidLoad() {
        super.viewDidLoad()

        vc = (storyboard?.instantiateViewController(withIdentifier: "ViewController") as! CalendarViewController)
     
        setViewControllers([vc], direction: .forward, animated: true, completion: nil)
        self.delegate = self
        self.dataSource = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension PageViewController: UIPageViewControllerDelegate {
    // TODO:
}
extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
         vc.calendarView.scrollToSegment(.next)
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
         vc.calendarView.scrollToSegment(.previous)
        return vc
    }
}
