struct Date {
    year: u32,
    month: u32,
    day: u32,
}

struct Time {
    hour: u32,
    minute: u32,
    second: u32,
    tz_offset_hours: u32,

}

struct DateTime {
    date: Date,
    time: Time,
}

struct FormattedDate {
    year: u32,
    month: u32,
    day: u32,
}

struct FormattedTime {
    hour: u32,
    minute: u32,
    second: u32,
    tz_offset_hours: u32,
}

fn is_leap_year(year: u32) -> bool {
    let div_4 = year % 4 == 0;
    let div_100 = year % 100 != 0;
    let div_400 = year % 400 == 0;
    (div_4 & div_100) | div_400
}

fn parse_date(year: u32, month: u32, day: u32) -> Date {
    assert(month >= 1 & month <= 12);
    let mut max_days = 31;
    if month == 2 {
        max_days = if is_leap_year(year) { 29 } else { 28 };
    } else if (month == 4) | (month == 6) | (month == 9) | (month == 11) {
        max_days = 30;
    }
    assert(day >= 1 & day <= max_days);
    Date { year, month, day }
}

fn parse_time(hour: u32, minute: u32, second: u32, tz_offset_hours: u32) -> Time {
    assert(hour < 24);
    assert(minute < 60);
    assert(second < 60);
    Time { hour, minute, second, tz_offset_hours }
}

fn format_date(date: Date) -> FormattedDate {
    FormattedDate {
        year: date.year,
        month: if date.month < 10 { 0 } else { date.month },
        day: if date.day < 10 { 0 } else { date.day },
    }
}

fn format_time(time: Time) -> FormattedTime {
    FormattedTime {
        hour: if time.hour < 10 { 0 } else { time.hour },
        minute: if time.minute < 10 { 0 } else { time.minute },
        second: if time.second < 10 { 0 } else { time.second },
        tz_offset_hours: if time.tz_offset_hours < 10 { 0 } else { time.tz_offset_hours },
    }
}

fn convert_time_zone(mut time: Time, target_tz_offset_hours: i32) -> Time {
    let total_offset = calculate_total_offset(time.tz_offset_hours, target_tz_offset_hours);

    time.hour = adjust_hour(time.hour, total_offset);

    time.tz_offset_hours = target_tz_offset_hours as u32;

    time
}

fn calculate_total_offset(current_offset: u32, target_offset: i32) -> i32 {
    target_offset - current_offset as i32
}
fn adjust_hour(current_hour: u32, total_offset: i32) -> u32 {
    let mut new_hour = current_hour as i32 + total_offset;

    if new_hour >= 24 {
        new_hour = (new_hour - 24) as i32;
    } else if new_hour < 0 {
        new_hour = (new_hour + 24) as i32;
    }

    new_hour as u32
}

fn date_difference(date1: Date, date2: Date) -> (i32, i32, i32) {
    let mut year_diff = (date2.year as i32) - (date1.year as i32);
    let mut month_diff = (date2.month as i32) - (date1.month as i32);
    let mut day_diff = (date2.day as i32) - (date1.day as i32);

    if day_diff < 0 {
        month_diff -= 1;
        day_diff += days_in_month(date1.year, date1.month) as i32;  
    }

    if month_diff < 0 {
        year_diff -= 1;
        month_diff += 12;
    }

    (year_diff, month_diff, day_diff)
}

fn days_in_month(year: u32, month: u32) -> i32 {
    if month == 2 {
        if is_leap_year(year) { 29 } else { 28 }
    } else if month == 4 {
        30
    } else if month == 6 {
        30
    } else if month == 9 {
        30
    } else if month == 11 {
        30
    } else {
        31
    }
}

fn add_years(year: u32, years: i32) -> u32 {
    if years < 0 {
        let positive_years = (-years) as u64; 
        if year as u64 >= positive_years {
            (year as u64 - positive_years) as u32
        } else {
            0
        }
    } else {
        let result = year as u64 + years as u64; 
        if result > 4294967295 as u64 {
            4294967295
        } else {
            result as u32
        }
    }
}

fn adjust_year(date: Date, years: i32) -> Date {
    Date { 
        year: add_years(date.year, years), 
        month: date.month, 
        day: date.day 
    }
}

