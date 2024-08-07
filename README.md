# Sharing-Extension
Sample to show the data transfer between the HostApp and the Sharing-Extension of a ContainingApp

See: https://developer.apple.com/forums/thread/759383  


###Preparations
Build and run the Containing target.  
Build and run the Host target.


### Debug the Extension
Choose the ShareExtension target, Run without building (it was built and installed with the ContainingApp).  
Xcode asks you to choose an app to run, choose the Hosting-App.

In the Hosting-App, tap one of the three sharing buttons, then select the ContainingApp to share with the ShareExtension.
