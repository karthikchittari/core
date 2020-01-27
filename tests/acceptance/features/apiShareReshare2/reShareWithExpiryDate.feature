@api @TestAlsoOnExternalUserBackend @files_sharing-app-required
Feature: resharing a resource with an expiration date

  Background:
    Given user "user0" has been created with default attributes and skeleton files
    And user "user1" has been created with default attributes and without skeleton files

  @skipOnOcV10.3
  Scenario Outline: User should be able to set expiration while resharing a file with user
    Given using OCS API version "<ocs_api_version>"
    And user "user2" has been created with default attributes and without skeleton files
    And user "user0" has shared file "/textfile0.txt" with user "user1" with permissions "read,update,share"
    When user "user1" creates a share using the sharing API with settings
      | path        | textfile0.txt |
      | shareType   | user          |
      | permissions | change        |
      | shareWith   | user2         |
      | expireDate  | +3 days       |
    Then the HTTP status code should be "200"
    And the OCS status code should be "<ocs_status_code>"
    And the information of the last share of user "user1" should include
      | expiration | +3 days |
    And the response when user "user2" gets the info of the last share should include
      | expiration | +3 days |
    Examples:
      | ocs_api_version | ocs_status_code |
      | 1               | 100             |
      | 2               | 200             |

  @skipOnOcV10.3
  Scenario Outline: User should be able to set expiration while resharing a file with group
    Given using OCS API version "<ocs_api_version>"
    And user "user2" has been created with default attributes and without skeleton files
    And group "grp1" has been created
    And user "user2" has been added to group "grp1"
    And user "user0" has shared file "/textfile0.txt" with user "user1" with permissions "read,update,share"
    When user "user1" creates a share using the sharing API with settings
      | path        | textfile0.txt |
      | shareType   | group         |
      | permissions | change        |
      | shareWith   | grp1          |
      | expireDate  | +3 days       |
    Then the HTTP status code should be "200"
    And the OCS status code should be "<ocs_status_code>"
    And the information of the last share of user "user1" should include
      | expiration | +3 days |
    And the response when user "user2" gets the info of the last share should include
      | expiration | +3 days |
    Examples:
      | ocs_api_version | ocs_status_code |
      | 1               | 100             |
      | 2               | 200             |

  @skipOnOcV10.3
  Scenario Outline: resharing with user using the sharing API with expire days set and combinations of default/enforce expire date enabled
    Given using OCS API version "<ocs_api_version>"
    And parameter "shareapi_default_expire_date_user_share" of app "core" has been set to "<default-expire-date>"
    And parameter "shareapi_enforce_expire_date_user_share" of app "core" has been set to "<enforce-expire-date>"
    And parameter "shareapi_expire_after_n_days_user_share" of app "core" has been set to "30"
    And user "user2" has been created with default attributes and without skeleton files
    And user "user0" has shared file "/textfile0.txt" with user "user1" with permissions "read,update,share"
    When user "user1" creates a share using the sharing API with settings
      | path        | textfile0.txt |
      | shareType   | user          |
      | permissions | change        |
      | shareWith   | user2         |
    Then the HTTP status code should be "200"
    And the OCS status code should be "<ocs_status_code>"
    And the information of the last share of user "user1" should include
      | expiration | <expected-expire-date> |
    And the response when user "user2" gets the info of the last share should include
      | expiration | <expected-expire-date> |
    Examples:
      | ocs_api_version | default-expire-date | enforce-expire-date | expected-expire-date | ocs_status_code |
      | 1               | yes                 | yes                 | +30 days             | 100             |
      | 2               | yes                 | yes                 | +30 days             | 200             |
      | 1               | no                  | yes                 |                      | 100             |
      | 2               | no                  | yes                 |                      | 200             |

  @skipOnOcV10.3
  Scenario Outline: resharing with group using the sharing API with expire days set and combinations of default/enforce expire date enabled
    Given using OCS API version "<ocs_api_version>"
    And parameter "shareapi_default_expire_date_group_share" of app "core" has been set to "<default-expire-date>"
    And parameter "shareapi_enforce_expire_date_group_share" of app "core" has been set to "<enforce-expire-date>"
    And parameter "shareapi_expire_after_n_days_group_share" of app "core" has been set to "30"
    And user "user2" has been created with default attributes and without skeleton files
    And group "grp1" has been created
    And user "user2" has been added to group "grp1"
    And user "user0" has shared file "/textfile0.txt" with user "user1" with permissions "read,update,share"
    When user "user1" creates a share using the sharing API with settings
      | path        | textfile0.txt |
      | shareType   | group         |
      | permissions | change        |
      | shareWith   | grp1          |
    Then the HTTP status code should be "200"
    And the OCS status code should be "<ocs_status_code>"
    And the information of the last share of user "user1" should include
      | expiration | <expected-expire-date> |
    And the response when user "user2" gets the info of the last share should include
      | expiration | <expected-expire-date> |
    Examples:
      | ocs_api_version | default-expire-date | enforce-expire-date | expected-expire-date | ocs_status_code |
      | 1               | yes                 | yes                 | +30 days             | 100             |
      | 2               | yes                 | yes                 | +30 days             | 200             |
      | 1               | no                  | yes                 |                      | 100             |
      | 2               | no                  | yes                 |                      | 200             |

  @skipOnOcV10.3
  Scenario Outline: resharing with user using the sharing API without expire days set and with combinations of default/enforce expire date enabled
    Given using OCS API version "<ocs_api_version>"
    And parameter "shareapi_default_expire_date_user_share" of app "core" has been set to "<default-expire-date>"
    And parameter "shareapi_enforce_expire_date_user_share" of app "core" has been set to "<enforce-expire-date>"
    And user "user2" has been created with default attributes and without skeleton files
    And user "user0" has shared file "/textfile0.txt" with user "user1" with permissions "read,update,share"
    When user "user1" creates a share using the sharing API with settings
      | path        | textfile0.txt |
      | shareType   | user          |
      | permissions | change        |
      | shareWith   | user2         |
    Then the HTTP status code should be "200"
    And the OCS status code should be "<ocs_status_code>"
    And the information of the last share of user "user1" should include
      | expiration | <expected-expire-date> |
    And the response when user "user2" gets the info of the last share should include
      | expiration | <expected-expire-date> |
    Examples:
      | ocs_api_version | default-expire-date | enforce-expire-date | expected-expire-date | ocs_status_code |
      | 1               | yes                 | yes                 | +7 days              | 100             |
      | 2               | yes                 | yes                 | +7 days              | 200             |
      | 1               | no                  | yes                 |                      | 100             |
      | 2               | no                  | yes                 |                      | 200             |

  @skipOnOcV10.3
  Scenario Outline: resharing with group using the sharing API without expire days set and with combinations of default/enforce expire date enabled
    Given using OCS API version "<ocs_api_version>"
    And parameter "shareapi_default_expire_date_group_share" of app "core" has been set to "<default-expire-date>"
    And parameter "shareapi_enforce_expire_date_group_share" of app "core" has been set to "<enforce-expire-date>"
    And user "user3" has been created with default attributes and without skeleton files
    And group "grp2" has been created
    And user "user3" has been added to group "grp2"
    And user "user0" has shared file "/textfile0.txt" with user "user1" with permissions "read,update,share"
    When user "user1" creates a share using the sharing API with settings
      | path        | textfile0.txt |
      | shareType   | group         |
      | permissions | change        |
      | shareWith   | grp2          |
    Then the HTTP status code should be "200"
    And the OCS status code should be "<ocs_status_code>"
    And the information of the last share of user "user1" should include
      | expiration | <expected-expire-date> |
    And the response when user "user3" gets the info of the last share should include
      | expiration | <expected-expire-date> |
    Examples:
      | ocs_api_version | default-expire-date | enforce-expire-date | expected-expire-date | ocs_status_code |
      | 1               | yes                 | yes                 | +7 days              | 100             |
      | 2               | yes                 | yes                 | +7 days              | 200             |
      | 1               | no                  | yes                 |                      | 100             |
      | 2               | no                  | yes                 |                      | 200             |

  @skipOnOcV10.3
  Scenario Outline: resharing with user using the sharing API with expire days set and with combinations of default/enforce expire date enabled and specify expire date in share
    Given using OCS API version "<ocs_api_version>"
    And parameter "shareapi_default_expire_date_user_share" of app "core" has been set to "<default-expire-date>"
    And parameter "shareapi_enforce_expire_date_user_share" of app "core" has been set to "<enforce-expire-date>"
    And parameter "shareapi_expire_after_n_days_user_share" of app "core" has been set to "30"
    And user "user2" has been created with default attributes and without skeleton files
    And user "user0" has shared file "/textfile0.txt" with user "user1" with permissions "read,update,share"
    When user "user1" creates a share using the sharing API with settings
      | path        | textfile0.txt |
      | shareType   | user          |
      | permissions | change        |
      | shareWith   | user2         |
      | expireDate  | +20 days      |
    Then the HTTP status code should be "200"
    And the OCS status code should be "<ocs_status_code>"
    And the information of the last share of user "user1" should include
      | expiration | +20 days |
    And the response when user "user2" gets the info of the last share should include
      | expiration | +20 days |
    Examples:
      | ocs_api_version | default-expire-date | enforce-expire-date | ocs_status_code |
      | 1               | yes                 | yes                 | 100             |
      | 2               | yes                 | yes                 | 200             |
      | 1               | no                  | yes                 | 100             |
      | 2               | no                  | yes                 | 200             |

  @skipOnOcV10.3
  Scenario Outline: resharing with group using the sharing API with expire days set and with combinations of default/enforce expire date enabled and specify expire date in share
    Given using OCS API version "<ocs_api_version>"
    And parameter "shareapi_default_expire_date_group_share" of app "core" has been set to "<default-expire-date>"
    And parameter "shareapi_enforce_expire_date_group_share" of app "core" has been set to "<enforce-expire-date>"
    And parameter "shareapi_expire_after_n_days_group_share" of app "core" has been set to "30"
    And user "user3" has been created with default attributes and without skeleton files
    And group "grp2" has been created
    And user "user3" has been added to group "grp2"
    And user "user0" has shared file "/textfile0.txt" with user "user1" with permissions "read,update,share"
    When user "user1" creates a share using the sharing API with settings
      | path        | textfile0.txt |
      | shareType   | group         |
      | permissions | change        |
      | shareWith   | grp2          |
      | expireDate  | +20 days      |
    Then the HTTP status code should be "200"
    And the OCS status code should be "<ocs_status_code>"
    And the information of the last share of user "user1" should include
      | expiration | +20 days |
    And the response when user "user3" gets the info of the last share should include
      | expiration | +20 days |
    Examples:
      | ocs_api_version | default-expire-date | enforce-expire-date | ocs_status_code |
      | 1               | yes                 | yes                 | 100             |
      | 2               | yes                 | yes                 | 200             |
      | 1               | no                  | yes                 | 100             |
      | 2               | no                  | yes                 | 200             |

  @skipOnOcV10.3
  Scenario Outline: Setting default expiry date and enforcement after the share is created
    Given using OCS API version "<ocs_api_version>"
    And user "user2" has been created with default attributes and without skeleton files
    And user "user0" has shared file "/textfile0.txt" with user "user1" with permissions "read,update,share"
    And user "user1" has shared file "/textfile0.txt" with user "user2"
    And parameter "shareapi_default_expire_date_user_share" of app "core" has been set to "<default-expire-date>"
    And parameter "shareapi_enforce_expire_date_user_share" of app "core" has been set to "<enforce-expire-date>"
    And parameter "shareapi_expire_after_n_days_user_share" of app "core" has been set to "4"
    When user "user1" gets the info of the last share using the sharing API
    Then the HTTP status code should be "200"
    And the OCS status code should be "<ocs_status_code>"
    And the information of the last share of user "user1" should include
      | expiration |  |
    And the response when user "user2" gets the info of the last share should include
      | expiration |  |
    Examples:
      | ocs_api_version | default-expire-date | enforce-expire-date | ocs_status_code |
      | 1               | yes                 | yes                 | 100             |
      | 2               | yes                 | yes                 | 200             |
      | 1               | no                  | yes                 | 100             |
      | 2               | no                  | yes                 | 200             |

  @skipOnOcV10.3
  Scenario Outline: resharing group share with user using the sharing API with default expire date set and with combinations of default/enforce expire date enabled
    Given using OCS API version "<ocs_api_version>"
    And parameter "shareapi_default_expire_date_user_share" of app "core" has been set to "<default-expire-date>"
    And parameter "shareapi_enforce_expire_date_user_share" of app "core" has been set to "<enforce-expire-date>"
    And parameter "shareapi_expire_after_n_days_user_share" of app "core" has been set to "30"
    And group "grp1" has been created
    And user "user2" has been created with default attributes and without skeleton files
    And user "user1" has been added to group "grp1"
    And user "user0" has shared file "/textfile0.txt" with group "grp1" with permissions "read,update,share"
    When user "user1" creates a share using the sharing API with settings
      | path        | textfile0.txt |
      | shareType   | user          |
      | permissions | change        |
      | shareWith   | user2         |
    Then the HTTP status code should be "200"
    And the OCS status code should be "<ocs_status_code>"
    And the information of the last share of user "user1" should include
      | expiration | <expected-expire-date> |
    And the response when user "user2" gets the info of the last share should include
      | expiration | <expected-expire-date> |
    Examples:
      | ocs_api_version | default-expire-date | enforce-expire-date | expected-expire-date | ocs_status_code |
      | 1               | yes                 | yes                 | +30 days             | 100             |
      | 2               | yes                 | yes                 | +30 days             | 200             |
      | 1               | no                  | yes                 |                      | 100             |
      | 2               | no                  | yes                 |                      | 200             |

  @skipOnOcV10.3
  Scenario Outline: resharing group share with user using the sharing API with default expire date set and specifying expiration on share and with combinations of default/enforce expire date enabled
    Given using OCS API version "<ocs_api_version>"
    And parameter "shareapi_default_expire_date_user_share" of app "core" has been set to "<default-expire-date>"
    And parameter "shareapi_enforce_expire_date_user_share" of app "core" has been set to "<enforce-expire-date>"
    And parameter "shareapi_expire_after_n_days_user_share" of app "core" has been set to "30"
    And group "grp1" has been created
    And user "user2" has been created with default attributes and without skeleton files
    And user "user1" has been added to group "grp1"
    And user "user0" has shared file "/textfile0.txt" with group "grp1" with permissions "read,update,share"
    When user "user1" creates a share using the sharing API with settings
      | path        | textfile0.txt |
      | shareType   | user          |
      | permissions | change        |
      | shareWith   | user2         |
      | expireDate  | +20 days      |
    Then the HTTP status code should be "200"
    And the OCS status code should be "<ocs_status_code>"
    And the information of the last share of user "user1" should include
      | expiration | <expected-expire-date> |
    And the response when user "user2" gets the info of the last share should include
      | expiration | <expected-expire-date> |
    Examples:
      | ocs_api_version | default-expire-date | enforce-expire-date | expected-expire-date | ocs_status_code |
      | 1               | yes                 | yes                 | +20 days             | 100             |
      | 2               | yes                 | yes                 | +20 days             | 200             |
      | 1               | no                  | yes                 | +20 days             | 100             |
      | 2               | no                  | yes                 | +20 days             | 200             |

  @skipOnOcV10.3
  Scenario Outline: resharing using the sharing API with default expire date set but not enforced
    Given using OCS API version "<ocs_api_version>"
    And parameter "shareapi_default_expire_date_user_share" of app "core" has been set to "<default-expire-date>"
    And parameter "shareapi_enforce_expire_date_user_share" of app "core" has been set to "<enforce-expire-date>"
    And parameter "shareapi_expire_after_n_days_user_share" of app "core" has been set to "30"
    And user "user2" has been created with default attributes and without skeleton files
    And user "user0" has shared file "/textfile0.txt" with user "user1" with permissions "read,update,share"
    When user "user1" creates a share using the sharing API with settings
      | path        | textfile0.txt |
      | shareType   | user          |
      | permissions | change        |
      | shareWith   | user2         |
    Then the HTTP status code should be "200"
    And the OCS status code should be "<ocs_status_code>"
    And the information of the last share of user "user1" should include
      | expiration |  |
    And the response when user "user2" gets the info of the last share should include
      | expiration |  |
    Examples:
      | ocs_api_version | default-expire-date | enforce-expire-date | ocs_status_code |
      | 1               | yes                 | no                  | 100             |
      | 2               | yes                 | no                  | 200             |
      | 1               | no                  | no                  | 100             |
      | 2               | no                  | no                  | 200             |
