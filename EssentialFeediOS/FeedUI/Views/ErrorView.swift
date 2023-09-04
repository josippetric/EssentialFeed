//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Josip Petric on 04.09.2023..
//

import UIKit

public final class ErrorView: UIView {
	@IBOutlet private var label: UILabel!
	
	public var message: String? {
		get { return label.text }
		set { label.text = message }
	}
	
	public override func awakeFromNib() {
		super.awakeFromNib()
		
		label.text = nil
	}
}