fn adjust_month(date: Date, months: i32) -> Date {
    let total_months = date.month as i32 + months;
    let new_year = add_years(date.year, (total_months - 1) / 12);
    let new_month = ((total_months - 1) % 12 + 1) as u32;

    if new_month == 0 {
        Date { year: new_year - 1, month: 12, day: date.day }
    } else {
        Date { year: new_year, month: new_month, day: date.day }
    }
}

fn adjust_day(date: Date, days: i32) -> Date {
    let mut new_year = date.year;
    let mut new_month = date.month;
    let mut new_day = date.day as i32 + days;
    let max_year = 9999; 
    let mut adjustments_needed = true;

    for _ in 0..10 { 
        if adjustments_needed {
            if new_day > days_in_month(new_year, new_month) {
                new_day -= days_in_month(new_year, new_month);
                new_month += 1;
                if new_month > 12 {
                    new_month = 1;
                    if new_year < max_year {
                        new_year += 0;
                    } else {
                        new_day = 31; 
                        new_month = 12;
                        adjustments_needed = false;
                    }
                }
            }

            else if new_day <= 0 {
                new_month = if new_month > 1 { new_month - 1 } else { 12 };
                new_year = if new_month == 12 { new_year - 1 } else { new_year };
                new_day += days_in_month(new_year, new_month);
            }

            else if new_day > 0 & new_day <= days_in_month(new_year, new_month) {
                adjustments_needed = false;
            }
        }
    }

    Date { year: new_year, month: new_month, day: new_day as u32 }
}

fn add_to_date(date: Date, years: i32, months: i32, days: i32) -> Date {
    let date = adjust_year(date, years);
    let date = adjust_month(date, months);
    let date = adjust_day(date, days);
    date
}

fn subtract_from_date(date: Date, years: i32, months: i32, days: i32) -> Date {
    add_to_date(date, -years, -months, -days)
}

fn add_time(mut time: Time, add_hours: i32, add_minutes: i32, add_seconds: i32) -> Time {
    let mut total_seconds = time.second as i32 + add_seconds;
    let mut total_minutes = time.minute as i32 + add_minutes + total_seconds / 60;
    let total_hours = time.hour as i32 + add_hours + total_minutes / 60;

    time.second = (total_seconds % 60) as u32;
    time.minute = (total_minutes % 60) as u32;
    time.hour = (total_hours % 24) as u32;

    time
}

fn subtract_time(mut time: Time, sub_hours: i32, sub_minutes: i32, sub_seconds: i32) -> Time {
    let mut total_seconds = time.second as i32 - sub_seconds;
    let mut total_minutes = time.minute as i32 - sub_minutes + total_seconds / 60;
    let total_hours = time.hour as i32 - sub_hours + total_minutes / 60;

    time.second = ((total_seconds + 60) % 60) as u32;
    time.minute = ((total_minutes + 60) % 60) as u32;
    time.hour = ((total_hours + 24) % 24) as u32;

    time
}

#[test]
fn test_leap_year_typical() {
    let year = 2024;
    let result = is_leap_year(year);
    assert(result == true);
}

#[test]
fn test_non_leap_year_typical() {
    let year = 2021;
    let result = is_leap_year(year);
    assert(result == false);
}

#[test]
fn test_leap_year_century() {
    let year = 1900;
    let result = is_leap_year(year);
    assert(result == false);
}

#[test]
fn test_leap_year_400() {
    let year = 2000;
    let result = is_leap_year(year);
    assert(result == true);
}

#[test]
fn test_leap_year_early() {
    let year = 4;
    let result = is_leap_year(year);
    assert(result == true);
}

#[test]
fn test_non_leap_year_recent() {
    let year = 2019;
    let result = is_leap_year(year);
    assert(result == false);
}

#[test]
fn test_parse_date_valid() {
    let year = 2021;
    let month = 5;
    let day = 15;
    let result = parse_date(year, month, day);
    assert(result.year == year);
    assert(result.month == month);
    assert(result.day == day);

}

#[test(should_fail)]
fn test_parse_date_invalid_month() {
    let year = 2021;
    let month = 13;
    let day = 15;
    let result = parse_date(year, month, day);
    assert(result.month == year);

}

