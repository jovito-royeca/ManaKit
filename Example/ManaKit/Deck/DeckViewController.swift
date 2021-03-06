//
//  DeckViewController.swift
//  ManaKit_Example
//
//  Created by Jovito Royeca on 24.08.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import CoreData
import ManaKit

class DeckViewController: UIViewController {

    // MARK: Variables
    var mainboardViewModel: DeckMainboardViewModel!
    var sideboardViewModel: DeckSideboardViewModel!
    
    // MARK: Outlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    // MARK: Actions
    @IBAction func segmentedAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mainboardViewModel.fetchData()
            tableView.reloadData()
        case 1:
            sideboardViewModel.fetchData()
            tableView.reloadData()
        default:
            ()
        }
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.register(ManaKit.sharedInstance.nibFromBundle("CardTableViewCell"), forCellReuseIdentifier: CardTableViewCell.reuseIdentifier)
        
        mainboardViewModel.fetchData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCard" {
            guard let dest = segue.destination as? CardViewController,
                let card = sender as? CMCard else {
                    return
            }
            
            dest.card = card
            dest.title = card.name
        }
    }
}

// MARK: UITableViewDataSource
extension DeckViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            rows = mainboardViewModel.numberOfRows(inSection: section)
        case 1:
            rows = sideboardViewModel.numberOfRows(inSection: section)
        default:
            ()
        }
        
        return rows
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 0
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            sections = mainboardViewModel.numberOfSections()
        case 1:
            sections = sideboardViewModel.numberOfSections()
        default:
            ()
        }
        
        return sections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DeckHeroTableViewCell.reuseIdentifier,
                                                           for: indexPath) as? DeckHeroTableViewCell else {
                fatalError("Unexpected indexPath: \(indexPath)")
            }
            cell.deck = mainboardViewModel.deck
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CardTableViewCell.reuseIdentifier,
                                                           for: indexPath) as? CardTableViewCell else {
                fatalError("Unexpected indexPath: \(indexPath)")
            }
            
            var inventory: CMInventory?
            
            switch segmentedControl.selectedSegmentIndex {
            case 0:
                inventory = mainboardViewModel.object(forRowAt: indexPath)
            case 1:
                inventory = sideboardViewModel.object(forRowAt: indexPath)
            default:
                ()
            }
            
            guard let ci = inventory else {
                fatalError("Unexpected indexPath: \(indexPath)")
            }
            
            cell.card = ci.card
            cell.add(annotation: Int(ci.quantity))

            return cell
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var array: [String]?
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            array = mainboardViewModel.sectionIndexTitles()
        case 1:
            array = sideboardViewModel.sectionIndexTitles()
        default:
            ()
        }
        
        return array
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        var section = 0
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            section = mainboardViewModel.sectionForSectionIndexTitle(title: title, at: index)
        case 1:
            section = sideboardViewModel.sectionForSectionIndexTitle(title: title, at: index)
        default:
            ()
        }
        
        return section
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var string: String?
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            string = mainboardViewModel.titleForHeaderInSection(section: section)
        case 1:
            string = sideboardViewModel.titleForHeaderInSection(section: section)
        default:
            ()
        }
        
        return string
    }
}

// MARK: UITableViewDelegate
extension DeckViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var inventory: CMInventory?
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            inventory = mainboardViewModel.object(forRowAt: indexPath)
        case 1:
            inventory = sideboardViewModel.object(forRowAt: indexPath)
        default:
            ()
        }
        
        guard let ci = inventory else {
            return
        }
        performSegue(withIdentifier: "showCard", sender: ci.card)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 176
        } else {
            return CardTableViewCell.cellHeight
        }
    }
}

