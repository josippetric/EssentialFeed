//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 19.10.2023..
//

import UIKit
import EssentialFeed

public class ImageCommentCellController: ListCellController {
	
	private let model: ImageCommentViewModel
	
	public init(model: ImageCommentViewModel) {
		self.model = model
	}
	
	public func view(in tableView: UITableView) -> UITableViewCell {
		let cell: ImageCommentCell = tableView.dequeueReusableCell()
		cell.messageLabel?.text = model.message
		cell.usernameLabel?.text = model.username
		cell.dateLabel?.text = model.date
		return cell
	}
	
	public func preload() {
		
	}
	
	public func cancelLoad() {
		
	}
}
