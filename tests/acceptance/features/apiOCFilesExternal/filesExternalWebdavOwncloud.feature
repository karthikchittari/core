Feature: files external using webdav_owncloud

  Scenario: creating a webdav_owncloud external storage
#    Given using server "REMOTE"
#    And user "user0" has been created with default attributes and without skeleton files
#    Given user "user0" has created folder "TestMnt"
#    And using server "LOCAL"
#    And user "user1" has been created with default attributes and without skeleton files
    When user "user1" has created an external mount point with following configs using occ command
      | host                   | http://localhost/ownCloudCore |
      | root                   | TestMnt                       |
      | secure                 | false                         |
      | storage_backend        | owncloud                      |
      | authentication_backend | password::password            |
    Then the command should have been successful
    And last created owncloud mount point should be verified
    And as "user1" folder "TestMnt" should exist

  Scenario:
    Given using server "REMOTE"
    And user "user0" has been created with default attributes and without skeleton files
    And user "user0" has created folder "TestMnt"
    And using server "LOCAL"
    And user "user1" has been created with default attributes and without skeleton files
    And user "user1" has created an external mount point with following configs using occ command
      | host                   | http://localhost/ownCloudCore |
      | root                   | TestMnt                       |
      | secure                 | false                         |
      | storage_backend        | owncloud                      |
      | authentication_backend | password::password            |
    When user "user1" has uploaded file with content "Hello from local" to "TestMnt/test.txt"
    And using server "REMOTE"
    Then as "user0" file "TestMnt/test.txt" should exist
