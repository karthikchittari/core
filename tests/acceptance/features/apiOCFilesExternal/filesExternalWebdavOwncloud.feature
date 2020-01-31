@api
Feature: using files external service with storage as webdav_owncloud

As a user
I want to be able to use webdav_owncloud as external storage
So that I can extend my storage service

  Background:
    Given using server "REMOTE"
    And user "user1" has been created with default attributes and without skeleton files
    And user "user1" has created folder "TestMnt"
    And using server "LOCAL"

  Scenario: creating a webdav_owncloud external storage
    When administrator creates an external mount point with following configuration using the occ command
      | host                   | %remote_server%    |
      | root                   | TestMnt            |
      | secure                 | false              |
      | user                   | user1              |
      | password               | %alt1%             |
      | storage_backend        | owncloud           |
      | mount_point            | TestMountPoint     |
      | authentication_backend | password::password |
    And the administrator verifies the mount configuration for local storage "TestMountPoint" using the occ command
    Then the following mount configuration information should be listed:
      | status | code | message |
      | ok     | 0    |         |
    And as "admin" folder "TestMountPoint" should exist

  Scenario: using webdav_owncloud as external storage
    Given administrator has created an external mount point with following configuration using the occ command
      | host                   | %remote_server%    |
      | root                   | TestMnt            |
      | secure                 | false              |
      | user                   | user1              |
      | password               | %alt1%             |
      | storage_backend        | owncloud           |
      | mount_point            | TestMountPoint     |
      | authentication_backend | password::password |
    When user "admin" has uploaded file with content "Hello from Local!" to "TestMountPoint/test.txt"
    And using server "REMOTE"
    Then as "user1" file "/TestMnt/test.txt" should exist
    And the content of file "/TestMnt/test.txt" for user "user1" should be "Hello from Local!"

  Scenario: deleting a webdav_owncloud external storage
    Given administrator creates an external mount point with following configuration using the occ command
      | host                   | %remote_server%    |
      | root                   | TestMnt            |
      | secure                 | false              |
      | user                   | user1              |
      | password               | 1234               |
      | storage_backend        | owncloud           |
      | mount_point            | TestMountPointtt   |
      | authentication_backend | password::password |
    When administrator deletes external storage with mount point "TestMountPointtt"
    Then the command should have been successful
    And mount point "/TestMountPointtt" should not be listed as created external storages
