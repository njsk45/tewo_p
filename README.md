# TeWo-P
- is a "Multi^2-PF" (Multiplatform-Multifunctional) point of sale (POS) system. It is a POS that can be run on different platforms and easily adapted for each kind of users.

- An ambitious project that aims to be an alternative to traditional POS systems, featuring modern functionalities and a clean, simple design.

# OBJECTIVES
       
  - To be a "Multi^2-PF" (Multiplatform-Multifunctional) point of sale system.
       
  - To be a POS system accessible to the user on any device.
       
  - To have both a local and a cloud database.
       
  - To feature a free-use and opensource version which allows sales processing and inventory management with limitations, but including the basic functionalities of a traditional POS.
       
  - To feature a premium-use version which allows sales processing and inventory management without limitations, but including advanced functionalities of a traditional POS.
       
  - To have versatility with APIs that allow integration with local, remote, and cloud DB models.
       
  - To have periodic free updates: Security, functionality, and support.

# BASE FUNCTIONALITIES

- Users

  - Login

  - Registration

  - Logout

  - Change password
       
- Inventory:
       
  - List products

  - Search products

  - Add products

  - Modify products

  - Delete products
       
- Sales:
       
  - List sales
       
  - Search sales
       
  - Add sales
       
  - Modify sales
       
  - Delete sales
       
- Reports:
       
  - List reports
              
  - Search reports
              
  - Add reports
              
  - Modify reports
              
  - Delete reports
       
- Configuration:
       
  - List configuration
              
  - Search configuration
              
  - Add configuration
              
  - Modify configuration
              
  - Delete configuration

- APIs:
  - Remote use from desktop devices (Administrator and Employee)
       
  - Remote use from mobile devices with Employee limitations (Login and sales only)

- lib EXPLANATION:

  - app_desktop: base functions for the desktop application
        
    - setting_up.dart: a way to set up the database management.
              
    - aws_service.dart: amazon aws database support.
              
    - ui_desktop: user interface for desktop.

  - app_movil: base functions for the mobile application

    - db_connector.dart: the function library for connecting to the remote database for the mobile application.
              
    - ui_movil: user interface for mobile.

MIT License (see LICENSE)
