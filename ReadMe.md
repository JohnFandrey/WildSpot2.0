**Welcome to WildSpot!**

WildSpot is an iOS app that allows users to upload photos to the cloud using Googles Firebase Realtime Database and Firebase Storage.  The idea is that users will upload photos of nature and those photos will be displayed as pins on a map.  Users can then tap those pins to view the photos associated with the tapped pin.

**LEGAL**

MIT License

Copyright (c) [2018] [John Fandrey]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

**INSTALLATION**

To get the app running you will need to install cocoa pods on your Mac.  To do this follow the steps outlined below:
1. Open Terminal on your Mac.
2. Type `sudo gem install cocoa pods`
3. Press ‘enter’.

Great, now let that run for a little bit so that everything gets installed.  Once the installation has completed, lets get the correct pods installed on your machine.  Do this by following the steps below:
1. Do not open Xcode until you have completed the steps for installing the pods from the podfile outlined below.  
2. First, look at the project folder and identify the folder that contains a file titled ‘podfile’.  
3. Use terminal to navigate to the folder where the WildSpot ‘podfile’ is saved.
4. Once you reach the correct folder, type `pod install` in terminal and press ‘enter’.

You’re doing great!  Let’s try opening the Xcode file.  Open the project file named ‘WildSpot.xcworkspace.

Try building and running the project.  If you get any errors related to Firebase files try the steps below.

1. Close Xcode
2. Use terminal to navigate to the folder that contains the ‘podfile’.
3. In terminal type `pod repo update` and press ‘enter’.
4. Let the repo update run and complete.
5. Once repo update has completed type `pod install` and press ‘enter’.
6. Once pod install is complete, type `pod update` and press ‘enter’.
7. Let pod update complete and then reopen the WildSpot.xcworkspace file.

Try building and running the project again.  If the project runs, here is how the app works.

**USING WILDSPOT**

_Sign In:_

WildSpot allows users to sign in using either a google account or an email address and password.  When the app first loads, a screen with options ‘Sign in with google’ and ‘Sign in with email’ are displayed.  There is also a ‘cancel’ button at the top of the screen.  If the user presses ‘cancel’, then the app displays a screen with a single button labeled ‘Sign In’.  If the user presses ’Sign In’ then the app will again display the screen with the options Sign in with google’ and ‘Sign in with email’.

_Sign in With Google:_

If the user presses sign in with google, the user will be asked for their gmail address.  Once the gmail address is entered, the user will be asked for a password.  If the user has enabled two factor authentication then, the user will need to verify the login on another device.  Once the correct password has been entered and the user has verified the login, the user will be taken to the main map screen.  

_Sign in With Email:_

If the user presses sign in with email, then the user will be asked for an email address.  If the email address entered by the user has not been used in WildSpot before, then the user will need to enter their first name and last name as well as as a password.  Once the user has entered either the correct password or a new password, the user will be taken to the main map view.  

_Main Map Screen:_

The main map screen shows the user a map view.  Any spots added by other users will be displayed on this view.  There are several buttons on the main map view.  Starting from the left and working right, the first button is a ’Search’ button.  If a user

_Search Button:_

If a user presses the search button, the user can enter a text string and search Flickr for posts related to the search string.  The search will return up to 100 results that occur within the coordinates currently displayed by the map view.  In other words, the four corners of the map view set the bounds of the area for which Flickr will return results.  If the search is successful, then up to 100 results will be displayed on the screen in the form of blue pins.  

If the pins are tapped, the user will be taken to the detail view controller screen.  In the detail view controller screen the user is shown the image retrieved from Flickr.  A navigation button labeled ‘back’ is present in the top left of the screen.  If the user presses the back button, then the user is taken back to the main map view.  


_Minus Button (Zoom Out Button):_

The Minus Button is used to Zoom out.  If this button is tapped then the view moves out so that a larger area is visible on the map.  


_Plus Button (Zoom In Button):_

The Plus Button is used to Zoom in.  If this button is tapped then the view moves in so that a smaller, more detailed area is visible on the map.  

_Delete Switch:_

The delete switch is located just to the right of the ‘Plus’ or ‘Zoom in Button’.  When the switch is turned on, all pins are removed from the map view, except for those pins that were posted by the user currently signed on the device.  This is done to allows the user to delete their own pins, but not pins of other users.  Pins tapped while the delete switch is on are removed from the device and Firebase.  Once the delete switch is turned off, all WildSpot pins are again displayed on the map view.  When the delete switch is turned on, an alert view appears that explains to the user that pins tapped while the switch is on will be deleted.  The user is also informed that to avoid delete pins, they should simply turn the delete switch off.  

_Sign Out:_

When the sign out button is pressed, the user is taken back to the Sign In screen where the options Sign in with google’ and ‘Sign in with email’ are displayed.

_Longpress:_  

If the user does a long press on the main map view an alert controller is displayed.   The alert controller asks the user to enter in some information about their wild spot.  Once the user presses enter, then the image picker is displayed.  Once the user selects a photo, the user is taken back to the main map view and a pin is added at the location of the long press.  Pins entered by users of wild spot will appear as green pins.  

_Detail View Controller:_

If the user taps a pin on the main map view, then the user will be taken to the detail view.  The detail view controller displays three things:

1. A map view with the pin tapped by the user displayed.  
2. An image view that will display the image associated with the pin.
3. A textfield that will display any text associated with the pin.  

The detail view controller will show an activity view while an image is being loaded.  The detail view controller also has a back button that allows the user to navigate back to the main map view.

**CONCLUSION**

That should be everything you need to know about WildSpot.  Thanks for trying out the app and good ‘spotting’.