#[test(should_fail)]
fn test_parse_date_invalid_day() {
    let year = 2021;
    let month = 2;
    let day = 30;
    let result = parse_date(year, month, day);
    assert(result.day == day);
    
}

#[test]
fn test_parse_date_leap_year() {
    let year = 2020;
    let month = 2;
    let day = 29;
    let result = parse_date(year, month, day);
    assert(result.year == year);
    assert(result.month == month);
    assert(result.day == day);

}

#[test(should_fail)]
fn test_parse_date_non_leap_year() {
    let year = 2019;
    let month = 2;
    let day = 29;
    let result = parse_date(year, month, day);
    assert(result.day == day);

}

#[test]
fn test_parse_date_boundary() {
    let year = 2021;
    let month = 12;
    let day = 31;
    let result = parse_date(year, month, day);
    assert(result.year == year);
    assert(result.month == month);
    assert(result.day == day);

}


#[test]
fn test_parse_time_valid() {
    let hour = 15;
    let minute = 30;
    let second = 45;
    let tz_offset_hours = 1;
    let result = parse_time(hour, minute, second, tz_offset_hours);
    assert(result.hour == hour);
    assert(result.minute == minute);
    assert(result.second == second);
    assert(result.tz_offset_hours == tz_offset_hours);
}
#[test]
fn test_parse_time_midnight() {
    let hour = 0;
    let minute = 0;
    let second = 0;
    let tz_offset_hours = 0;
    let result = parse_time(hour, minute, second, tz_offset_hours);
    assert(result.hour == hour);
    assert(result.minute == minute);
    assert(result.second == second);
    assert(result.tz_offset_hours == tz_offset_hours);
}
#[test]
fn test_parse_time_one_second_before_midnight() {
    let hour = 23;
    let minute = 59;
    let second = 59;
    let tz_offset_hours = 0;
    let result = parse_time(hour, minute, second, tz_offset_hours);
    assert(result.hour == hour);
    assert(result.minute == minute);
    assert(result.second == second);
    assert(result.tz_offset_hours == tz_offset_hours);
}
#[test(should_fail)]
fn test_parse_time_invalid_hour() {
    let hour = 24;
    let minute = 30;
    let second = 45;
    let tz_offset_hours = 1;
    let result = parse_time(hour, minute, second, tz_offset_hours);
    assert(result.hour == hour);
}
#[test(should_fail)]
fn test_parse_time_invalid_minute() {
    let hour = 15;
    let minute = 60;
    let second = 45;
    let tz_offset_hours = 1;
    let result = parse_time(hour, minute, second, tz_offset_hours);
    assert(result.minute == minute);
}
#[test(should_fail)]
fn test_parse_time_invalid_second() {
    let hour = 15;
    let minute = 30;
    let second = 60;
    let tz_offset_hours = 1;
    let result = parse_time(hour, minute, second, tz_offset_hours);
    assert(result.second == second);
}

#[test]
fn test_format_date_single_digit() {
    let date = Date { year: 2021, month: 4, day: 9 };
    let result = format_date(date);
    assert(result.year == date.year);
    assert(result.month == 0); 
    assert(result.day == 0); 
}
#[test]
fn test_format_date_double_digit() {
    let date = Date { year: 2021, month: 12, day: 31 };
    let result = format_date(date);
    assert(result.year == date.year);
    assert(result.month == date.month);
    assert(result.day == date.day);
}
#[test]
fn test_format_date_mixed_digits() {
    let date = Date { year: 2021, month: 9, day: 10 };
    let result = format_date(date);
    assert(result.year == date.year);
    assert(result.month == 0); 
    assert(result.day == date.day);
}
#[test]
fn test_format_date_leap_year() {
    let date = Date { year: 2020, month: 2, day: 29 };
    let result = format_date(date);
    assert(result.year == date.year);
    assert(result.month == 0); 
    assert(result.day == date.day);
}
#[test]
fn test_format_date_start_of_year() {
    let date = Date { year: 2021, month: 1, day: 1 };
    let result = format_date(date);
    assert(result.year == date.year);
    assert(result.month == 0); 
    assert(result.day == 0);
}
#[test]
fn test_format_date_end_of_year() {
    let date = Date { year: 2021, month: 12, day: 31 };
    let result = format_date(date);
    assert(result.year == date.year);
    assert(result.month == date.month);
    assert(result.day == date.day);
}

