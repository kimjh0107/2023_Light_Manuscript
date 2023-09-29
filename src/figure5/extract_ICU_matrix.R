library(here)
library(tidyverse)

## Sepsis Demographic to patient long table
sepsis_demo <- read_csv(here("data/raw/sepsis_demographic.csv"))

patient_long_table <- sepsis_demo %>%
  select(No, patient_id, age, sex, starts_with("DrawTime")) %>%
  pivot_longer(cols = starts_with("DrawTime"), names_to = "timepoint", values_to = "timestamp") %>%
  mutate(timepoint = as.numeric(str_replace(timepoint, "DrawTime", "")))

icu_matrix <- read_csv(here("data/raw/ICU_matrix.csv"))

merged_table <- patient_long_table %>%
  left_join(icu_matrix) %>%
  mutate(timediff = abs(timestamp - DrawTime))

min_time_table <- merged_table %>%
  group_by(No, patient_id, timepoint, timestamp, prescription_code, code_name) %>%
  summarize(min_time = min(timediff, na.rm = T))

result_table <- merged_table %>%
  right_join(min_time_table, by = c("No", "patient_id", "timepoint", "timestamp", "prescription_code", "code_name")) %>%
  filter(min_time == timediff) %>%
  select(No, patient_id, timepoint, timestamp, prescription_code, code_name, value, result_value, min_time) %>%
  filter(min_time <= 24 * 60)

result_table
write_csv(result_table, here("data/processed/ICU_result.csv"))
