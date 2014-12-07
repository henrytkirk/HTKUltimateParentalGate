Pod::Spec.new do |s|
  s.name         = "HTKUltimateParentalGate"
  s.version      = "0.0.1"
  s.summary      = "The Ultimate Parental Gate to help block children from accessing in app purchase. Combines both math and dexterity skills to be very challenging."
  s.description  = <<-DESC
                   The Ultimate Parental Gate to help block children from accessing in app purchases within an app. Most "Parental Gates" simply ask a math question or provide a question that a child can figure out by randomly selecting an item on the screen. This is unique in it requires both math and dexterity skills to succeed, which typically a child does not have at a young age. This is the same Parental Gate used in the popular special needs app, SpeechBox for iPad. Therefore, this has been tested for over a year in both home and clinical environments, and have yet had a child get past the gate. This doesn't mean it's perfect, but it provides more security than other solutions.
                   DESC
  s.homepage     = "http://www.github.com/henrytkirk/HTKUltimateParentalGate"
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author             = { "Henry T Kirk" => "henrytkirk@gmail.com" }
  s.social_media_url   = "http://twitter.com/henrytkirk"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/henrytkirk/HTKUltimateParentalGate.git", :tag => "v0.0.1" }
  s.source_files  = "HTKUltimateParentalGate/*.{h,m}"
  s.requires_arc = true
end
