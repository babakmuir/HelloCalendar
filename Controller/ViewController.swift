//
//  ViewController.swift
//  HelloCalendar
//
//  Created by B.Mossavi on 3/1/19.
//  Copyright © 2019 B.Mossavi. All rights reserved.
//

import UIKit

struct EventItem {
    
    var title = ""
    var subtitle = ""
    var data1 = ""
    var data2 = ""
    
}

class EventCell: UITableViewCell {
    @IBOutlet weak var data1: UILabel!
    @IBOutlet weak var data2: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var menuView: UIViewX!
    @IBOutlet weak var chatButton: UIImageView!
    @IBOutlet weak var pencilButton: UIImageView!
    @IBOutlet weak var clockButton: UIImageView!
    @IBOutlet weak var dayView: UIStackView!
    @IBOutlet weak var weatherView: UIStackView!
    @IBOutlet weak var tabelView: UITableView!
    
    let array = ["num1", "num2", "num3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        closeMenu()
        setaupAnimationsControls()
        
        tabelView.delegate = self
        tabelView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            self.dayView.transform = .identity
            self.weatherView.transform = .identity
        }) { (success) in
            
        }
        
        animateTableCells()
        
        let imageTappedGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped))
        
        chatButton.isUserInteractionEnabled = true
        
        chatButton.addGestureRecognizer(imageTappedGestureRecognizer)
                
    }

    @IBAction func menuTapped(_ sender: FloatingActionButton) {
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.menuView.transform == .identity {
                self.closeMenu()
            } else {
                self.menuView.transform = .identity
            }
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: [], animations: {
            if self.menuView.transform == .identity {
                self.pencilButton.transform = .identity
                self.chatButton.transform = .identity
                self.clockButton.transform = .identity
            }
        })
    }
    
    @objc func imageTapped() {
        
        chatButton.transform = CGAffineTransform(translationX: 5, y: 5)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            if self.menuView.transform == .identity {
                self.chatButton.transform = .identity
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
            self.performSegue(withIdentifier: "toCalendar", sender: self)
            
        }
        
    }
    
    func closeMenu() {
        menuView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        pencilButton.transform = CGAffineTransform(translationX: 0, y: 15)
        chatButton.transform = CGAffineTransform(translationX: 11, y: 11)
        clockButton.transform = CGAffineTransform(translationX: 15, y: 0)
    }
    
    func setaupAnimationsControls() {
        dayView.transform = CGAffineTransform(translationX: dayView.frame.width, y: 0)
        weatherView.transform = CGAffineTransform(translationX: -weatherView.frame.width, y: 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tabelView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath) as! EventCell

        cell.titleLabel.text = array[indexPath.row]
        cell.subtitleLabel.text = array[indexPath.row]
        cell.data1.text = array[indexPath.row]
        cell.data2.text = array[indexPath.row]

        return cell

    }
    
    func animateTableCells() {
        
        let cells = tabelView.visibleCells
        
        for cell in cells {
            
            cell.transform = CGAffineTransform(translationX: cell.frame.width, y: 0)
            
        }
        
        var delay = 0.5
        
        for cell in cells {
            
            UIView.animate(withDuration: 0.2, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: [], animations: {
                cell.transform = .identity
            })
            
            delay += 0.15
            
        }
        
    }
    
}
