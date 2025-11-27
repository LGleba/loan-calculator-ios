import ProjectDescription

// MARK: - Constants

let MODULES_PATH = "Modules/"

// MARK: - Helpful funcs

func depModule(modulePath: String = MODULES_PATH, name: String) -> TargetDependency {
    .project(target: name, path: "\(modulePath)\(name)")
}

// MARK: - Settings

let settings = ProjectDescription.Settings.settings(
    base: [
        "SWIFT_VERSION": "6.0"
    ]
)

// MARK: - Project

let project = Project(
    name: "LoanCalculator",
    options: .options(
        defaultKnownRegions: ["en", "ru"],
        developmentRegion: "en"
    ),
    targets: [
        .target(
            name: "LoanCalculator",
            destinations: .iOS,
            product: .app,
            bundleId: "com.lgleba.LoanCalculator",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["LoanCalculator/Sources/**"],
            resources: [],
            dependencies: [],
            settings: settings
        ),
        .target(
            name: "LoanCalculatorTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.lgleba.LoanCalculatorTests",
            infoPlist: .default,
            sources: ["LoanCalculatorTests/**"],
            dependencies: [
                .target(name: "LoanCalculator")
            ],
            settings: settings
        )
    ]
)
