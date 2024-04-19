//
//  ChannelTableViewController.swift
//  PinkBookTest
//
//  Created by mac on 2024/4/18.
//

import UIKit
import XLPagerTabStrip

class ChannelTableViewController: UITableViewController {
    
    var channel = ""
    var subChannels: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subChannels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kSubChannelCellID, for: indexPath)
        var configuration = cell.defaultContentConfiguration()
        configuration.text = "# \(subChannels[indexPath.row])"
        cell.contentConfiguration = configuration

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = parent as! ChannelViewController
        vc.channelDelegate?.updateChannel(channel: channel, subChannel: subChannels[indexPath.row])
        dismiss(animated: true)
    }


}

extension ChannelTableViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: XLPagerTabStrip.PagerTabStripViewController) -> XLPagerTabStrip.IndicatorInfo {
        IndicatorInfo(title: channel)
    }
    
    
}
