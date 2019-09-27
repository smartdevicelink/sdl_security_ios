# SDL Security iOS
SDL Security is a security library for encrypting data transmitted betwen an [SDL iOS application](https://github.com/smartdevicelink/sdl_ios) and [SDL Core](https://github.com/smartdevicelink/sdl_core). On setup, a certificate associated with the SDL app's unique app id is downloaded from a URL. Then, the OpenSSL cryptographic library is used to validate the certificate and encrypt and decrypt data using the TLS protocol. 

## What can be Encrypted?
This library can be used to encrypt [SDL services](https://github.com/smartdevicelink/protocol_spec#5-services) such as the video, audio or RPC services.  

## Configuring the Library
SDL Security is an example security library that automotive OEMs can use to build their own proprietary security library. Once the library has been configured by the OEM, it can be used to generate a static security manager library that developers add to their SDL iOS apps. The following customizations must be made by the OEM in order for the library to work with their proprietary version of SDL Core.

### Certificate URL
The `CertQAURL` URL in the **SDLPrivateSecurityConstants.m** file should to be updated to point to a database that will return certificate data for a specific SDL `appID`. The certificate data will be stored on disk as a `.pfx` file so it can persist between app sessions. If the certficate has expired, the library will automatically try to download a new certficate.     

Anyone implementing this library should take care to add additional protections during the download of the certficate and storage of the certificate. Otherwise, it will be quite easy for an attacker to take the certificate and defeat the TLS protection.

### Vehicle Makes
The `availableMakes` property should be updated in the **SDLSecurityManager.m** file to list all supported vehicle types. The `vehicleType` returned by SDL Core's `RegisterAppInterface` response is used to select the security manager associated with that vehicle type. It is important that the vehicle types listed in `availableMakes` match exactly the `vehicleType`s returned by the `RegisterAppInterface` response, otherwise the security manager will not be selected and configured. 

### Certificate Validation
In order to validate the downloaded mobile certficate, the security library needs the TLS issuer and certficate password used to generate the certificate. Currently the the `SDLTLSIssuer` and `SDLTLSCertPassword` properties used to validate the certficate are hardcoded in the **SDLPrivateSecurityConstants.m** file. 

### Renaming the Library
In order to use this security library with SDL, an OEM must rename this library and classes. This is because a developer who wants to support multiple OEMS will have to add a security manager from each OEM. If OEMS use the same class names then it will be impossible for the developer to include more than one security library in their application.

## Creating the Static Library
Since you will not want developers to have access to your security library code, you will want to give them a static `.a` file with some public headers. 


## Configuring the Library
### Adding Your Own OpenSSL Build
### Common Issues

