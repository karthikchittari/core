@api @federation-app-required @TestAlsoOnExternalUserBackend @files_sharing-app-required
Feature: federated

  Background:
    Given using server "REMOTE"
    And user "user0" has been created with default attributes and skeleton files
    And using server "LOCAL"
    And user "user1" has been created with default attributes and skeleton files

  Scenario Outline: Federate share a file with another server
    Given using OCS API version "<ocs-api-version>"
    When user "user1" from server "LOCAL" shares "/textfile0.txt" with user "user0" from server "REMOTE" using the sharing API
    Then the OCS status code should be "<ocs-status>"
    And the HTTP status code should be "200"
    And the fields of the last response should include
      | id                     | A_NUMBER          |
      | item_type              | file              |
      | item_source            | A_NUMBER          |
      | share_type             | federated         |
      | file_source            | A_NUMBER          |
      | path                   | /textfile0.txt    |
      | permissions            | share,read,update |
      | stime                  | A_NUMBER          |
      | storage                | A_NUMBER          |
      | mail_send              | 0                 |
      | uid_owner              | user1             |
      | file_parent            | A_NUMBER          |
      | displayname_owner      | User One          |
      | share_with             | user0@REMOTE      |
      | share_with_displayname | user0@REMOTE      |
    Examples:
      | ocs-api-version | ocs-status |
      | 1               | 100        |
      | 2               | 200        |

  Scenario Outline: Federate share a file with local server
    Given using OCS API version "<ocs-api-version>"
    When user "user0" from server "REMOTE" shares "/textfile0.txt" with user "user1" from server "LOCAL" using the sharing API
    Then the OCS status code should be "<ocs-status>"
    And the HTTP status code should be "200"
    And the fields of the last response should include
      | id                     | A_NUMBER          |
      | item_type              | file              |
      | item_source            | A_NUMBER          |
      | share_type             | federated         |
      | file_source            | A_NUMBER          |
      | path                   | /textfile0.txt    |
      | permissions            | share,read,update |
      | stime                  | A_NUMBER          |
      | storage                | A_NUMBER          |
      | mail_send              | 0                 |
      | uid_owner              | user0             |
      | file_parent            | A_NUMBER          |
      | displayname_owner      | User Zero         |
      | share_with             | user1@LOCAL       |
      | share_with_displayname | user1@LOCAL       |
    Examples:
      | ocs-api-version | ocs-status |
      | 1               | 100        |
      | 2               | 200        |

  Scenario Outline: Remote sharee can see the pending share
    Given user "user0" from server "REMOTE" has shared "/textfile0.txt" with user "user1" from server "LOCAL"
    And using OCS API version "<ocs-api-version>"
    When user "user1" gets the list of pending federated cloud shares using the sharing API
    Then the OCS status code should be "<ocs-status>"
    And the HTTP status code should be "200"
    And the fields of the last response should include
      | id          | A_NUMBER                                   |
      | remote      | REMOTE                                     |
      | remote_id   | A_NUMBER                                   |
      | share_token | A_TOKEN                                    |
      | name        | /textfile0.txt                             |
      | owner       | user0                                      |
      | user        | user1                                      |
      | mountpoint  | {{TemporaryMountPointName#/textfile0.txt}} |
      | accepted    | 0                                          |
    Examples:
      | ocs-api-version | ocs-status |
      | 1               | 100        |
      | 2               | 200        |

  Scenario Outline: Remote sharee requests information of only one share
    Given user "user0" from server "REMOTE" has shared "/textfile0.txt" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And using OCS API version "<ocs-api-version>"
    When user "user1" retrieves the information of the last federated cloud share using the sharing API
    Then the OCS status code should be "<ocs-status>"
    And the HTTP status code should be "200"
    And the fields of the last response should include
      | id          | A_NUMBER                 |
      | remote      | REMOTE                   |
      | remote_id   | A_NUMBER                 |
      | share_token | A_TOKEN                  |
      | name        | /textfile0.txt           |
      | owner       | user0                    |
      | user        | user1                    |
      | mountpoint  | /textfile0 (2).txt       |
      | accepted    | 1                        |
      | type        | file                     |
      | permissions | share,read,update,delete |
    Examples:
      | ocs-api-version | ocs-status |
      | 1               | 100        |
      | 2               | 200        |

  @issue-34636
  Scenario Outline: Remote sharee requests information of only one share before accepting it
    Given user "user0" from server "REMOTE" has shared "/textfile0.txt" with user "user1" from server "LOCAL"
    And using OCS API version "<ocs-api-version>"
    When user "user1" retrieves the information of the last pending federated cloud share using the sharing API
    Then the HTTP status code should be "200" or "500"
    And the body of the response should be empty
    #Then the HTTP status code should be "200"
    #And the OCS status code should be "100"
    #And the fields of the last response should include
    #  | id          | A_NUMBER                                   |
    #  | remote      | REMOTE                                     |
    #  | remote_id   | A_NUMBER                                   |
    #  | share_token | A_TOKEN                                    |
    #  | name        | /textfile0.txt                             |
    #  | owner       | user0                                      |
    #  | user        | user1                                      |
    #  | mountpoint  | {{TemporaryMountPointName#/textfile0.txt}} |
    #  | accepted    | 0                                          |
    Examples:
      | ocs-api-version | ocs-status |
      | 1               | 100        |
      | 2               | 200        |

  Scenario Outline: sending a GET request to a pending remote share is not valid
    Given using OCS API version "<ocs-api-version>"
    When user "user1" sends HTTP method "GET" to OCS API endpoint "/apps/files_sharing/api/v1/remote_shares/pending/12"
    Then the HTTP status code should be "405"
    And the body of the response should be empty
    Examples:
      | ocs-api-version | ocs-status |
      | 1               | 100        |
      | 2               | 200        |

  Scenario Outline: sending a GET request to a not existing remote share
    Given using OCS API version "<ocs-api-version>"
    When user "user1" sends HTTP method "GET" to OCS API endpoint "/apps/files_sharing/api/v1/remote_shares/9999999999"
    Then the OCS status code should be "<ocs-status>"
    And the HTTP status code should be "<http-status>"
    Examples:
      | ocs-api-version | ocs-status | http-status |
      | 1               | 404        | 200         |
      | 2               | 404        | 404         |

  Scenario Outline: accept a pending remote share
    Given user "user0" from server "REMOTE" has shared "/textfile0.txt" with user "user1" from server "LOCAL"
    And using OCS API version "<ocs-api-version>"
    When user "user1" from server "LOCAL" accepts the last pending share using the sharing API
    Then the OCS status code should be "<ocs-status>"
    And the HTTP status code should be "200"
    Examples:
      | ocs-api-version | ocs-status |
      | 1               | 100        |
      | 2               | 200        |

  Scenario Outline: Reshare a federated shared file
    Given user "user0" from server "REMOTE" has shared "/textfile0.txt" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And using server "LOCAL"
    And user "user2" has been created with default attributes and skeleton files
    And using OCS API version "<ocs-api-version>"
    When user "user1" creates a share using the sharing API with settings
      | path        | /textfile0 (2).txt |
      | shareType   | user               |
      | shareWith   | user2              |
      | permissions | share,read,update  |
    Then the OCS status code should be "<ocs-status>"
    And the HTTP status code should be "200"
    And the fields of the last response should include
      | id                     | A_NUMBER           |
      | item_type              | file               |
      | item_source            | A_NUMBER           |
      | share_type             | user               |
      | file_source            | A_NUMBER           |
      | path                   | /textfile0 (2).txt |
      | permissions            | share,read,update  |
      | stime                  | A_NUMBER           |
      | storage                | A_NUMBER           |
      | mail_send              | 0                  |
      | uid_owner              | user1              |
      | file_parent            | A_NUMBER           |
      | displayname_owner      | User One           |
      | share_with             | user2              |
      | share_with_displayname | User Two           |
    Examples:
      | ocs-api-version | ocs-status |
      | 1               | 100        |
      | 2               | 200        |

  Scenario Outline: Overwrite a federated shared file as recipient - local server shares - remote server receives
    Given user "user1" from server "LOCAL" has shared "/textfile0.txt" with user "user0" from server "REMOTE"
    And user "user0" from server "REMOTE" has accepted the last pending share
    And using server "REMOTE"
    And using OCS API version "<ocs-api-version>"
    When user "user0" uploads file "filesForUpload/file_to_overwrite.txt" to "/textfile0 (2).txt" using the WebDAV API
    Then the HTTP status code should be "204"
    And the content of file "/textfile0.txt" for user "user1" on server "LOCAL" should be "BLABLABLA" plus end-of-line
    Examples:
      | ocs-api-version | ocs-status |
      | 1               | 100        |
      | 2               | 200        |

  Scenario Outline: Overwrite a federated shared file as recipient - remote server shares - local server receives
    Given user "user0" from server "REMOTE" has shared "/textfile0.txt" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And using OCS API version "<ocs-api-version>"
    When user "user1" uploads file "filesForUpload/file_to_overwrite.txt" to "/textfile0 (2).txt" using the WebDAV API
    Then the HTTP status code should be "204"
    And the content of file "/textfile0.txt" for user "user0" on server "REMOTE" should be "BLABLABLA" plus end-of-line
    Examples:
      | ocs-api-version | ocs-status |
      | 1               | 100        |
      | 2               | 200        |

  Scenario Outline: Overwrite a file in a federated shared folder as recipient - local server shares - remote server receives
    Given user "user1" from server "LOCAL" has shared "/PARENT" with user "user0" from server "REMOTE"
    And user "user0" from server "REMOTE" has accepted the last pending share
    And using server "REMOTE"
    And using OCS API version "<ocs-api-version>"
    When user "user0" uploads file "filesForUpload/file_to_overwrite.txt" to "/PARENT (2)/textfile0.txt" using the WebDAV API
    Then the HTTP status code should be "201"
    And the content of file "/PARENT/textfile0.txt" for user "user1" on server "LOCAL" should be "BLABLABLA" plus end-of-line
    Examples:
      | ocs-api-version | ocs-status |
      | 1               | 100        |
      | 2               | 200        |

  Scenario Outline: Overwrite a file in a federated shared folder as recipient - remote server shares - local server receives
    Given user "user0" from server "REMOTE" has shared "/PARENT" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And using OCS API version "<ocs-api-version>"
    When user "user1" uploads file "filesForUpload/file_to_overwrite.txt" to "/PARENT (2)/textfile0.txt" using the WebDAV API
    Then the HTTP status code should be "201"
    And the content of file "/PARENT/textfile0.txt" for user "user0" on server "REMOTE" should be "BLABLABLA" plus end-of-line
    Examples:
      | ocs-api-version | ocs-status |
      | 1               | 100        |
      | 2               | 200        |

  Scenario Outline: Overwrite a federated shared file as recipient using old chunking
    Given user "user0" from server "REMOTE" has shared "/textfile0.txt" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And using OCS API version "<ocs-api-version>"
    When user "user1" uploads the following "3" chunks to "/textfile0 (2).txt" with old chunking and using the WebDAV API
      | number | content |
      | 1      | AAAAA   |
      | 2      | BBBBB   |
      | 3      | CCCCC   |
    Then the HTTP status code should be "201"
    And the content of file "/textfile0 (2).txt" for user "user1" should be "AAAAABBBBBCCCCC"
    And the content of file "/textfile0.txt" for user "user0" on server "REMOTE" should be "AAAAABBBBBCCCCC"
    Examples:
      | ocs-api-version | ocs-status |
      | 1               | 100        |
      | 2               | 200        |

  Scenario Outline: Overwrite a file in a federated shared folder as recipient using old chunking
    Given user "user0" from server "REMOTE" has shared "/PARENT" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And using OCS API version "<ocs-api-version>"
    When user "user1" uploads the following "3" chunks to "/PARENT (2)/textfile0.txt" with old chunking and using the WebDAV API
      | number | content |
      | 1      | AAAAA   |
      | 2      | BBBBB   |
      | 3      | CCCCC   |
    Then the HTTP status code should be "201"
    And the content of file "/PARENT (2)/textfile0.txt" for user "user1" should be "AAAAABBBBBCCCCC"
    And the content of file "/PARENT/textfile0.txt" for user "user0" on server "REMOTE" should be "AAAAABBBBBCCCCC"
    Examples:
      | ocs-api-version | ocs-status |
      | 1               | 100        |
      | 2               | 200        |

  Scenario Outline: Remote sharee deletes an accepted federated share
    Given user "user0" from server "REMOTE" has shared "/textfile0.txt" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And using OCS API version "<ocs-api-version>"
    When user "user1" deletes the last federated cloud share using the sharing API
    Then the OCS status code should be "<ocs-status>"
    And the HTTP status code should be "200"
    And user "user1" should not see the following elements
      | /textfile0%20(2).txt |
    When user "user1" gets the list of federated cloud shares using the sharing API
    Then the response should contain 0 entries
    When user "user1" gets the list of pending federated cloud shares using the sharing API
    Then the response should contain 0 entries
    Examples:
      | ocs-api-version | ocs-status |
      | 1               | 100        |
      | 2               | 200        |

  @issue-31276
  Scenario Outline: Remote sharee tries to delete an accepted federated share sending wrong password
    Given user "user0" from server "REMOTE" has shared "/textfile0.txt" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And using OCS API version "<ocs-api-version>"
    When user "user1" deletes the last federated cloud share with password "invalid" using the sharing API
    Then the OCS status code should be "997"
    And the HTTP status code should be "401"
    And user "user1" should see the following elements
      | /textfile0%20(2).txt |
    When user "user1" gets the list of federated cloud shares using the sharing API
    Then the fields of the last response should include
      | id          | A_NUMBER                 |
      | remote      | REMOTE                   |
      | remote_id   | A_NUMBER                 |
      | share_token | A_TOKEN                  |
      | name        | /textfile0.txt           |
      | owner       | user0                    |
      | user        | user1                    |
      | mountpoint  | /textfile0 (2).txt       |
      | accepted    | 1                        |
      | type        | file                     |
      | permissions | share,delete,update,read |
    When user "user1" gets the list of pending federated cloud shares using the sharing API
    Then the response should contain 0 entries
    Examples:
      | ocs-api-version |
      | 1               |
      | 2               |

  Scenario Outline: Remote sharee deletes a pending federated share
    Given user "user0" from server "REMOTE" has shared "/textfile0.txt" with user "user1" from server "LOCAL"
    And using OCS API version "<ocs-api-version>"
    When user "user1" deletes the last pending federated cloud share using the sharing API
    Then the OCS status code should be "<ocs-status>"
    And the HTTP status code should be "200"
    And user "user1" should not see the following elements
      | /textfile0%20(2).txt |
    When user "user1" gets the list of federated cloud shares using the sharing API
    Then the response should contain 0 entries
    When user "user1" gets the list of pending federated cloud shares using the sharing API
    Then the response should contain 0 entries
    Examples:
      | ocs-api-version | ocs-status |
      | 1               | 100        |
      | 2               | 200        |

  @issue-31276
  Scenario Outline: Remote sharee tries to delete a pending federated share sending wrong password
    Given user "user0" from server "REMOTE" has shared "/textfile0.txt" with user "user1" from server "LOCAL"
    And using OCS API version "<ocs-api-version>"
    When user "user1" deletes the last pending federated cloud share with password "invalid" using the sharing API
    Then the OCS status code should be "997"
    And the HTTP status code should be "401"
    And user "user1" should not see the following elements
      | /textfile0%20(2).txt |
    When user "user1" gets the list of pending federated cloud shares using the sharing API
    Then the fields of the last response should include
      | id          | A_NUMBER                                   |
      | remote      | REMOTE                                     |
      | remote_id   | A_NUMBER                                   |
      | share_token | A_TOKEN                                    |
      | name        | /textfile0.txt                             |
      | owner       | user0                                      |
      | user        | user1                                      |
      | mountpoint  | {{TemporaryMountPointName#/textfile0.txt}} |
      | accepted    | 0                                          |
    When user "user1" gets the list of federated cloud shares using the sharing API
    Then the response should contain 0 entries
    Examples:
      | ocs-api-version |
      | 1               |
      | 2               |

  Scenario Outline: Trusted server handshake does not require authenticated requests - we force 403 by sending an empty body
    Given using server "LOCAL"
    And using OCS API version "<ocs-api-version>"
    When user "UNAUTHORIZED_USER" requests shared secret using the federation API
    Then the HTTP status code should be "<http-status>"
    Then the OCS status code should be "403"
    Examples:
      | ocs-api-version | http-status |
      | 1               | 200         |
      | 2               | 403         |

  @skipOnLDAP
  Scenario: Upload file to received federated share while quota is set on home storage
    Given user "user0" from server "REMOTE" has shared "/PARENT" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And using server "LOCAL"
    When user "user1" uploads file "filesForUpload/textfile.txt" to filenames based on "/PARENT (2)/testquota.txt" with all mechanisms using the WebDAV API
    Then the HTTP status code of all upload responses should be "201"
    And as user "user0" on server "REMOTE" the files uploaded to "/PARENT/testquota.txt" with all mechanisms should exist

  @skipOnLDAP
  Scenario: Upload file to received federated share while quota is set on remote storage - local server shares - remote server receives
    Given using server "LOCAL"
    And the quota of user "user1" has been set to "20 B"
    And user "user1" from server "LOCAL" has shared "/PARENT" with user "user0" from server "REMOTE"
    And user "user0" from server "REMOTE" has accepted the last pending share
    And using server "REMOTE"
    When user "user0" uploads file "filesForUpload/textfile.txt" to filenames based on "/PARENT (2)/testquota.txt" with all mechanisms using the WebDAV API
    Then the HTTP status code of all upload responses should be "507"

  @skipOnLDAP
  Scenario: Upload file to received federated share while quota is set on remote storage - remote server shares - local server receives
    Given using server "REMOTE"
    And the quota of user "user0" has been set to "20 B"
    And user "user0" from server "REMOTE" has shared "/PARENT" with user "user1" from server "LOCAL"
    And user "user1" from server "LOCAL" has accepted the last pending share
    And using server "LOCAL"
    When user "user1" uploads file "filesForUpload/textfile.txt" to filenames based on "/PARENT (2)/testquota.txt" with all mechanisms using the WebDAV API
    Then the HTTP status code of all upload responses should be "507"


  Scenario Outline: share of a folder to a remote user who already has a folder with the same name
    Given using server "REMOTE"
    And user "user0" has created folder "/zzzfolder"
    And user "user0" has created folder "zzzfolder/user0"
    And using server "LOCAL"
    And user "user1" has created folder "/zzzfolder"
    And user "user1" has created folder "zzzfolder/user1"
    When user "user0" from server "REMOTE" shares "zzzfolder" with user "user1" from server "LOCAL" using the sharing API
    And user "user1" from server "LOCAL" has accepted the last pending share
    And using OCS API version "<ocs-api-version>"
    When user "user1" retrieves the information of the last federated cloud share using the sharing API
    Then the OCS status code should be "<ocs-status>"
    And the HTTP status code should be "200"
    And the fields of the last response should include
      | id          | A_NUMBER       |
      | remote      | REMOTE         |
      | name        | /zzzfolder     |
      | owner       | user0          |
      | user        | user1          |
      | mountpoint  | /zzzfolder (2) |
      | type        | dir            |
      | permissions | all            |
    And as "user1" folder "zzzfolder/user1" should exist
    And as "user1" folder "zzzfolder (2)/user0" should exist
    Examples:
      | ocs-api-version | ocs-status |
      | 1               | 100        |
      | 2               | 200        |

  Scenario Outline: share of a file to the remote user who already has a file with the same name
    Given using server "REMOTE"
    And user "user0" has uploaded file with content "remote content" to "/randomfile.txt"
    And using server "LOCAL"
    And user "user1" has uploaded file with content "local content" to "/randomfile.txt"
    When user "user0" from server "REMOTE" shares "/randomfile.txt" with user "user1" from server "LOCAL" using the sharing API
    And user "user1" from server "LOCAL" has accepted the last pending share
    And using OCS API version "<ocs-api-version>"
    When user "user1" retrieves the information of the last federated cloud share using the sharing API
    Then the OCS status code should be "<ocs-status>"
    And the HTTP status code should be "200"
    And the fields of the last response should include
      | id          | A_NUMBER                 |
      | remote      | REMOTE                   |
      | remote_id   | A_NUMBER                 |
      | share_token | A_TOKEN                  |
      | name        | /randomfile.txt          |
      | owner       | user0                    |
      | user        | user1                    |
      | mountpoint  | /randomfile (2).txt      |
      | accepted    | 1                        |
      | type        | file                     |
      | permissions | share,delete,update,read |
    And the content of file "/randomfile.txt" for user "user1" on server "LOCAL" should be "local content"
    And the content of file "/randomfile (2).txt" for user "user1" on server "LOCAL" should be "remote content"
    Examples:
      | ocs-api-version | ocs-status |
      | 1               | 100        |
      | 2               | 200        |

  @issue-35154
  Scenario: receive a local share that has the same name as a previously received remote share
    Given using server "REMOTE"
    And user "user0" has created folder "/zzzfolder"
    And user "user0" has created folder "zzzfolder/remote"
    And user "user0" has uploaded file with content "remote content" to "/randomfile.txt"
    And using server "LOCAL"
    And user "user2" has been created with default attributes and skeleton files
    And user "user1" has created folder "/zzzfolder"
    And user "user1" has created folder "zzzfolder/local"
    And user "user1" has uploaded file with content "local content" to "/randomfile.txt"
    When user "user0" from server "REMOTE" shares "zzzfolder" with user "user2" from server "LOCAL" using the sharing API
    And user "user2" from server "LOCAL" accepts the last pending share using the sharing API
    And user "user0" from server "REMOTE" shares "randomfile.txt" with user "user2" from server "LOCAL" using the sharing API
    And user "user2" from server "LOCAL" accepts the last pending share using the sharing API
    And user "user1" shares folder "zzzfolder" with user "user2" using the sharing API
    And user "user1" shares folder "randomfile.txt" with user "user2" using the sharing API
    # local shares are taking priority at the moment
    Then as "user2" folder "zzzfolder (2)/remote" should exist
    And as "user2" folder "zzzfolder/local" should exist
    And the content of file "/randomfile (2).txt" for user "user2" on server "LOCAL" should be "remote content"
    And the content of file "/randomfile.txt" for user "user2" on server "LOCAL" should be "local content"

  Scenario: receive a remote share that has the same name as a previously received local share
    Given using server "REMOTE"
    And user "user0" has created folder "/zzzfolder"
    And user "user0" has created folder "zzzfolder/remote"
    And user "user0" has uploaded file with content "remote content" to "/randomfile.txt"
    And using server "LOCAL"
    And user "user2" has been created with default attributes and skeleton files
    And user "user1" has created folder "/zzzfolder"
    And user "user1" has created folder "zzzfolder/local"
    And user "user1" has uploaded file with content "local content" to "/randomfile.txt"
    When user "user1" shares folder "zzzfolder" with user "user2" using the sharing API
    And user "user1" shares folder "randomfile.txt" with user "user2" using the sharing API
    And user "user0" from server "REMOTE" shares "zzzfolder" with user "user2" from server "LOCAL" using the sharing API
    And user "user2" from server "LOCAL" accepts the last pending share using the sharing API
    And user "user0" from server "REMOTE" shares "randomfile.txt" with user "user2" from server "LOCAL" using the sharing API
    And user "user2" from server "LOCAL" accepts the last pending share using the sharing API
    Then as "user2" folder "zzzfolder/local" should exist
    And as "user2" folder "zzzfolder (2)/remote" should exist
    And the content of file "/randomfile.txt" for user "user2" on server "LOCAL" should be "local content"
    And the content of file "/randomfile (2).txt" for user "user2" on server "LOCAL" should be "remote content"

  @issue-35839
  Scenario: "Auto accept from trusted servers" enabled with remote server
    Given the trusted server list is cleared
    # Remove this line once the issue is resolved
    And parameter "autoAddServers" of app "federation" has been set to "0"
    And parameter "auto_accept_trusted" of app "federatedfilesharing" has been set to "yes"
    When the administrator adds url "%remote_server%" as trusted server using the testing API
    And user "user0" from server "REMOTE" shares "/textfile1.txt" with user "user1" from server "LOCAL" using the sharing API
    And using server "LOCAL"
    Then as "user1" file "textfile1 (2).txt" should exist
    And url "%remote_server%" should be a trusted server

  @issue-35839
  Scenario: "Auto accept from trusted servers" disabled with remote server
    Given the trusted server list is cleared
    # Remove this line once the issue is resolved
    And parameter "autoAddServers" of app "federation" has been set to "0"
    And parameter "auto_accept_trusted" of app "federatedfilesharing" has been set to "no"
    When the administrator adds url "%remote_server%" as trusted server using the testing API
    And user "user0" from server "REMOTE" shares "/textfile1.txt" with user "user1" from server "LOCAL" using the sharing API
    And using server "LOCAL"
    Then as "user1" file "textfile1 (2).txt" should not exist
    And url "%remote_server%" should be a trusted server

  Scenario: Federated share with "Auto add server" enabled
    Given the trusted server list is cleared
    And using server "LOCAL"
    And parameter "autoAddServers" of app "federation" has been set to "1"
    When user "user0" from server "REMOTE" shares "/textfile1.txt" with user "user1" from server "LOCAL" using the sharing API
    And user "user1" from server "LOCAL" has accepted the last pending share
    And using server "LOCAL"
    Then as "user1" file "textfile1 (2).txt" should exist
    And url "%remote_server%" should be a trusted server

  Scenario: Federated share with "Auto add server" disabled
    Given the trusted server list is cleared
    And parameter "autoAddServers" of app "federation" has been set to "0"
    When user "user0" from server "REMOTE" shares "/textfile1.txt" with user "user1" from server "LOCAL" using the sharing API
    And user "user1" from server "LOCAL" has accepted the last pending share
    And using server "LOCAL"
    Then as "user1" file "textfile1 (2).txt" should exist
    And url "%remote_server%" should not be a trusted server

  @issue-35839
  Scenario: enable "Add server automatically" once a federated share was created successfully
    Given using server "LOCAL"
    And parameter "autoAddServers" of app "federation" has been set to "1"
    And parameter "auto_accept_trusted" of app "federatedfilesharing" has been set to "yes"
    When user "user0" from server "REMOTE" shares "/textfile0.txt" with user "user1" from server "LOCAL" using the sharing API
    And user "user1" from server "LOCAL" has accepted the last pending share
    And using server "LOCAL"
    Then url "%remote_server%" should be a trusted server
    When user "user0" from server "REMOTE" shares "/textfile1.txt" with user "user1" from server "LOCAL" using the sharing API
    # Uncomment this line once the issue is resolved
    # Then as "user1" file "textfile1 (2).txt" should exist
    Then as "user1" file "textfile1 (2).txt" should not exist

  @issue-35839
  Scenario: disable "Add server automatically" once a federated share was created successfully
    Given using server "LOCAL"
    And the trusted server list is cleared
    And parameter "autoAddServers" of app "federation" has been set to "0"
    And parameter "auto_accept_trusted" of app "federatedfilesharing" has been set to "yes"
    When user "user0" from server "REMOTE" shares "/textfile0.txt" with user "user1" from server "LOCAL" using the sharing API
    And user "user1" from server "LOCAL" has accepted the last pending share
    And using server "LOCAL"
    Then url "%remote_server%" should not be a trusted server
    # Remove this line once the issue is resolved
    When the administrator sets parameter "autoAddServers" of app "federation" to "0"
    And user "user0" from server "REMOTE" shares "/textfile1.txt" with user "user1" from server "LOCAL" using the sharing API
    And as "user1" file "textfile1 (2).txt" should not exist
