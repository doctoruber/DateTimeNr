# DateTimeNr Library README

## Overview
DateTimeNr is a specialized library tailored for Noir, a language designed for zero-knowledge proofs (ZKPs). Essential in blockchain and cryptographic applications, it offers precise and efficient handling of date and time data.

## Features
- **Structures for Date and Time:** Well-defined structures for dates, times, and combined datetime.
- **Leap Year Detection:** Accurately identifies leap years, a key aspect for date computations.
- **Parsing Functions:** Converts raw year, month, day, hour, minute, and second data into structured formats.
- **Formatting Tools:** Transforms date and time objects into user-friendly formats.
- **Time Zone Adjustment:** Alters time data for different global time zones.
- **Arithmetic Operations:** Adds or subtracts years, months, days, hours, minutes, and seconds.

## ZKP Context
In ZKPs and blockchain:
- **Trustless Verification:** Generates proofs related to time without revealing specifics.
- **Smart Contract Logic:** Powers time-dependent contract functionalities.
- **Computational Efficiency:** Tailored for ZKP computational limits, suitable for on-chain use.

## Usage Examples

#### Date and Time Parsing
```rust
let date = parse_date(2024, 12, 31);
let time = parse_time(23, 59, 59, 0);
```

#### Formatting
```rust
let formatted_date = format_date(date);
let formatted_time = format_time(time);
```

#### Time Zone Conversion
```rust
let time_utc = parse_time(15, 0, 0, 0);
let time_est = convert_time_zone(time_utc, -5);
```

#### Arithmetic Operations
```rust
let date = parse_date(2021, 1, 1);
let new_date = add_to_date(date, 1, 0, 0);
let time = parse_time(11, 30, 0, 0);
let new_time = add_time(time, 1, 30, 0);
```

#### Leap Year
```rust
let leap_2020 = is_leap_year(2020);
let leap_2019 = is_leap_year(2019);
```

#### Month Handling
```rust
let feb_2020_days = days_in_month(2020, 2);
let feb_2019_days = days_in_month(2019, 2);
```

#### Date Components Adjustment
```rust
let date = parse_date(2021, 12, 15);
let new_date = adjust_month(date, 2);
let another_date = adjust_day(date, -10);
```

#### Subtracting Dates/Times
```rust
let new_date = subtract_from_date(date, 1, 0, 0);
let new_time = subtract_time(time, 2, 0, 0);
```

#### Date Difference
```rust
let start_date = parse_date(2021, 1, 1);
let end_date = parse_date(2021, 12, 31);
let difference = date_difference(start_date, end_date);
```

## Limitations
- **Date Range:** Limited to u32 range.
- **Time Zone Simplification:** Excludes daylight saving adjustments.
- **Leap Second Exclusion:** Does not account for leap seconds.

## Testing
Features robust tests for accuracy and reliability.

## Contributing
Contributions are welcome! Feel free to submit pull requests or issues.

## License
Distributed under Apache License 2.0. See LICENSE for details.
