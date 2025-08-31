// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Get Started`
  String get get_started {
    return Intl.message('Get Started', name: 'get_started', desc: '', args: []);
  }

  /// `Manage Your Orders`
  String get manage_your_orders {
    return Intl.message(
      'Manage Your Orders',
      name: 'manage_your_orders',
      desc: '',
      args: [],
    );
  }

  /// `\nEasily`
  String get easily {
    return Intl.message('\nEasily', name: 'easily', desc: '', args: []);
  }

  /// `Sign in with dinnery account`
  String get authentication_slogan {
    return Intl.message(
      'Sign in with dinnery account',
      name: 'authentication_slogan',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get sign_in {
    return Intl.message('Sign In', name: 'sign_in', desc: '', args: []);
  }

  /// `Create An Account`
  String get create_account {
    return Intl.message(
      'Create An Account',
      name: 'create_account',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Confirm Password`
  String get confirm_password {
    return Intl.message(
      'Confirm Password',
      name: 'confirm_password',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password`
  String get forgot_password {
    return Intl.message(
      'Forgot Password',
      name: 'forgot_password',
      desc: '',
      args: [],
    );
  }

  /// `Restaurant Name`
  String get restaurant_name {
    return Intl.message(
      'Restaurant Name',
      name: 'restaurant_name',
      desc: '',
      args: [],
    );
  }

  /// `Create A Restaurant Account`
  String get create_restaurant_account {
    return Intl.message(
      'Create A Restaurant Account',
      name: 'create_restaurant_account',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get sing_up {
    return Intl.message('Sign Up', name: 'sing_up', desc: '', args: []);
  }

  /// `You are not registered as a restaurant!`
  String get youre_not_registered_as_restaurant {
    return Intl.message(
      'You are not registered as a restaurant!',
      name: 'youre_not_registered_as_restaurant',
      desc: '',
      args: [],
    );
  }

  /// `You have signed in successfully!`
  String get sign_successfully {
    return Intl.message(
      'You have signed in successfully!',
      name: 'sign_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Sign-in failed. Please check your credentials.`
  String get sign_failed {
    return Intl.message(
      'Sign-in failed. Please check your credentials.',
      name: 'sign_failed',
      desc: '',
      args: [],
    );
  }

  /// `Authentication error: `
  String get auth_error {
    return Intl.message(
      'Authentication error: ',
      name: 'auth_error',
      desc: '',
      args: [],
    );
  }

  /// `An unexpected error occurred: `
  String get unexpected_error {
    return Intl.message(
      'An unexpected error occurred: ',
      name: 'unexpected_error',
      desc: '',
      args: [],
    );
  }

  /// `Schedule`
  String get schedule {
    return Intl.message('Schedule', name: 'schedule', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Tags`
  String get tags {
    return Intl.message('Tags', name: 'tags', desc: '', args: []);
  }

  /// `Update Item`
  String get update_item {
    return Intl.message('Update Item', name: 'update_item', desc: '', args: []);
  }

  /// `All fields must be filled`
  String get items_must_be_filled {
    return Intl.message(
      'All fields must be filled',
      name: 'items_must_be_filled',
      desc: '',
      args: [],
    );
  }

  /// `Item Name`
  String get item_name {
    return Intl.message('Item Name', name: 'item_name', desc: '', args: []);
  }

  /// `Add Item`
  String get add_item {
    return Intl.message('Add Item', name: 'add_item', desc: '', args: []);
  }

  /// `Price of`
  String get price_of {
    return Intl.message('Price of', name: 'price_of', desc: '', args: []);
  }

  /// `Price`
  String get price {
    return Intl.message('Price', name: 'price', desc: '', args: []);
  }

  /// `Delete Category`
  String get delete_category {
    return Intl.message(
      'Delete Category',
      name: 'delete_category',
      desc: '',
      args: [],
    );
  }

  /// `Category name and at least one item are required`
  String get category_name_item_required {
    return Intl.message(
      'Category name and at least one item are required',
      name: 'category_name_item_required',
      desc: '',
      args: [],
    );
  }

  /// `No Items`
  String get no_items {
    return Intl.message('No Items', name: 'no_items', desc: '', args: []);
  }

  /// `Category Name`
  String get caregory_name {
    return Intl.message(
      'Category Name',
      name: 'caregory_name',
      desc: '',
      args: [],
    );
  }

  /// `Accept notes`
  String get accept_notes {
    return Intl.message(
      'Accept notes',
      name: 'accept_notes',
      desc: '',
      args: [],
    );
  }

  /// `Multi Sizes`
  String get multi_sizes {
    return Intl.message('Multi Sizes', name: 'multi_sizes', desc: '', args: []);
  }

  /// `Failed to add restaurant:`
  String get failed_add_restaurant {
    return Intl.message(
      'Failed to add restaurant:',
      name: 'failed_add_restaurant',
      desc: '',
      args: [],
    );
  }

  /// `Add Tags`
  String get add_tags {
    return Intl.message('Add Tags', name: 'add_tags', desc: '', args: []);
  }

  /// `No tags are selected`
  String get no_tags_selected {
    return Intl.message(
      'No tags are selected',
      name: 'no_tags_selected',
      desc: '',
      args: [],
    );
  }

  /// `Add Category`
  String get add_category {
    return Intl.message(
      'Add Category',
      name: 'add_category',
      desc: '',
      args: [],
    );
  }

  /// `Menu is empty`
  String get menu_empty {
    return Intl.message(
      'Menu is empty',
      name: 'menu_empty',
      desc: '',
      args: [],
    );
  }

  /// `Start Working`
  String get start_working {
    return Intl.message(
      'Start Working',
      name: 'start_working',
      desc: '',
      args: [],
    );
  }

  /// `Select Location`
  String get select_location {
    return Intl.message(
      'Select Location',
      name: 'select_location',
      desc: '',
      args: [],
    );
  }

  /// `Account created successfully`
  String get account_created_successfully {
    return Intl.message(
      'Account created successfully',
      name: 'account_created_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Select Primary Image`
  String get select_primary_image {
    return Intl.message(
      'Select Primary Image',
      name: 'select_primary_image',
      desc: '',
      args: [],
    );
  }

  /// `Add Image`
  String get add_image {
    return Intl.message('Add Image', name: 'add_image', desc: '', args: []);
  }

  /// `Select Album Image`
  String get select_album_image {
    return Intl.message(
      'Select Album Image',
      name: 'select_album_image',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Internal error, try again!`
  String get internal_error {
    return Intl.message(
      'Internal error, try again!',
      name: 'internal_error',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Information`
  String get information {
    return Intl.message('Information', name: 'information', desc: '', args: []);
  }

  /// `Edit information`
  String get edit_information {
    return Intl.message(
      'Edit information',
      name: 'edit_information',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Information changed successfully. Check your mail!`
  String get info_changed_successfully {
    return Intl.message(
      'Information changed successfully. Check your mail!',
      name: 'info_changed_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Email changed successfully. Check your mail!`
  String get email_changed_successfully {
    return Intl.message(
      'Email changed successfully. Check your mail!',
      name: 'email_changed_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Email changed successfully. Check your mail!`
  String get name_changed_successfully {
    return Intl.message(
      'Email changed successfully. Check your mail!',
      name: 'name_changed_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Edit schedule`
  String get edit_schedule {
    return Intl.message(
      'Edit schedule',
      name: 'edit_schedule',
      desc: '',
      args: [],
    );
  }

  /// `Day Off`
  String get day_off {
    return Intl.message('Day Off', name: 'day_off', desc: '', args: []);
  }

  /// `Location`
  String get location {
    return Intl.message('Location', name: 'location', desc: '', args: []);
  }

  /// `Edit location`
  String get edit_location {
    return Intl.message(
      'Edit location',
      name: 'edit_location',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get gallery {
    return Intl.message('Gallery', name: 'gallery', desc: '', args: []);
  }

  /// `Edit gallery`
  String get edit_gallery {
    return Intl.message(
      'Edit gallery',
      name: 'edit_gallery',
      desc: '',
      args: [],
    );
  }

  /// `Edit Primary Image`
  String get edit_primary_image {
    return Intl.message(
      'Edit Primary Image',
      name: 'edit_primary_image',
      desc: '',
      args: [],
    );
  }

  /// `Edit Album Image`
  String get edit_album_image {
    return Intl.message(
      'Edit Album Image',
      name: 'edit_album_image',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get delete_account {
    return Intl.message(
      'Delete Account',
      name: 'delete_account',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete your account? This action cannot be undone.`
  String get delete_account_warning {
    return Intl.message(
      'Are you sure you want to delete your account? This action cannot be undone.',
      name: 'delete_account_warning',
      desc: '',
      args: [],
    );
  }

  /// `Account deleted successfully`
  String get account_deleted_successfully {
    return Intl.message(
      'Account deleted successfully',
      name: 'account_deleted_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Yes, I want`
  String get yes_i_want {
    return Intl.message('Yes, I want', name: 'yes_i_want', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `ID`
  String get id {
    return Intl.message('ID', name: 'id', desc: '', args: []);
  }

  /// `Record`
  String get record {
    return Intl.message('Record', name: 'record', desc: '', args: []);
  }

  /// `Order History`
  String get order_history {
    return Intl.message(
      'Order History',
      name: 'order_history',
      desc: '',
      args: [],
    );
  }

  /// `App`
  String get app {
    return Intl.message('App', name: 'app', desc: '', args: []);
  }

  /// `Language`
  String get langauge {
    return Intl.message('Language', name: 'langauge', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `French`
  String get french {
    return Intl.message('French', name: 'french', desc: '', args: []);
  }

  /// `Arabic`
  String get arabic {
    return Intl.message('Arabic', name: 'arabic', desc: '', args: []);
  }

  /// `Support`
  String get support {
    return Intl.message('Support', name: 'support', desc: '', args: []);
  }

  /// `Help Center`
  String get help_center {
    return Intl.message('Help Center', name: 'help_center', desc: '', args: []);
  }

  /// `Contact Us`
  String get contact_us {
    return Intl.message('Contact Us', name: 'contact_us', desc: '', args: []);
  }

  /// `Rate Our App`
  String get rate_our_app {
    return Intl.message(
      'Rate Our App',
      name: 'rate_our_app',
      desc: '',
      args: [],
    );
  }

  /// `Legal`
  String get legal {
    return Intl.message('Legal', name: 'legal', desc: '', args: []);
  }

  /// `Privacy Policy`
  String get privacy_policy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacy_policy',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Service`
  String get terms_of_service {
    return Intl.message(
      'Terms of Service',
      name: 'terms_of_service',
      desc: '',
      args: [],
    );
  }

  /// `Sign Out`
  String get sign_out {
    return Intl.message('Sign Out', name: 'sign_out', desc: '', args: []);
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `No orders found`
  String get no_orders_found {
    return Intl.message(
      'No orders found',
      name: 'no_orders_found',
      desc: '',
      args: [],
    );
  }

  /// `Arriving Orders`
  String get arriving_orders {
    return Intl.message(
      'Arriving Orders',
      name: 'arriving_orders',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed Orders`
  String get confirmed_orders {
    return Intl.message(
      'Confirmed Orders',
      name: 'confirmed_orders',
      desc: '',
      args: [],
    );
  }

  /// `Total Price`
  String get total_price {
    return Intl.message('Total Price', name: 'total_price', desc: '', args: []);
  }

  /// `DA`
  String get da {
    return Intl.message('DA', name: 'da', desc: '', args: []);
  }

  /// `Cancel Order`
  String get cancel_order {
    return Intl.message(
      'Cancel Order',
      name: 'cancel_order',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel this order?`
  String get cancel_order_warning {
    return Intl.message(
      'Are you sure you want to cancel this order?',
      name: 'cancel_order_warning',
      desc: '',
      args: [],
    );
  }

  /// `Yes, Cancel`
  String get yes_cancel {
    return Intl.message('Yes, Cancel', name: 'yes_cancel', desc: '', args: []);
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `At Table`
  String get at_table {
    return Intl.message('At Table', name: 'at_table', desc: '', args: []);
  }

  /// `To Go`
  String get to_go {
    return Intl.message('To Go', name: 'to_go', desc: '', args: []);
  }

  /// `Orders`
  String get orders {
    return Intl.message('Orders', name: 'orders', desc: '', args: []);
  }

  /// `Order`
  String get order {
    return Intl.message('Order', name: 'order', desc: '', args: []);
  }

  /// `Suggest`
  String get suggest {
    return Intl.message('Suggest', name: 'suggest', desc: '', args: []);
  }

  /// `Menu`
  String get menu {
    return Intl.message('Menu', name: 'menu', desc: '', args: []);
  }

  /// `Category Name`
  String get category_name {
    return Intl.message(
      'Category Name',
      name: 'category_name',
      desc: '',
      args: [],
    );
  }

  /// `Empty`
  String get empty {
    return Intl.message('Empty', name: 'empty', desc: '', args: []);
  }

  /// `Statistics`
  String get statistics {
    return Intl.message('Statistics', name: 'statistics', desc: '', args: []);
  }

  /// `Total Orders`
  String get total_orders {
    return Intl.message(
      'Total Orders',
      name: 'total_orders',
      desc: '',
      args: [],
    );
  }

  /// `Served Items`
  String get served_items {
    return Intl.message(
      'Served Items',
      name: 'served_items',
      desc: '',
      args: [],
    );
  }

  /// `Total Income`
  String get total_icnome {
    return Intl.message(
      'Total Income',
      name: 'total_icnome',
      desc: '',
      args: [],
    );
  }

  /// `Weekly Orders`
  String get weekly_orders {
    return Intl.message(
      'Weekly Orders',
      name: 'weekly_orders',
      desc: '',
      args: [],
    );
  }

  /// `Reservation at table`
  String get reservation_at_table {
    return Intl.message(
      'Reservation at table',
      name: 'reservation_at_table',
      desc: '',
      args: [],
    );
  }

  /// `Reservation to go`
  String get reservation_to_go {
    return Intl.message(
      'Reservation to go',
      name: 'reservation_to_go',
      desc: '',
      args: [],
    );
  }

  /// `View`
  String get view {
    return Intl.message('View', name: 'view', desc: '', args: []);
  }

  /// `Accept`
  String get accept {
    return Intl.message('Accept', name: 'accept', desc: '', args: []);
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Select your language`
  String get select_your_language {
    return Intl.message(
      'Select your language',
      name: 'select_your_language',
      desc: '',
      args: [],
    );
  }

  /// `Orders History`
  String get orders_history {
    return Intl.message(
      'Orders History',
      name: 'orders_history',
      desc: '',
      args: [],
    );
  }

  /// `Message`
  String get message {
    return Intl.message('Message', name: 'message', desc: '', args: []);
  }

  /// `Send`
  String get send {
    return Intl.message('Send', name: 'send', desc: '', args: []);
  }

  /// `Message cannot be empty`
  String get message_empty {
    return Intl.message(
      'Message cannot be empty',
      name: 'message_empty',
      desc: '',
      args: [],
    );
  }

  /// `Message sent successfully`
  String get message_sent_successfully {
    return Intl.message(
      'Message sent successfully',
      name: 'message_sent_successfully',
      desc: '',
      args: [],
    );
  }

  /// `We would love to hear from you! If You have any questions, suggestions, or feedback, please don't hesitate to reach out to us. Our team is here to assist you and ensure you have the best experience possible.`
  String get we_would_love_to_hear_from_you {
    return Intl.message(
      'We would love to hear from you! If You have any questions, suggestions, or feedback, please don\'t hesitate to reach out to us. Our team is here to assist you and ensure you have the best experience possible.',
      name: 'we_would_love_to_hear_from_you',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
