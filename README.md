# SDL Security iOS
SDL Security is a security library for encrypting data transmitted between an [SDL iOS application](https://github.com/smartdevicelink/sdl_ios) and [SDL Core](https://github.com/smartdevicelink/sdl_core). On setup, a certificate associated with the SDL app's unique app id is downloaded from a URL. Then the OpenSSL cryptographic library is used to encrypt and decrypt data using the DTLS protocol.

### How It Works
SDL Security is an example security library that automotive OEMs can use to build their own proprietary security libraries. The security library must be modified by the OEM to work with their proprietary version of SDL Core. Once the security library has been modified, it is used to generate a static library that developers add to their SDL iOS apps.

OEMs implementing this library should take care to add additional protections as this library is not cryptographically secure out-of-the box.

### What Can Be Encrypted?
This library can be used to encrypt [SDL services](https://github.com/smartdevicelink/protocol_spec#5-services) such as the video, audio or RPC services.

## Configuring the Library
The following customizations must be made by the OEM in order for the library to work with their proprietary version of SDL Core:

### Certificate URL
The `CertQAURL` URL in the **SDLPrivateSecurityConstants.m** file should be updated to point to a database that will return certificate data for a specific SDL `appID`. The certificate data will be stored on disk as a `.pfx` file so it can persist between app sessions. If the certificate has expired, the library will automatically try to download a new certificate. 

Depending on the what you return for the certificate request, you may have to update how the certificate is extracted from the JSON object in **_SDLCertificateManager.m**. Currently the certificate manager is setup to handle parsing this JSON format:
```
{
  "meta": {
  "request_id": "...",
    "code": 200,
    "message": null
  },
  "data": {
    "certificate": "..."
  }
}
```

### Vehicle Makes
The `availableMakes` property should be updated in the **SDLSecurityManager.m** file to list all supported vehicle types. The `vehicleType` returned by SDL Core's `RegisterAppInterface` response is used to select the security manager associated with that vehicle type. It is important that the vehicle types listed in `availableMakes` match exactly the `vehicleType`s returned by the `RegisterAppInterface` response, otherwise the security manager will not be selected and configured. 

### Checking Certificate Parameters
In order to check the mobile certificate parameters, the security library needs the TLS issuer and certificate password used to generate the certificate. Currently the the `SDLTLSIssuer` and `SDLTLSCertPassword` properties used to check the certificate are hardcoded in the **SDLPrivateSecurityConstants.m** file. 

### Certificate Storage
Once the certificate is downloaded it is stored on disk so the certificate can persist between app sessions. The `VendorName` property in the **SDLPrivateSecurityConstants.m** file is used to create a directory where your certificate is stored. We recommend updating this property to your company name. 

### Renaming the Library
In order to use this security library with SDL, an OEM must rename this library and classes. This is because a developer who wants to support multiple OEMS will have to add a security manager from each OEM. If OEMS use the same class names then it will be impossible for the developer to include more than one security library in their application.

## Generating the Static Security Library
Once the security library has been configured by the OEM, it is used to generate a static library that developers add to their SDL iOS apps. The static library, **libSDLSecurityStatic.a**, can easily be built in Xcode using the **SDLSecurityStatic** target:

1. In the scheme menu of Xcode, set the active scheme to **SDLSecurityStatic**.
1. Build and run the **SDLSecurityStatic** scheme (**Product > Build For > Running**). 
1. In the project navigator you will find the **libSDLSecurityStatic.a** build under **SDLSecurity > Products**.
1. Right click on the **libSDLSecurityStatic.a** build and select **Show in Finder**. This will take you to the derived data of the project which has the three builds listed below:
    * *Debug-iphoneos* - will only work on an iPhone 
    * *Debug-iphonesimulator* - will only work on a simulator
    * *Debug-universal* - will work on both the iPhone and simulator
1. There are also two header files in the **include** folder, **SDLSecurityConstants.h** and **SDLSecurityManager.h** that must be included along with **libSDLSecurityStatic.a** archive build.
    
## Adding the Static Security Library to a SDL App
1. In Xcode, drag and drop the following 3 files into your project: **libSDLSecurityStatic.a**, **SDLSecurityConstants.h** and **SDLSecurityManager.h** (or their equivalents after OEM naming modifications are made). Make sure **libSDLSecurityStatic.a** has been added to the project's target membership.  
1. Import **SDLSecurityManager.h** into the file where the the `SDLConfiguration`'s `SDLEncryptionConfiguration` or `SDLStreamingMediaConfiguration` is being set. If you have a Swift project, this will require adding a bridging header to the project.

### Adding the SDLSecurityManager to a Project
#### Swift
```swift
let encryptionConfig = SDLEncryptionConfiguration(securityManagers: [SDLSecurityManager.self]], delegate: nil)
```

#### Objective-C
```objc
SDLEncryptionConfiguration *encryptionConfig = [[SDLEncryptionConfiguration alloc] initWithSecurityManagers:@[SDLSecurityManager.self] delegate:nil];
```

## Updating the OpenSSL Dependency
We have included a build of the OpenSSL library so that the security library can work out of the box with a few minor customizations. However, this example does not often update the OpenSSL build and it is provided for example purposes. Production versions of this library should replace the OpenSSL dependency with an updated and trusted build. The following configurations may have to be updated:

1. Make sure that the OpenSSL library builds **libcrypto.a** and **libssl.a** have been added to the **SDLSecurityStatic** target.
1. Configure the build settings for the **SDLSecurityStatic** target.
    * In **Build Settings > Library Search Paths** include the path to the **libcrypto.a** and **libssl.a** static libraries.
    * In **Build Settings > Header Search Paths** include the path to the **OpenSSL** public headers.
