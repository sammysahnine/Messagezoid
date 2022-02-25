//
//  NewChatViewController.swift
//  messagezoid
//
//  Created by Sammy Sahnine on 07/01/2022.
//

import UIKit

class NewChatViewController: UIViewController {

    public var completion: (([String: String]) -> (Void))?
    private var users = [[String: String]]()
    private var results = [[String: String]]()
    private var hasFetched = false
    //Set up variables and assigns their correct structures

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search by username..."
        return searchBar
        //Set up parameters for the textbox to search for a user
    }()

    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")
        return table
        //Set up parameters for the table
    }()

    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No users found"
        label.textAlignment = .center
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 21, weight: .bold)
        return label
        //Set up parameters for label that shows if no users are found
    }()
    
    private let lonelyimage: UIImageView = {
        let lonelyimage = UIImageView()
        lonelyimage.image = UIImage(named: "lonely")
        lonelyimage.contentMode = .scaleAspectFit
        lonelyimage.clipsToBounds = true
        lonelyimage.isHidden = true
        return lonelyimage
        //Set up parameters for image that displays if no users are found
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        view.addSubview(lonelyimage)
        //Adds elements to subview
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.rowHeight = 100
        //Changes height of rows of other users
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        view.backgroundColor = .systemBackground
        searchBar.becomeFirstResponder()
        //Purs the new user search box in focus
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        //Adds a cancel button to help with users
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.width/4,
                                      y: (view.height-100)/2,
                                      width: view.width/2,
                                      height: 100)
        lonelyimage.frame = CGRect(x: (view.width/4)+20, y: noResultsLabel.top - 120, width: 150, height: 150)
        //Lays out data in a suitable manner
    }

    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }

}

extension NewChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
        //Creates suitable amount of cells
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["username"]
        return cell
        //Returns cells with usernames
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Start chat with selected user
        tableView.deselectRow(at: indexPath, animated: true)
        let userSearchResult = results[indexPath.row]
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(userSearchResult)
            //Sends the user to the ChatsViewController to start a new chat with chosen user
        })
    }
}

extension NewChatViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }

        searchBar.resignFirstResponder()

        results.removeAll()

        self.searchUsers(query: text)
        
        //Reset search results if starting a new search
    }

    func searchUsers(query: String) {
        // check if array has firebase results
        if hasFetched {
            // if it does: filter
            filterUsers(with: query)
        }
        else {
            // if not, fetch then filter
            DatabaseController.shared.requestUsers(completion: { [weak self] result in
                switch result {
                case .success(let UserList):
                    self?.hasFetched = true
                    self?.users = UserList
                    self?.filterUsers(with: query)
                case .failure:
                    return
                }
            })
        }
    }

    func filterUsers(with term: String) {
        guard hasFetched else {
            return
        }
        let results: [[String: String]] = self.users.filter({
            guard let name = $0["username"]?.uppercased else {
                return false
                //Does not filter results properly
            }
            return name().contains(term.uppercased())
        })

        self.results = results

        updateUI()
    }

    func updateUI() {
        if results.isEmpty {
            self.noResultsLabel.isHidden = false
            self.tableView.isHidden = true
            lonelyimage.isHidden = false
            print("Empty")
            print(self.results)
            print(users)
            //Updates UI to hide table and show results if there are results...
        }
        else {
            self.noResultsLabel.isHidden = true
            self.tableView.isHidden = false
            lonelyimage.isHidden = true
            print(users)
            self.tableView.reloadData()
            //...and vice versa
        }
    }

}



//Searching database: https://stackoverflow.com/questions/42459432/filtering-and-displaying-searchbar-results-from-firebase-databa, https://www.zerotoappstore.com/how-to-filter-an-array-in-swift.html, https://www.youtube.com/watch?v=Hmr8PsG9E2w

//Add code from previous view controller


