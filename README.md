NuageApp
========

Warning
--------
The project isn't maintained anymore.
Since CloudApp moved to 10 free drops a month - lol - I'm using another service now.

What is it?
--------
Let's start with [CloudApp](http://cl.ly "CloudApp's home page").
CloudApp is a simple service that allows you to upload all kinds of files, images, music, videos, bookmarks... It gives you a link to the uploaded file that you can share, you can manage your files in the Mac application or in your browser, allowing you to access your files anywhere...

NuageApp is a fully featured CloudApp iPhone client, you can do everything the web-app can do.
Here are its main features:
+ Create an account
+ Access your account, and modify your settings (email address, password, custom domain name, default upload settings)
+ Browse all your drops, rename them, change their privacy, view their stats, trash them
+ Browse your trash, restore drops from the trash
+ Open pictures, music, videos, text, bookmarks without leaving the application
+ Open any other file in an other iOS app that can handle it
+ Bookmark a link
+ Drop a picture

Why is it (so) cool?
--------
If you've ever used CloudApp Mac's client, you've probably fallen in love with the screenshot autoupload feature.
When you take a screenshot, it automatically gets uploaded and the link copied to your clipboard.
You no longer need to upload it on a web page, wait thirty seconds until the picture is uploaded or receive tons of ads just to get your link. Productivity enhanced by over nine thousand.

And that's what I wanted to bring to the iPhone with NuageApp.
Unfortunately, due to iOS's restrictions, it's impossible to detect when a screenshot is taken on your device. Anyway, to workaround this issue, NuageApp offers the possibility to auto-upload the last picture taken from your camera roll when you open the application.

Of course like in the Mac application, you don't need to copy the link yourself. When a picture is uploaded, or a link bookmarked, it is instantly copied to your clipboard.
But... what if you want to get the link on your Mac? You could always send it by mail, message, but it would be a waste of time. And that's why NuageApp also has a tiny Mac application that will instantly display a notification and copy the link to the clipboard when you upload a file from your iPhone, as long as your iPhone and your Mac are on the same network.

And here it is, CloudApp's best feature, brought to iOS.

How can I get and use it ?
--------
For now on, you'll have to compile and run it by yourself (don't forget to `pod install` before opening the project - more infos on [CocoaPods](http://cocoapods.org, "CocoaPods' documentation")).
In a few weeks though, I'll post it on the AppStore.
To enable sharing to your Mac, you'll have to compile and run NuageApp Server's sub-project, and enable it in the iOS application settings.
After, you'll just have to upload a picture, and that's it !

License
--------
```
/*
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <maxime.dechalendar@me.com> wrote these files. As long as you retain this
 * notice in the application you can do whatever you want with this stuff. 
 * If we meet some day, and you think this stuff is worth it, you can buy
 * me a beer in return Maxime de Chalendar.
 * ----------------------------------------------------------------------------
 */
```

Stuff NuageApp relies on
--------
NuageApp relies on a bunch of open-source stuff, which really simplified my life. Thanks to :
+ [DTBonjour](https://github.com/Cocoanetics/DTBonjour "DTBonjour")
+ [MBProgressHUD](https://github.com/matej/MBProgressHUD "MBProgressHUD")
+ [AFNetworking](https://github.com/AFNetworking/AFNetworking "MBProgressHUD")
+ [PKRevealController](https://github.com/pkluz/PKRevealController "PKRevealController")
 
Also, even if the icons will probably change :
+ [Igh0zt's icons](http://igh0zt.deviantart.com/art/iOS-7-Style-Metro-UI-Icons-384587316 "Igh0zt's icons") (used in the iOS application)
+ [Iynque's icons](http://iynque.deviantart.com/art/iOS-7-Icons-Updated-378969049 "Iynque's icons") (used in the Mac OS and iOS application)
 
