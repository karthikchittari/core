@webUI @insulated @disablePreviews @systemtags-app-required
Feature: Creation of tags for the files and folders
  As a user
  I want to create tags for the files/folders
  So that I can find them easily

  Background:
    Given these users have been created with default attributes and without skeleton files:
      | username |
      | user1    |
    And the user has browsed to the login page
    And the user has logged in with username "user1" and password "%alt1%" using the webUI

  Scenario: Create a new tag that does not exist for a file in the root
    Given user "user1" has uploaded file with content "some content" to "/randomfile.txt"
    When the user browses directly to display the details of file "randomfile.txt" in folder "/"
    And the user adds a tag "Top Secret" to the file using the webUI
    And the user adds a tag "Confidential" to the file using the webUI
    Then file "/randomfile.txt" should have the following tags for user "user1"
      | name         | type   |
      | Top Secret   | normal |
      | Confidential | normal |

  Scenario: Create a new tag that does not exist for a file in a folder
    Given user "user1" has created folder "a-folder"
    And user "user1" has uploaded file with content "some content" to "/a-folder/randomfile.txt"
    When the user browses directly to display the details of file "randomfile.txt" in folder "a-folder"
    And the user adds a tag "Top Secret" to the file using the webUI
    And the user adds a tag "Top" to the file using the webUI
    Then file "a-folder/randomfile.txt" should have the following tags for user "user1"
      | name       | type   |
      | Top Secret | normal |
      | Top        | normal |

  Scenario: Add a new tag that already exists for a file in a folder
    Given user "user1" has created folder "a-folder"
    And user "user1" has uploaded file with content "some content" to "/a-folder/randomfile.txt"
    And user "user1" has uploaded file with content "some content" to "/a-folder/randomfile-big.txt"
    And the user has created a "normal" tag with name "randomfile"
    And the user has added tag "randomfile" to file "/a-folder/randomfile.txt"
    When the user browses directly to display the details of file "randomfile-big.txt" in folder "a-folder"
    And the user adds a tag "randomfile" to the file using the webUI
    Then file "a-folder/randomfile.txt" should have the following tags for user "user1"
      | name       | type   |
      | randomfile | normal |
    And file "a-folder/randomfile-big.txt" should have the following tags for user "user1"
      | name       | type   |
      | randomfile | normal |

  @skipOnFIREFOX @files_sharing-app-required
  Scenario: Create and add tag on a shared file
    Given user "user2" has been created with default attributes and without skeleton files
    And user "user1" has uploaded file with content "some content" to "/randomfile.txt"
    And the user browses directly to display the details of file "randomfile.txt" in folder "/"
    When the user adds a tag "tag1" to the file using the webUI
    And the user shares file "randomfile.txt" with user "User Two" using the webUI
    And the user re-logs in with username "user2" and password "%alt2%" using the webUI
    And the user browses directly to display the details of file "randomfile.txt" in folder "/"
    And the user adds a tag "tag2" to the file using the webUI
    Then file "randomfile.txt" should have the following tags for user "user1"
      | name | type   |
      | tag1 | normal |
      | tag2 | normal |
    And file "randomfile.txt" should have the following tags for user "user2"
      | name | type   |
      | tag1 | normal |
      | tag2 | normal |

  @files_sharing-app-required
  Scenario: Add tags on skeleton file before sharing
    Given these users have been created with skeleton files:
      | username |
      | user2    |
      | user3    |
    And the user re-logs in as "user2" using the webUI
    And the user browses directly to display the details of file "lorem.txt" in folder "/"
    When the user adds a tag "skeleton" to the file using the webUI
    And the user shares file "lorem.txt" with user "user3" using the webUI
    Then file "lorem (2).txt" should have the following tags for user "user3"
      | name     | type   |
      | skeleton | normal |

  @files_sharing-app-required
  Scenario: Check for existence of tags in shared file
    Given user "user2" has been created with default attributes and without skeleton files
    And user "user1" has uploaded file with content "some content" to "/randomfile.txt"
    When the user browses directly to display the details of file "randomfile.txt" in folder "/"
    And the user adds a tag "Confidential" to the file using the webUI
    And the user shares file "randomfile.txt" with user "User Two" using the webUI
    Then file "/randomfile.txt" should have the following tags for user "user2"
      | name         | type   |
      | Confidential | normal |

