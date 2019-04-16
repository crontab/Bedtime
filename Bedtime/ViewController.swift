//
//  ViewController.swift
//  Bedtime
//
//  Created by Hovik Melikyan on 16/04/2019.
//  Copyright © 2019 Hovik Melikyan. All rights reserved.
//

import UIKit
import UserNotifications


class ViewController: UIViewController {

	let ALARM_NOTIFICATION_ID = "com.melikyan.Bedtime.alarm"
	let ALARM_NOTIFICATION_CATEGORY_ID = "com.melikyan.Bedtime.alarm.category"
	let ALARM_HOUR_PREFS_ID = "alarm.hour"
	let ALARM_MINS_PREFS_ID = "alarm.mins"
	let ALARM_ON_PREFS_ID = "alarm.on"

	@IBOutlet weak var datePicker: UIDatePicker!
	@IBOutlet weak var onOffSwitch: UISwitch!

	var granted = false
	let calendar = Calendar.current
	var components = DateComponents()
	let center = UNUserNotificationCenter.current()

	override func viewDidLoad() {
		super.viewDidLoad()

		let options: UNAuthorizationOptions = [.alert, .sound];
		center.requestAuthorization(options: options) { (granted, error) in
			self.granted = granted
		}

		let hour: Int = loadIntPref(key: ALARM_HOUR_PREFS_ID) ?? 22
		let mins: Int = loadIntPref(key: ALARM_MINS_PREFS_ID) ?? 10
		let on: Bool = loadPref(key: ALARM_ON_PREFS_ID) as? Bool ?? true

		components.calendar = calendar
		components.hour = hour
		components.minute = mins

		datePicker.setValue(UIColor.white, forKeyPath: "textColor")
		datePicker.date = calendar.date(from: components)!

		onOffSwitch.isOn = on

		setupNotification(on: on, components: components)
	}


	override func viewDidAppear(_ animated: Bool) {
		if (!granted) {
			showAlertWithSettings(title: "Notifications", message: "Notifications are disabled for this app. They are required for the alarm to be delivered; please eneble them in app's Settings.")
		}
	}


	@IBAction func datePickerAction(_ sender: UIDatePicker) {
		components = calendar.dateComponents([.hour, .minute], from: datePicker.date)
		setupNotification(on: onOffSwitch.isOn, components: components)
	}


	@IBAction func onOffAction(_ sender: UISwitch) {
		setupNotification(on: onOffSwitch.isOn, components: components)
	}


	func setupNotification(on: Bool, components: DateComponents) {
		center.removePendingNotificationRequests(withIdentifiers: [ALARM_NOTIFICATION_ID])
		if (on) {
			let content = UNMutableNotificationContent()
			content.body = "It's bed time!"
			content.sound = UNNotificationSound(named: UNNotificationSoundName("alarm-sound.m4a"))
			content.categoryIdentifier = ALARM_NOTIFICATION_CATEGORY_ID

			let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
			let request = UNNotificationRequest(identifier: ALARM_NOTIFICATION_ID, content: content, trigger: trigger)
			center.add(request) { (error) in
				if let error = error { print(error) }
			}
		}

		savePref(key: ALARM_HOUR_PREFS_ID, value: components.hour!)
		savePref(key: ALARM_MINS_PREFS_ID, value: components.minute!)
		savePref(key: ALARM_ON_PREFS_ID, value: on)
	}


	func showAlertWithSettings(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle:.alert)
		alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
			UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		self.present(alert, animated: true)
	}


	func savePref(key: String, value: Any?) {
		UserDefaults.standard.set(value, forKey: key)
	}


	func loadPref(key: String) -> Any? {
		return UserDefaults.standard.value(forKey: key)
	}


	func loadIntPref(key: String) -> Int? {
		return loadPref(key: key) as? Int
	}
}

