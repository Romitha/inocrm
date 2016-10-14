@selenium
Feature: Adding and viewing brands
  Brand has two attributes called brand name and brand code.
  brand name and brand code must be unique.

  Background:
    Given I am authorized user
    When Go to admin brand screen in inventories.


  Scenario Outline: Adding brand to system.
    And I enter inventory_category1 name like <brandName>
    And I enter inventory_category1 code like <brandCode>
    And I click Save
    Then I should see expected <message>

    Scenarios: Successfully adding:
      | brandName     | brandCode | message                         |
      |  brand1       |  5        | Successfully saved              |
      |  brand2       |  7        | Successfully saved              |

    Scenarios: Brand name is empty:
      | brandName     | brandCode | message                         |
      |               |  6        | This field is required          |

    Scenarios: Brand code is empty:
      | brandName     | brandCode | message                         |
      |  brand3       |           | This field is required          |

    Scenarios: Duplicate brand entry:
      | brandName     | brandCode | message                         |
      |  brand2       |  7        | has already been taken          |

  # @javascript
  # Scenario: Empty brand name:
  #   When brand name is empty
  #   And I click Save
  #   Then I should see error message like This field is required in brand name field

  # Scenario: Empty brand code:
  #   When brand code is empty
  #   Then I should see error message like This field is required in brand code field

  # Scenario: already available brand:
  #   When brandName or brandCode is already available
  #   Then I should see error message like brand name already exist

  Scenario Outline: Checking availability of data from database.
    Given within each id <wrapper>
    Given I able to see <code> in the hml dom class inline_edit
    And I able to see <name> in the hml dom class inline_edit

      Examples:    
        | wrapper  |code | name    |
        | brand1   | 5   | brand1  |