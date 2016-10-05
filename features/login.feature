@selenium
Feature: Login to InoCrm page
Unauthorized user is going to login to inocrm login page.
Authenticated admin is entitled to enter admin@inovacrm.com as email and 123456789 as password for successfull login credential.

Scenario Outline: Login to InoCrm page.
  Given I am Unauthorized user
  When I go to sign in page
  And I find login form
  And I enter user email like <email>
  And I enter user password like <password>
  And I click button Log in
  Then I should see expected <message>

  Scenarios: Successfull login:
    |email              |password | message                 |
    |admin@inovacrm.com |123456789| Signed in successfully  |

  Scenarios: Failure login:
    |email              |password | message                           |
    |admin1@inovacrm.com|123456789| Invalid email address or password |

# And press Log in button
# Then I able to login to InoCrm system.