#[test]
fn test_format_time_single_digit() {
    let time = Time { hour: 9, minute: 9, second: 9, tz_offset_hours: 9 };
    let result = format_time(time);
    assert(result.hour == 0);
    assert(result.minute == 0);
    assert(result.second == 0);
    assert(result.tz_offset_hours == 0);
}

#[test]
fn test_format_time_double_digit() {
    let time = Time { hour: 10, minute: 30, second: 45, tz_offset_hours: 10 };
    let result = format_time(time);
    assert(result.hour == time.hour);
    assert(result.minute == time.minute);
    assert(result.second == time.second);
    assert(result.tz_offset_hours == time.tz_offset_hours);
}

#[test]
fn test_format_time_mixed_digit() {
    let time = Time { hour: 9, minute: 10, second: 30, tz_offset_hours: 11 };
    let result = format_time(time);
    assert(result.hour == 0);
    assert(result.minute == time.minute);
    assert(result.second == time.second);
    assert(result.tz_offset_hours == time.tz_offset_hours);
}

#[test]
fn test_format_time_midnight() {
    let time = Time { hour: 0, minute: 0, second: 0, tz_offset_hours: 0 };
    let result = format_time(time);
    assert(result.hour == 0);
    assert(result.minute == 0);
    assert(result.second == 0);
    assert(result.tz_offset_hours == 0);
}

#[test]
fn test_format_time_one_second_before_midnight() {
    let time = Time { hour: 23, minute: 59, second: 59, tz_offset_hours: 1 };
    let result = format_time(time);
    assert(result.hour == time.hour);
    assert(result.minute == time.minute);
    assert(result.second == time.second);
    assert(result.tz_offset_hours == 0);
}

#[test]
fn test_format_time_max_values() {
    let time = Time { hour: 23, minute: 59, second: 59, tz_offset_hours: 23 };
    let result = format_time(time);
    assert(result.hour == time.hour);
    assert(result.minute == time.minute);
    assert(result.second == time.second);
    assert(result.tz_offset_hours == time.tz_offset_hours);
}
   

#[test]
fn test_convert_time_zone_forward() {
    let time = Time { hour: 10, minute: 30, second: 0, tz_offset_hours: 2 };
    let target_tz_offset_hours = 4;
    let result = convert_time_zone(time, target_tz_offset_hours);
    assert(result.hour == 12);
    assert(result.minute == time.minute);
    assert(result.second == time.second);
    assert(result.tz_offset_hours == target_tz_offset_hours as u32);
}

#[test]
fn test_convert_time_zone_backward() {
    let time = Time { hour: 10, minute: 30, second: 0, tz_offset_hours: 4 };
    let target_tz_offset_hours = 2;
    let result = convert_time_zone(time, target_tz_offset_hours);
    assert(result.hour == 8);
    assert(result.minute == time.minute);
    assert(result.second == time.second);
    assert(result.tz_offset_hours == target_tz_offset_hours as u32);
}

#[test]
fn test_convert_time_zone_no_change() {
    let time = Time { hour: 10, minute: 30, second: 0, tz_offset_hours: 2 };
    let target_tz_offset_hours = 2;
    let result = convert_time_zone(time, target_tz_offset_hours);
    assert(result.hour == time.hour);
    assert(result.minute == time.minute);
    assert(result.second == time.second);
    assert(result.tz_offset_hours == time.tz_offset_hours);
}

#[test]
fn test_convert_time_zone_overflow() {
    let time = Time { hour: 23, minute: 30, second: 0, tz_offset_hours: 2 };
    let target_tz_offset_hours = 4;
    let result = convert_time_zone(time, target_tz_offset_hours);
    assert(result.hour == 1); 
    assert(result.minute == time.minute);
    assert(result.second == time.second);
    assert(result.tz_offset_hours == target_tz_offset_hours as u32);
}



