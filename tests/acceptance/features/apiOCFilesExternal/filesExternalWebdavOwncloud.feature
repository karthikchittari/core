@api
Feature: files external using webdav_owncloud

  Background:
    Given using server "REMOTE"
    And user "user0" has been created with default attributes and without skeleton files
    And user "user0" has created folder "TestMnt"
    And using server "LOCAL"
    And user "user1" has been created with default attributes and without skeleton files

  Scenario: creating a webdav_owncloud external storage
    When user "user1" creates an external mount point with following configs using occ command
      | host                   | %remote_server%    |
      | root                   | TestMnt            |
      | secure                 | false              |
      | user                   | admin              |
      | password               | admin              |
      | storage_backend        | owncloud           |
      | mount_point            | TestMountPoint     |
      | authentication_backend | password::password |
    And the administrator verifies the mount configuration for local storage "TestMountPoint" using the occ command
    Then the following mount configuration information should be listed:
      | status | code | message |
      | ok     | 0    |         |
    And as "user1" folder "TestMountPoint" should exist

  Scenario:
    Given user "user1" has created an external mount point with following configs using occ command
      | host                   | %remote_server%    |
      | root                   | TestMnt            |
      | secure                 | false              |
      | user                   | admin              |
      | password               | admin              |
      | storage_backend        | owncloud           |
      | mount_point            | TestMountPoint     |
      | authentication_backend | password::password |
    When user "user1" has uploaded file with content "Hello from Local!" to "TestMountPoint/test.txt"
    And using server "REMOTE"
    And the content of file "/TestMnt/test.txt" for user "user0" should be "Hello from Local!"
