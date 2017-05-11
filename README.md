# IMConfig
Configuration Reports and Tools for PTC Integrity Lifecycle Manager Administrators

This solution set is a group of Reports and Tools helping Integrity Administrators to manage PTC Integrity Lifecycle Manager implementations better.
The Development has been started back in 2013, and is continued over the past years with additional reports.

A of now it contains the following reports and tools.

1) Configuration Reports

- Type Fields
- Pick List Values
- User (Dynamic) Group Assignment
- Static Group Details
- Static Group and Object Refs
- Dynamic Group Details
- Dynamic Group and Object Refs


2) Administrative Reports & Tools

- Currently Unused Fields
- Recently Changed Objects
- Stage Configuration
- Type Property Checker
- Type Usage

Unfortunately, some of the reports are not workting in all environments (developed with MSSQL DB, partially tested with Oracle DB).

Important: It is NOT intended to be used in Production. It is intended to be used in a staging environment chain with DEV > TEST > PROD 
on TEST only for validation purposes.

Tested with:
- Integrity 10.6
- Integrity 10.8
- Integrity 10.9
- Integrity 11.0

Installation Instruction:

- Copy IMConfig.war to IntegrityServer\server\mks\deploy
- Configure the Server Side API Connection in is.properties

mksis.apiSession.defaultUser=<username>
mksis.apiSession.defaultPassword=<password>

- In case of issues check the Server.log

Looking forward to your suggestions, ideas, feedback.

Thank you
Volker Eckardt

March/2017
