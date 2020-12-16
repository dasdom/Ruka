import Ruka
import XCTest

class Tests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: Storyboard

    func test_findsAStoryboardBackedController() throws {
        let app = App(storyboard: "Main", identifier: "UIViewController identifier")
        XCTAssertNotNil(try app.label(text: "Storyboard label text"))
    }

    // MARK: UILabel

    func test_findsALabel() throws {
        let controller = RootViewController()
        let app = App(controller: controller)

        let label = try app.label(text: "Label text")
        XCTAssertNotNil(label)
        XCTAssertEqual(label?.superview?.superview, controller.view)
    }

    func test_doesNotFindAHiddenLabel() throws {
        let app = App(controller: RootViewController(), failureBehavior: .doNothing)
        XCTAssertNil(try app.label(text: "Hidden label text"))
    }

    // MARK: UIButton

    func test_findsAButton() throws {
        let controller = RootViewController()
        let app = App(controller: controller)

        let button = try app.button(title: "Button title")
        XCTAssertNotNil(button)
        XCTAssertEqual(button?.superview?.superview, controller.view)
    }

    func test_doesNotFindAHiddenButton() throws {
        let controller = RootViewController()
        let app = App(controller: controller, failureBehavior: .doNothing)

        XCTAssertNil(try app.button(title: "Hidden button title"))
    }

    func test_tapsAButton() throws {
        let controller = RootViewController()
        let app = App(controller: controller)

        let button = try app.button(title: "Button title")
        button?.tap()

        _ = try app.label(text: "Changed label text")
    }

    func test_doesNotTapADisabledButton() throws {
        let controller = RootViewController()
        let app = App(controller: controller, failureBehavior: .doNothing)

        let button = try app.button(title: "Disabled button title")
        button?.tap()

        XCTAssertNil(try app.label(text: "Changed label text"))
    }

    // MARK: UINavigationController

    func test_pushesAViewController() throws {
        let navigationController = UINavigationController(rootViewController: RootViewController())
        let app = App(controller: navigationController)

        try app.button(title: "Push view controller")?.tap()

        XCTAssertEqual(navigationController.viewControllers.count, 2)
    }

    func test_popsAViewController() throws {
        let navigationController = UINavigationController(rootViewController: RootViewController())
        let app = App(controller: navigationController)

        try app.button(title: "Push view controller")?.tap()
        XCTAssertEqual(navigationController.viewControllers.count, 2)

        try app.button(title: "Pop view controller")?.tap()
        XCTAssertEqual(navigationController.viewControllers.count, 1)
    }

    // MARK: Modal view controllers

    func test_presentsAViewController() throws {
        let controller = RootViewController()
        let app = App(controller: controller)

        try app.button(title: "Present view controller")?.tap()

        XCTAssertNotNil(controller.presentedViewController)
    }

    func test_dismissesAViewController() throws {
        let controller = RootViewController()
        let app = App(controller: controller, failureBehavior: .doNothing)
        XCTAssertNil(try app.button(title: "Dismiss view controller"))

        try app.button(title: "Present view controller")?.tap()
        XCTAssertNotNil(try app.button(title: "Dismiss view controller"))

        let async = expectation(description: "async")
        try app.button(title: "Dismiss view controller")?.tap()
        DispatchQueue.main.async {
            async.fulfill()
        }
        wait(for: [async], timeout: 1)
        XCTAssertNil(try app.button(title: "Dismiss view controller"))
    }
    
    func test_dismissNestedModalViewController() throws {
        let controller = RootViewController()
        let app = App(controller: controller, failureBehavior: .doNothing)
        XCTAssertNil(try app.button(title: "Dismiss view controller"))

        try app.button(title: "Present view controller")?.tap()
        XCTAssertNotNil(try app.button(title: "Dismiss view controller"))
        
        try app.button(title: "Present view controller")?.tap()
        XCTAssertNotNil(try app.button(title: "Dismiss view controller"))

        let async1 = expectation(description: "async")
        try app.button(title: "Dismiss view controller")?.tap()
        DispatchQueue.main.async {
            async1.fulfill()
        }
        wait(for: [async1], timeout: 1)
        XCTAssertNotNil(try app.button(title: "Dismiss view controller"))
        
        let async2 = expectation(description: "async")
        try app.button(title: "Dismiss view controller")?.tap()
        DispatchQueue.main.async {
            async2.fulfill()
        }
        wait(for: [async2], timeout: 1)
        XCTAssertNil(try app.button(title: "Dismiss view controller"))
    }
    
    // MARK: UITabBarController
    
    func test_presentsAViewControllerOnSecondTabInTabBarController() throws {
        let tabBarController = TabBarViewController()
        let app = App(controller: tabBarController, failureBehavior: .doNothing)
        XCTAssertNil(try app.button(title: "Present view controller from second tab"))

        tabBarController.selectedIndex = 1
        XCTAssertNotNil(try app.button(title: "Present view controller from second tab"))
        try app.button(title: "Present view controller from second tab")?.tap()
        
        XCTAssertNotNil(tabBarController.secondTabViewController.presentedViewController)
    }

    // MARK: UIAlertController

    func test_findsAnAlert() throws {
        let controller = RootViewController()
        let app = App(controller: controller)

        try app.button(title: "Show alert")?.tap()
        XCTAssertNotNil(try app.label(text: "Alert title"))
        XCTAssertNotNil(try app.label(text: "Alert message."))
    }

    func test_dismissesAnAlert() throws {
        let controller = RootViewController()
        let app = App(controller: controller, failureBehavior: .doNothing)

        try app.button(title: "Show alert")?.tap()
        XCTAssertNil(try app.button(title: "Show alert"))

        let async = expectation(description: "async")
        app.alertViewController?.tapButton(title: "Dismiss")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            async.fulfill()
        }
        wait(for: [async], timeout: 1)
        XCTAssertNotNil(try app.button(title: "Show alert"))
        XCTAssertNotNil(try app.label(text: "Changed label text"))
    }

    // MARK: UITableView

    func test_findsVisibleCells() throws {
        let app = App(controller: TableViewController())
        XCTAssertEqual(app.tableView?.visibleCells.count ?? 0, 3)
    }

    func test_findsASpecificCell() throws {
        let app = App(controller: TableViewController(), failureBehavior: .doNothing)
        XCTAssertNotNil(try app.cell(containingText: "Three"))

        XCTAssertNotNil(try app.label(text: "Label text"))
        XCTAssertNil(try app.cell(containingText: "Label text"))
    }

    func test_tapsACell() throws {
        let app = App(controller: TableViewController())
        try app.cell(containingText: "Three")?.tap()
        XCTAssertNotNil(try app.label(text: "Changed label text"))
    }

    // MARK: UISwitch

    func test_findsASwitch() throws {
        let app = App(controller: FormViewController())
        XCTAssertNotNil(try app.switch(accessibilityLabel: "A switch"))
    }

    func test_doesNotFindAHiddenSwitch() throws {
        let app = App(controller: FormViewController(), failureBehavior: .doNothing)
        XCTAssertNil(try app.switch(accessibilityLabel: "A hidden switch"))
    }

    func test_togglesASwitch() throws {
        let app = App(controller: FormViewController())
        let `switch` = try app.switch(accessibilityLabel: "A switch")
        XCTAssertNotNil(try app.label(text: "Disabled"))

        `switch`?.toggle()
        XCTAssertNotNil(try app.label(text: "Enabled"))
    }

    func test_doesNotToggleADisabledSwitch() throws {
        let app = App(controller: FormViewController())
        let `switch` = try app.switch(accessibilityLabel: "A disabled switch")
        XCTAssertNotNil(try app.label(text: "Disabled"))

        `switch`?.toggle()
        XCTAssertNotNil(try app.label(text: "Disabled"))
    }

    // MARK: UIStepper

    func test_findsAStepper() throws {
        let app = App(controller: FormViewController())
        XCTAssertNotNil(try app.stepper(accessibilityLabel: "A stepper"))
    }

    func test_doesNotFindAHiddenStepper() throws {
        let app = App(controller: FormViewController(), failureBehavior: .doNothing)
        XCTAssertNil(try app.stepper(accessibilityLabel: "A hidden stepper"))
    }

    func test_incrementsAStepper() throws {
        let app = App(controller: FormViewController())
        try app.incrementStepper(accessibilityLabel: "A stepper")
        XCTAssertNotNil(try app.label(text: "3.0"))
    }

    func test_decrementsAStepper() throws {
        let app = App(controller: FormViewController())
        try app.decrementStepper(accessibilityLabel: "A stepper")
        XCTAssertNotNil(try app.label(text: "1.0"))
    }

    func test_doesNotIncrementADisabledStepper() throws {
        let app = App(controller: FormViewController())
        try app.incrementStepper(accessibilityLabel: "A disabled stepper")
        XCTAssertNotNil(try app.label(text: "2.0"))
    }

    func test_doesNotDecrementADisabledStepper() throws {
        let app = App(controller: FormViewController())
        try app.decrementStepper(accessibilityLabel: "A disabled stepper")
        XCTAssertNotNil(try app.label(text: "2.0"))
    }

    // MARK: UISlider

    func test_findsASlider() throws {
        let app = App(controller: FormViewController())
        XCTAssertNotNil(try app.slider(accessibilityLabel: "A slider"))
    }

    func test_doesNotFindAHiddenSlider() throws {
        let app = App(controller: FormViewController(), failureBehavior: .doNothing)
        XCTAssertNil(try app.slider(accessibilityLabel: "A hidden slider"))
    }

    func test_setsASlidersValue() throws {
        let app = App(controller: FormViewController())
        try app.setSlider(accessibilityLabel: "A slider", value: 3)
        XCTAssertNotNil(try app.label(text: "3.0"))
    }

    func test_doesNotSetADisabledSlidersValue() throws {
        let app = App(controller: FormViewController())
        try app.setSlider(accessibilityLabel: "A disabled slider", value: 3)
        XCTAssertNotNil(try app.label(text: "2.0"))
    }

    // MARK: UITextField

    func test_findsATextField() throws {
        let app = App(controller: FormViewController())
        XCTAssertNotNil(try app.textField(placeholder: "Text field placeholder"))
    }

    func test_doesNotFindAHiddenTextField() throws {
        let app = App(controller: FormViewController(), failureBehavior: .doNothing)
        XCTAssertNil(try app.textField(placeholder: "Hidden text field placeholder"))
    }

    func test_typesIntoATextField() throws {
        let app = App(controller: FormViewController())
        let textField = try app.textField(placeholder: "Text field placeholder")

        textField?.type(text: "Some typed text.")
        XCTAssertEqual(textField?.text, "Some typed text.")
        XCTAssertNotNil(try app.label(text: "Some typed text."))
    }

    func test_doesNotTypeIntoADisabledTextField() throws {
        let app = App(controller: FormViewController(), failureBehavior: .doNothing)
        let textField = try app.textField(placeholder: "Disabled text field placeholder")

        textField?.type(text: "Some typed text.")
        XCTAssertEqual(textField?.text, "")
        XCTAssertNil(try app.label(text: "Some typed text."))
    }

    // MARK: Failure behavior

    func test_aMissingElement_raisesAnError() throws {
        let app = App(controller: RootViewController(), failureBehavior: .raiseException)
        XCTAssertThrowsError(try app.label(text: "Missing element"))
    }

    func test_aMissingElement_isNil() throws {
        let app = App(controller: RootViewController(), failureBehavior: .doNothing)
        XCTAssertNil(try app.label(text: "Missing element"))
    }
}
