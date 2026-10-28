//
//  ViewController.swift
//  HealthKitImporter
//
//  Created by boaz saragossi on 11/7/17.
//  Copyright © 2017 boaz saragossi. All rights reserved.
//

import UIKit
import os.log

class ViewController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var readCounter: UILabel!
    @IBOutlet weak var writeCounter: UILabel!

    var dataImporter = Importer()

    private let previewSwitch = UISwitch()
    private let summaryView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()

        let label = UILabel()
        label.text = "Preview only (don't write to Health)"
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [label, previewSwitch])
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center

        summaryView.isEditable = false
        summaryView.font = UIFont(name: "Menlo-Regular", size: 11) ?? UIFont.systemFont(ofSize: 11)
        summaryView.text = "Import results and skipped records will appear here."
        summaryView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        let stack = UIStackView(arrangedSubviews: [row, summaryView])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: writeCounter.bottomAnchor, constant: 12)
        ])
    }

    @IBAction func start(_ sender: Any) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var path: URL?
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            if let url = fileURLs.first, url.absoluteString.hasSuffix("export.xml") {
                path = url
            }
        } catch {
        }

        let previewOnly = previewSwitch.isOn
        dataImporter = Importer {
            if path == nil {
                path = Bundle.main.url(forResource: "export", withExtension: "xml")
            }

            if let path = path {
                if let parser = XMLParser(contentsOf: path) {
                    parser.delegate = self.dataImporter
                    self.dataImporter.dryRun = previewOnly
                    self.dataImporter.onFinish = { [weak self] summary in
                        self?.summaryView.text = summary.report()
                    }
                    self.dataImporter.readCounterLabel  = self.readCounter
                    self.dataImporter.writeCounterLabel = self.writeCounter
                    parser.parse()
                    self.dataImporter.saveAllSamples()
                }
            } else {
                os_log("File not found")
            }
        }
    }
}
