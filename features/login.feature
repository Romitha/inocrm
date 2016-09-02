@selenium
Feature: Login to InoCrm page
Unauthorized user is going to login to inocrm login page.

Scenario: Login to InoCrm page.

Given I am Unauthorized user
When I am entering my credential details:
	|email						  |password |
	|admin@inovacrm.com |123456789|
	|admin1@inovacrm.com|123456789|
# And press Log in button
# Then I able to login to InoCrm system.