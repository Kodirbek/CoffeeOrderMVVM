//
//  AddOrderViewController.swift
//  CoffeeOrder
//
//  Created by Abduqodir's MacPro on 2022/10/06.
//

import Foundation
import UIKit

protocol AddCoffeeOrderDelegate {
  func addOrderVCDidSave(order: Order, controller: UIViewController)
  func addOrderVCDidClose(controller: UIViewController)
}

class AddOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var delegate: AddCoffeeOrderDelegate?
  
  private var vm = AddOrderViewModel()
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var nameTextFiel: UITextField!
  @IBOutlet weak var emailTextFiel: UITextField!
  
  private var sizesSegmentedControl: UISegmentedControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
  }
  
  
  private func setupUI() {
    
    self.sizesSegmentedControl = UISegmentedControl(items: self.vm.sizes)
    self.sizesSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
    
    self.view.addSubview(self.sizesSegmentedControl)
    self.sizesSegmentedControl.topAnchor.constraint(equalTo: self.tableView.bottomAnchor, constant: 20).isActive = true
    self.sizesSegmentedControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
  }
  
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    tableView.cellForRow(at: indexPath)?.accessoryType = .none
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.vm.types.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "CoffeeTypeCell", for: indexPath)
    cell.textLabel?.text = self.vm.types[indexPath.row]
    return cell
  }
  
  
  @IBAction func close() {
    if let delegate = self.delegate {
      delegate.addOrderVCDidClose(controller: self)
    }
  }
  
  
  @IBAction func save() {
    
    let name = self.nameTextFiel.text
    let email = self.emailTextFiel.text
    let selectedSize = self.sizesSegmentedControl.titleForSegment(at: self.sizesSegmentedControl.selectedSegmentIndex)
    
    guard let indexPath = self.tableView.indexPathForSelectedRow else {
      fatalError("Coffee type unselected!")
    }
    
    self.vm.name = name
    self.vm.email = email
    self.vm.selectedSize = selectedSize
    self.vm.selectedType = self.vm.types[indexPath.row]
    
    WebService().load(resource: Order.create(vm: self.vm)) { result in
      switch result {
      case .success(let order):
        if let order = order, let delegate = self.delegate {
          DispatchQueue.main.async {
            delegate.addOrderVCDidSave(order: order, controller: self)
          }
        }
      case .failure(let error):
        print(error)
      }
    }
    
  }
  
}