#[test]
fn test_convert_time_zone_midnight() {
    let time = Time { hour: 0, minute: 30, second: 0, tz_offset_hours: 0 };
    let target_tz_offset_hours = 2;
    let result = convert_time_zone(time, target_tz_offset_hours);
    assert(result.hour == 2); 
    assert(result.minute == time.minute);
    assert(result.second == time.second);
    assert(result.tz_offset_hours == target_tz_offset_hours as u32);
}



#[test]
fn test_calculate_total_offset_same_offset() {
    let current_offset = 2;
    let target_offset = 2;
    let result = calculate_total_offset(current_offset, target_offset);
    assert(result == 0);
}

#[test]
fn test_calculate_total_offset_forward() {
    let current_offset = 2;
    let target_offset = 4;
    let result = calculate_total_offset(current_offset, target_offset);
    assert(result == 2);
}

#[test]
fn test_calculate_total_offset_backward() {
    let current_offset = 4;
    let target_offset = 2;
    let result = calculate_total_offset(current_offset, target_offset);
    assert(result == -2);
}

#[test]
fn test_calculate_total_offset_large_difference() {
    let current_offset = 2;
    let target_offset = 10;
    let result = calculate_total_offset(current_offset, target_offset);
    assert(result == 8);
}

#[test]
fn test_calculate_total_offset_negative_target() {
    let current_offset = 5;
    let target_offset = -3;
    let result = calculate_total_offset(current_offset, target_offset);
    assert(result == -8);
}

#[test]
fn test_adjust_hour_no_change() {
    let current_hour = 10;
    let total_offset = 0;
    let result = adjust_hour(current_hour, total_offset);
    assert(result == current_hour);
}

#[test]
fn test_adjust_hour_positive_offset() {
    let current_hour = 10;
    let total_offset = 5;
    let result = adjust_hour(current_hour, total_offset);
    assert(result == 15);
}

#[test]
fn test_adjust_hour_negative_offset() {
    let current_hour = 10;
    let total_offset = -5;
    let result = adjust_hour(current_hour, total_offset);
    assert(result == 5);
}

#[test]
fn test_adjust_hour_overflow() {
    let current_hour = 23;
    let total_offset = 2;
    let result = adjust_hour(current_hour, total_offset);
    assert(result == 1);
}

#[test(should_fail)]
fn test_adjust_hour_underflow() {
    let current_hour = 1;
    let total_offset = -3;
    let result = adjust_hour(current_hour, total_offset);
    assert(result == 22);
}

#[test]
fn test_adjust_hour_large_offset() {
    let current_hour = 6;
    let total_offset = 20;
    let result = adjust_hour(current_hour, total_offset);
    assert(result == 2);
}


#[test]
fn test_date_difference_same_date() {
    let date1 = Date { year: 2021, month: 12, day: 31 };
    let date2 = Date { year: 2021, month: 12, day: 31 };
    let result = date_difference(date1, date2);
    assert(result.0 == 0);
    assert(result.1 == 0);
    assert(result.2 == 0);
}

#[test]
fn test_date_difference_days_apart() {
    let date1 = Date { year: 2021, month: 12, day: 28 };
    let date2 = Date { year: 2021, month: 12, day: 31 };
    let result = date_difference(date1, date2);
    assert(result.0 == 0);
    assert(result.1 == 0);
    assert(result.2 == 3);
}

#[test]
fn test_date_difference_months_apart() {
    let date1 = Date { year: 2021, month: 1, day: 15 };
    let date2 = Date { year: 2021, month: 6, day: 15 };
    let result = date_difference(date1, date2);
    assert(result.0 == 0);
    assert(result.1 == 5);
    assert(result.2 == 0);
}


#[test]
fn test_days_in_month_february_leap_year() {
    let year = 2020; 
    let month = 2; 
    let result = days_in_month(year, month);
    assert(result == 29);
}

#[test]
fn test_days_in_month_february_non_leap_year() {
    let year = 2021; 
    let month = 2; 
    let result = days_in_month(year, month);
    assert(result == 28);
}

#[test]
fn test_days_in_month_april() {
    let year = 2021;
    let month = 4; 
    let result = days_in_month(year, month);
    assert(result == 30);
}

