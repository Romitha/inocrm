Feature: Adding and viewing brands
  Brand has two attributes called brand name and brand code.
  brand name and brand code must be unique.

  Background:
    Given I am authorized user with role of admin
    When Go to admin brand screen in inventories.

  Scenario Outline: Adding brand to system.
    When I enter brand name: <brandName>
    And I enter brand code: <brandCode>
    And I click Save
    Then I should see expected <message>

    Scenarios: Successfully adding:
      | brandName     | brandCode | message                         |
      |  brand1       |  5        | Successfully saved              |
      |  brand2       |  7        | Successfully saved              |

    Scenarios: Brand name is empty:
      |               |  6        | This field is required          |

    Scenarios: Brand code is empty:
      |  brand3       |           | This field is required          |

    Scenarios: Duplicate brand entry:
      |  brand2       |  7        | Brand is already available      |

  @javascript
  Scenario: Empty brand name:
    When brand name is empty
    And I click Save
    Then I should see error message like This field is required in brand name field

  Scenario: Empty brand code:
    When brand code is empty
    Then I should see error message like This field is required in brand code field

  Scenario: already available brand:
    When brandName or brandCode is already available
    Then I should see error message like brand name already exist