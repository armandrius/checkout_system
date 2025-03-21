# Checkout System

This repository contains a Ruby implementation of a checkout system designed for a small supermarket chain. It has been implemented purely in Ruby without relying on Ruby on Rails, following a test-driven development (TDD) approach.

## Project Setup

### Prerequisites

Ensure Docker and Docker Compose are installed:

- [Docker installation guide](https://docs.docker.com/get-docker/)
- [Docker Compose installation guide](https://docs.docker.com/compose/install/)

### Setup Instructions

Clone the repository and navigate to the project's directory:

```bash
git clone <your-repository-url>
cd checkout_system
```

Build and run the Docker environment:

```bash
docker compose build
docker compose run --rm ruby-app bash
```

## Running Tests

Inside the Docker container, run RSpec tests:

```bash
rspec
```

All tests should pass, verifying correctness and rule logic.

## Manual Testing via Console

To manually test via IRB:

```bash
bin/checkout_system
```

Example:

```ruby
green_tea = Product.new(code: 'GR1', name: 'Green Tea', price: 3.11.gbp)
strawberry = Product.new(code: 'SR1', name: 'Strawberry', price: 5.00.gbp)
coffee = Product.new(code: 'CF1', name: 'Coffee', price: 11.23.gbp)

pricing_rules = [
  PricingRules::BuyNGetM.new(code: 'BOGOF', product: green_tea, buy: 1, get: 1),
  PricingRules::BulkFixedDiscount.new(code: 'SR1_DISCOUNT', product: strawberry, min_quantity: 3, price: 4.50.gbp),
  PricingRules::BulkPercentDiscount.new(code: 'CF1_DISCOUNT', product: coffee, min_quantity: 3, discount_percentage: 33.33)
]

co = Checkout.new(pricing_rules)
co.scan(green_tea)
co.scan(strawberry)
co.scan(green_tea)
co.scan(green_tea)
co.scan(coffee)
puts co.total.format
```

## Interactive Console Application

An interactive console-based shopping application (`ShopApp`) is included to provide reviewers with an engaging way to explore the functionality of the checkout system.

### Disclaimer
This interactive app is solely for reviewers' convenience and exploration and is not intended for production use.

### Running the Console Application

Within your Docker container, execute:

```bash
bin/shop
```


### Using the Console Application

- Upon launching, you'll be greeted and presented with menu options.
- **Menu Options:**
  - `L`: Quickly add multiple products by listing their codes (comma-separated).
  - `B`: Select a product by its code and specify a quantity.
  - `D`: Add available discounts.
  - `E`: Empty the current basket.
  - `Q`: Quit the application and display your final total.

### Example Interaction

```
Hello! Welcome to our shop.

Your basket total is £0.00. What do you want to do?
L: Buy products through a list of codes, B: Buy separate products by quantity,
D: Add discounts, E: Empty your basket, Q: Quit
> B

Available Products:
Code | Name         | Price
CF1  | Coffee       | £11.23
GR1  | Green tea    | £3.11
SR1  | Strawberries | £5.00

Type a product code and press enter:
> GR1
How many?
> 2
2 Green tea(s) added to your basket.
```

## Project Structure

```
checkout_system/
├── lib/
│   └── checkout_system/
│       ├── config/
│       │   └── initializers/
│       │       ├── money.rb
│       │       └── numeric.rb
│       └── models/
│           ├── checkout_collections/
│           │   ├── line_items_collection.rb
│           │   └── pricing_rules_collection.rb
│           ├── concerns/
│           │   ├── validatable.rb
│           │   ├── bulk_discountable.rb
│           │   └── code_identifiable.rb
│           ├── pricing_rules/
│           │   ├── base.rb
│           │   ├── buy_n_get_m.rb
│           │   ├── bulk_fixed_discount.rb
│           │   └── bulk_percent_discount.rb
│           ├── checkout.rb
│           ├── line_item.rb
│           └── product.rb
├── spec/
│   ├── models/
│   │   └── pricing_rules/
│   │       ├── bulk_fixed_discount_spec.rb
│   │       ├── bulk_percent_discount_spec.rb
│   │       └── buy_n_get_m_spec.rb
│   ├── loader.rb
│   └── spec_helper.rb
│
├── Dockerfile
└── docker-compose.yml
```
### Components Explained

- **Checkout:** The main orchestrator that manages the scanned products and applies the pricing rules. It maintains the state of the current checkout session, including the products scanned and the total price calculation. The `Checkout` class initializes with a set of pricing rules and provides the `scan` method to add products and `total` to calculate the final price after applying all relevant pricing rules.

- **Product:** Represents items available in the supermarket. It includes attributes such as code, name, and price, with validations to ensure data integrity. The `Product` class ensures that each product has a unique code and a valid price, leveraging the `Validatable` concern for attribute validation.

- **LineItem:** Represents an individual product that has been scanned during the checkout process. It keeps track of the quantity and total price for that product. The `LineItem` class calculates the total price based on the quantity and applies any relevant pricing rules.

- **PricingRules:** A set of flexible rules that adjust the pricing dynamically based on specific conditions. The rules include:
  - **Base:** The base class for all pricing rules, providing common functionality such as initialization and validation of rule attributes.
  - **BuyNGetM:** Implements a "buy N get M free" rule, allowing for promotions like "buy one get one free". This class calculates the discount based on the number of eligible products scanned.
  - **BulkFixedDiscount:** Applies a fixed price discount when a minimum quantity of a product is purchased. This class checks the quantity of the product and adjusts the price if the threshold is met.
  - **BulkPercentDiscount:** Applies a percentage discount when a minimum quantity of a product is purchased. This class calculates the discount percentage and applies it to the total price of the product if the minimum quantity is reached.

- **CheckoutCollections:**
  - **LineItemsCollection:** Manages a collection of `LineItem` objects, providing methods to add, remove, and iterate over line items. This class ensures that line items are correctly aggregated and updated during the checkout process.
  - **PricingRulesCollection:** Manages a collection of `PricingRules` objects, ensuring that all applicable rules are applied during the checkout process. This class iterates over the pricing rules and applies them to the relevant line items.

- **Concerns:**
  - **Validatable:** A module that provides validation functionality to ensure that objects meet certain criteria before they are used. This module is included in classes like `Product` and `PricingRules` to enforce attribute validations.
  - **BulkDiscountable:** A module that provides methods to apply bulk discounts to products. This module is used by pricing rules such as `BulkFixedDiscount` and `BulkPercentDiscount` to handle bulk discount logic.
  - **CodeIdentifiable:** A module that ensures objects have a unique code attribute, which is used to identify products and rules. This module is included in classes like `Product` and `PricingRules` to enforce unique code constraints.

### Additional Components

- **Config/Initializers:**
  - **Money:** Initializes the Money gem, which is used for handling currency and price calculations accurately. This initializer sets up the default currency and configures the Money gem for use throughout the application.
  - **Numeric:** Extends the Numeric class to support currency conversions. This initializer adds methods to the Numeric class to facilitate easy conversion and manipulation of monetary values.

- **Loader:** Configures the Zeitwerk loader to autoload classes and modules, reducing the need for explicit `require` statements and improving maintainability. The loader is set up to automatically load all classes and modules in the `lib/checkout_system` directory, ensuring that the application components are available when needed.
