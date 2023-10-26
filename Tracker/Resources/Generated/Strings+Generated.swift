// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Отменить
  internal static let cancel = L10n.tr("Localizable", "cancel", fallback: "Отменить")
  /// Plural format key: "%#@days@"
  internal static func daysOfCompletedTracker(_ p1: Int) -> String {
    return L10n.tr("Localizable", "daysOfCompletedTracker", p1, fallback: "Plural format key: \"%#@days@\"")
  }
  /// Localizable.strings
  ///   Tracker
  /// 
  ///   Created by Виктория Щербакова on 26.10.2023.
  internal static let delete = L10n.tr("Localizable", "delete", fallback: "Удалить")
  /// Редактировать
  internal static let edit = L10n.tr("Localizable", "edit", fallback: "Редактировать")
  /// Закрепить
  internal static let pin = L10n.tr("Localizable", "pin", fallback: "Закрепить")
  /// Поиск
  internal static let search = L10n.tr("Localizable", "search", fallback: "Поиск")
  /// Открепить
  internal static let unpin = L10n.tr("Localizable", "unpin", fallback: "Открепить")
  internal enum Onboarding {
    /// Вот это технологии!
    internal static let button = L10n.tr("Localizable", "Onboarding.button", fallback: "Вот это технологии!")
    /// Отслеживайте только то, что хотите
    internal static let view1 = L10n.tr("Localizable", "Onboarding.view1", fallback: "Отслеживайте только то, что хотите")
    /// Даже если это не литры воды и йога
    internal static let view2 = L10n.tr("Localizable", "Onboarding.view2", fallback: "Даже если это не литры воды и йога")
  }
  internal enum StaticticVC {
    /// Анализировать пока нечего
    internal static let errorTitle = L10n.tr("Localizable", "StaticticVC.errorTitle", fallback: "Анализировать пока нечего")
    /// Статистика
    internal static let title = L10n.tr("Localizable", "StaticticVC.title", fallback: "Статистика")
    /// Трекеров завершено
    internal static let titleCell = L10n.tr("Localizable", "StaticticVC.titleCell", fallback: "Трекеров завершено")
  }
  internal enum TrackerVC {
    /// Нельзя отметить трекер для будущей даты
    internal static let errorAlert = L10n.tr("Localizable", "TrackerVC.errorAlert", fallback: "Нельзя отметить трекер для будущей даты")
    /// Что будем отслеживать?
    internal static let errorTitle = L10n.tr("Localizable", "TrackerVC.errorTitle", fallback: "Что будем отслеживать?")
    /// Трекеры
    internal static let title = L10n.tr("Localizable", "TrackerVC.title", fallback: "Трекеры")
  }
  internal enum Delete {
    /// Уверены что хотите удалить трекер?
    internal static let confirmation = L10n.tr("Localizable", "delete.confirmation", fallback: "Уверены что хотите удалить трекер?")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
