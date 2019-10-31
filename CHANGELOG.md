# Changelog

## 1.0.0
### Enhancements
* Updated the OpenSSL dependency to v1.1.1 (https://github.com/smartdevicelink/sdl_security_ios/issues/12).
* Certificate storage moved to the `Application Support` directory. This means certificates will now be backed up with iCloud and it also makes the certificate inaccessible from iTunes (https://github.com/smartdevicelink/sdl_security_ios/issues/15). 
* Added a manager for logging errors, warnings and debug statements to the console (https://github.com/smartdevicelink/sdl_security_ios/issues/10).  
* Errors returned by the library now return a detailed description of the error (https://github.com/smartdevicelink/sdl_security_ios/issues/16).
* Updated the certificate download code (https://github.com/smartdevicelink/sdl_security_ios/issues/17). 
* Updated the certificate manager to parse the JSON formatted response from the SDL Policy Server (https://github.com/smartdevicelink/sdl_security_ios/pull/37).
* Consolidated the setting of private constants in `SDLPrivateSecurityConstants` (https://github.com/smartdevicelink/sdl_security_ios/issues/29).

### Bug Fixes
* Fixed the permission manager processing permission updates incorrectly (https://github.com/smartdevicelink/sdl_security_ios/issues/13).
