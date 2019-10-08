# SDL Security iOS
SDL Security is a security library for encrypting data transmitted betwen an [SDL iOS application](https://github.com/smartdevicelink/sdl_ios) and [SDL Core](https://github.com/smartdevicelink/sdl_core). On setup, a certificate associated with the SDL app's unique app id is downloaded from a URL. Then, the OpenSSL cryptographic library is used to validate the certificate and encrypt and decrypt data using the TLS protocol. 

### How it Works
SDL Security is an example security library that automotive OEMs can use to build their own proprietary security library. This security library must be configured by an OEM to work with their prioprietary version of SDL Core. Once the security library has been configured by the OEM, it is used to generate a static library that developers add to their SDL iOS apps.

### What can be Encrypted?
This library can be used to encrypt [SDL services](https://github.com/smartdevicelink/protocol_spec#5-services) such as the video, audio or RPC services.  

## Configuring the Library
The following customizations must be made by the OEM in order for the library to work with their proprietary version of SDL Core.

### Certificate URL
The `CertQAURL` URL in the **SDLPrivateSecurityConstants.m** file should to be updated to point to a database that will return certificate data for a specific SDL `appID`. The certificate data will be stored on disk as a `.pfx` file so it can persist between app sessions. If the certficate has expired, the library will automatically try to download a new certficate.     

Anyone implementing this library should take care to add additional protections during the download of the certficate and storage of the certificate. Otherwise, it will be quite easy for an attacker to take the certificate and defeat the TLS protection.

### Vehicle Makes
The `availableMakes` property should be updated in the **SDLSecurityManager.m** file to list all supported vehicle types. The `vehicleType` returned by SDL Core's `RegisterAppInterface` response is used to select the security manager associated with that vehicle type. It is important that the vehicle types listed in `availableMakes` match exactly the `vehicleType`s returned by the `RegisterAppInterface` response, otherwise the security manager will not be selected and configured. 

### Certificate Validation
In order to validate the downloaded mobile certficate, the security library needs the TLS issuer and certficate password used to generate the certificate. Currently the the `SDLTLSIssuer` and `SDLTLSCertPassword` properties used to validate the certficate are hardcoded in the **SDLPrivateSecurityConstants.m** file. 

### Certificate Storage
Once the certificate is downloaded it is stored on disk so the certfifcate can persist between app sessions. The `VendorName` property in the  **SDLSecurityManager.m** file is used to create a directory where your certificate is stored. We recommend updating this property to your company name. 

### Renaming the Library
In order to use this security library with SDL, an OEM must rename this library and classes. This is because a developer who wants to support multiple OEMS will have to add a security manager from each OEM. If OEMS use the same class names then it will be impossible for the developer to include more than one security library in their application.

## Generating the Static Security Library
Once the security library has been configured by the OEM, it is used to generate a static library that developers add to their SDL iOS apps. You can easily build the static library, **libSDLSecurityStatic.a**, in Xcode using the **SDLSecurityStatic** target:

1. In the scheme menu of Xcode, set the active scheme to **SDLSecurityStatic**.
1. Build and run the **SDLSecurityStatic** scheme (**Product > Build For > Running**). 
1. In the project navigator you will find the **libSDLSecurityStatic.a** build under **SDLSecurity > Products**.
1. Right click on the **libSDLSecurityStatic.a** build and select **Show in Finder**. This will take you to the derived data of the project which has the three builds listed below:
    * *Debug-iphoneos* - will only work on an iPhone 
    * *Debug-iphonesimulator* - will only work on a simulator
    * *Debug-universal*  - will work on both the iPhone and simulator
1. There are also two header files **include/SDLSecurityConstants.h** and **include/SDLSecurityManager.h** that must be used along with **libSDLSecurityStatic.a** archive build.
    
## Adding the Static Security Library to a SDL App
In order to use the static security library in an SDL app you must have three files: **libSDLSecurityStatic.a**, **SDLSecurityConstants.h** and **SDLSecurityManager.h**

1. In Xcode, drag and drop the following 3 files into your project: **libSDLSecurityStatic.a**, **SDLSecurityConstants.h** and **SDLSecurityManager.h**. Make sure **libSDLSecurityStatic.a** has been added to the project's target membership.  
1. Import **SDLSecurityManager.h** into the file where the the SDLConfiguration`'s `SDLEncryptionConfiguration` is being set. If you have a Swift project, this will require adding a bridging-header to the project.
    `let encryptionManager = SDLEncryptionConfiguration(securityManagers: [SDLSecurityManager.self]], delegate: nil)`

## Updating the OpenSSL Dependency
We have included a build of the OpenSSL library  so the security library can work out of the box with a few minor customizations. Production versions of this library should replace the OpenSSL dependency with a trusted build. The following configurations may have to be updated:

1. When dragging and dropping the **OpenSSL** library into the project root, make sure to select the following in the popup:
    * Select **Copy items if needed**
    * In the **Add to Targets** section, select the *SDLSecurityStatic* target.
2. Configure the build settings for the targets.
    * For both the *SDLSecurity* and *SDLSecurityStatic* targets:
        * In **Build Settings > Library Search Paths** include the path to the **libcrypto.a** and **libssl.a** static libraries (`"$(SRCROOT)/Dependencies/OpenSSL/lib"`)
        * In **Build Settings > Header Search Paths** include the path to the **OpenSSL** public headers (`"$(SRCROOT)/Dependencies/OpenSSL/include"`)
    * For both the *SDLSecurityStatic* targets:
        * Set **Build Settings > Build Options > Enable Bitcode** to No. This must be done as the included **libcrypto.a** and **libssl.a** static libraries were not built to support bitcode (this feature can be added later). 
    * For the *SDLSecurityStatic* target:
        * To update the name of the folder where the generated public header files are placed edit the **Build Settings > Packaging > Public Headers Folder Path** (currently the folder's name is **include**)
        
### Adding Your Own OpenSSL Build
### Common Issues

| OS Name | Xcode Platform Name | Valid Architectures | Clang -mxxx-version-min |
| iOS | iPhoneOS | arm64 armv7 armv7s  | -miphoneos-version-min or -mios-version-min |
| iOS Simulator | iPhoneOSSimulator | i386 x86_64 | -miphonesimulator-version-min or -mios-simulator-version-min |