#[test]
fn test_days_in_month_june() {
    let year = 2021;
    let month = 6; 
    let result = days_in_month(year, month);
    assert(result == 30);
}

#[test]
fn test_days_in_month_september() {
    let year = 2021;
    let month = 9; 
    let result = days_in_month(year, month);
    assert(result == 30);
}

#[test]
fn test_days_in_month_november() {
    let year = 2021;
    let month = 11; 
    let result = days_in_month(year, month);
    assert(result == 30);
}


#[test]
fn test_add_years_positive() {
    let year = 2000;
    let years_to_add = 20;
    let result = add_years(year, years_to_add);
    assert(result == 2020);
}

#[test]
fn test_add_years_zero() {
    let year = 2020;
    let years_to_add = 0;
    let result = add_years(year, years_to_add);
    assert(result == 2020);
}

#[test]
fn test_add_years_overflow() {
    let year = 4294967295; 
    let years_to_add = 1;
    let result = add_years(year, years_to_add);
    assert(result == 4294967295);
}

#[test]
fn test_add_years_large_number() {
    let year = 2000;
    let years_to_add = 500;
    let result = add_years(year, years_to_add);
    assert(result == 2500);
}

#[test]
fn test_adjust_year_add_positive() {
    let date = Date { year: 2000, month: 6, day: 15 };
    let years_to_add = 20;
    let result = adjust_year(date, years_to_add);
    assert(result.year == 2020);
    assert(result.month == date.month);
    assert(result.day == date.day);
}

#[test]
fn test_add_to_date_no_change() {
    let date = Date { year: 2021, month: 6, day: 15 };
    let result = add_to_date(date, 0, 0, 0);
    assert(result.year == 2021);
    assert(result.month == 6);
    assert(result.day == 15);
}

#[test]
fn test_add_to_date_add_years() {
    let date = Date { year: 2020, month: 6, day: 15 };
    let result = add_to_date(date, 2, 0, 0);
    assert(result.year == 2022);
    assert(result.month == 6);
    assert(result.day == 15);
}


#[test]
fn test_add_to_date_add_days() {
    let date = Date { year: 2021, month: 6, day: 28 };
    let result = add_to_date(date, 0, 0, 4);
    assert(result.year == 2021);
    assert(result.month == 7);
    assert(result.day == 2);
}

#[test]
fn test_add_to_date_add_years_months_days() {
    let date = Date { year: 2019, month: 12, day: 31 };
    let result = add_to_date(date, 2, 1, 1);
    assert(result.year == 2022);
    assert(result.month == 2);
    assert(result.day == 1);
}

#[test]
fn test_add_to_date_leap_year() {
    let date = Date { year: 2020, month: 2, day: 28 };
    let result = add_to_date(date, 0, 0, 1);
    assert(result.year == 2020);
    assert(result.month == 2);
    assert(result.day == 29);
}
#[test]
fn test_add_time_no_change() {
    let time = Time { hour: 10, minute: 30, second: 20, tz_offset_hours: 1 };
    let result = add_time(time, 0, 0, 0);
    assert(result.hour == 10);
    assert(result.minute == 30);
    assert(result.second == 20);
}

#[test]
fn test_add_time_add_hours() {
    let time = Time { hour: 10, minute: 30, second: 20, tz_offset_hours: 1 };
    let result = add_time(time, 2, 0, 0);
    assert(result.hour == 12);
    assert(result.minute == 30);
    assert(result.second == 20);
}

#[test]
fn test_add_time_add_minutes() {
    let time = Time { hour: 10, minute: 30, second: 20, tz_offset_hours: 1 };
    let result = add_time(time, 0, 45, 0);
    assert(result.hour == 11);
    assert(result.minute == 15);
    assert(result.second == 20);
}

#[test]
fn test_add_time_add_hours_minutes_seconds() {
    let time = Time { hour: 10, minute: 30, second: 20, tz_offset_hours: 1 };
    let result = add_time(time, 1, 29, 40);
    assert(result.hour == 12);
    assert(result.minute == 0);
    assert(result.second == 0);
}

#[test]
fn test_add_time_overflow() {
    let time = Time { hour: 23, minute: 59, second: 55, tz_offset_hours: 1 };
    let result = add_time(time, 0, 0, 10);
    assert(result.hour == 0);
    assert(result.minute == 0);
    assert(result.second == 5);
}

