#
# Be sure to run `pod lib lint RBSRealmBrowser.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = "RBSRealmBrowser"
s.version          = "0.1.9"
s.summary          = "RBSRealmBrowser is a a Realm browser which you can use in your Swift projects."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
s.description      = <<-DESC
RBSRealmBrowser is based on NBN's RealmBrowser. If you're using RealmSwift, this browser offers a brief insight into your Realm database.
Inspect objects, their properties and their properties' values easly.
DESC

s.homepage         = "https://github.com/bearjaw/RBSRealmBrowser"
# s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
s.license          = 'MIT'
s.author           = { "Max Baumbach" => "bearjaw.dev@gmail.com" }
s.source           = { :git => "https://github.com/bearjaw/RBSRealmBrowser.git", :tag => s.version.to_s }

s.platform     = :ios, '8.0'
s.requires_arc = true
s.source_files = 'Pod/Classes/*.swift'

# s.public_header_files = 'Pod/Classes/**/*.h'
s.dependency 'RealmSwift'
end