#[test]
fn test_adjust_year_zero_change() {
    let date = Date { year: 2020, month: 6, day: 15 };
    let years_to_add = 0;
    let result = adjust_year(date, years_to_add);
    assert(result.year == 2020);
    assert(result.month == date.month);
    assert(result.day == date.day);
}

#[test]
fn test_adjust_year_large_positive() {
    let date = Date { year: 2000, month: 6, day: 15 };
    let years_to_add = 500;
    let result = adjust_year(date, years_to_add);
    assert(result.year == 2500);
    assert(result.month == date.month);
    assert(result.day == date.day);
}

#[test]
fn test_subtract_time_no_change() {
    let time = Time { hour: 10, minute: 30, second: 20, tz_offset_hours: 1 };
    let result = subtract_time(time, 0, 0, 0);
    assert(result.hour == 10);
    assert(result.minute == 30);
    assert(result.second == 20);
}

#[test]
fn test_subtract_time_sub_hours() {
    let time = Time { hour: 10, minute: 30, second: 20, tz_offset_hours: 1 };
    let result = subtract_time(time, 2, 0, 0);
    assert(result.hour == 8);
    assert(result.minute == 30);
    assert(result.second == 20);
}

#[test]
fn test_subtract_from_date_months() {
    let date = Date { year: 2021, month: 12, day: 15 };
    let result = subtract_from_date(date, 0, 6, 0);
    assert(result.year == date.year);
    assert(result.month == 6);
    assert(result.day == date.day);
}

#[test]
fn test_subtract_from_date_days() {
    let date = Date { year: 2021, month: 1, day: 15 };
    let result = subtract_from_date(date, 0, 0, 10);
    assert(result.year == date.year);
    assert(result.month == date.month);
    assert(result.day == 5);
}

#[test]
fn test_adjust_month_no_change() {
    let date = Date { year: 2021, month: 6, day: 15 };
    let result = adjust_month(date, 0);
    assert(result.year == 2021);
    assert(result.month == 6);
    assert(result.day == 15);
}

#[test]
fn test_adjust_month_add() {
    let date = Date { year: 2021, month: 6, day: 15 };
    let result = adjust_month(date, 6);
    assert(result.year == 2021);
    assert(result.month == 12);
    assert(result.day == 15);
}

#[test]
fn test_adjust_month_subtract() {
    let date = Date { year: 2021, month: 6, day: 15 };
    let result = adjust_month(date, -5);
    assert(result.year == 2021);
    assert(result.month == 1);
    assert(result.day == 15);
}

#[test]
fn test_adjust_month_overflow() {
    let date = Date { year: 2021, month: 11, day: 15 };
    let result = adjust_month(date, 5);
    assert(result.year == 2022);
    assert(result.month == 4);
    assert(result.day == 15);
}

#[test]
fn test_adjust_month_large_adjustment() {
    let date = Date { year: 2021, month: 1, day: 15 };
    let result = adjust_month(date, 24);
    assert(result.year == 2023);
    assert(result.month == 1);
    assert(result.day == 15);
}

#[test]
fn test_adjust_day_no_change() {
    let date = Date { year: 2021, month: 6, day: 15 };
    let result = adjust_day(date, 0);
    assert(result.year == 2021);
    assert(result.month == 6);
    assert(result.day == 15);
}

#[test]
fn test_adjust_day_add_within_month() {
    let date = Date { year: 2021, month: 6, day: 15 };
    let result = adjust_day(date, 10);
    assert(result.year == 2021);
    assert(result.month == 6);
    assert(result.day == 25);
}

#[test]
fn test_adjust_day_subtract_within_month() {
    let date = Date { year: 2021, month: 6, day: 15 };
    let result = adjust_day(date, -10);
    assert(result.year == 2021);
    assert(result.month == 6);
    assert(result.day == 5);
}

#[test]
fn test_adjust_day_add_overflow_month() {
    let date = Date { year: 2021, month: 6, day: 25 };
    let result = adjust_day(date, 10);
    assert(result.year == 2021);
    assert(result.month == 7);
    assert(result.day == 5);
}