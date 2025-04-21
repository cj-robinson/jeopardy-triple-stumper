# SET UP
# ---------------------------------------------------------------------
# load necessary libraries
library(tidyverse)
library(lubridate)
library(zoo)
library(jsonlite)

# read in the data
df <- read_csv("../data/jeopardy_clues_2.csv")

# CLEANING
# ---------------------------------------------------------------------
# change date format
df <- df %>%
  mutate(date = mdy(str_extract(game_date, "(?<= - ).*"))) %>% 
  filter(date >= '2009-06-01')

# find tournament games
non_special <- df %>%
  filter(!grepl("master", tolower(game_comments)),
         !grepl("invitation", tolower(game_comments)),
         !grepl("college", tolower(game_comments)),
         !grepl("celebrity", tolower(game_comments)),
         !grepl("championship", tolower(game_comments)),
         !grepl("second chance", tolower(game_comments)),
         !grepl("champions", tolower(game_comments)),
         !grepl("power player", tolower(game_comments)),
         !grepl("battle", tolower(game_comments)),
         !grepl("kids", tolower(game_comments)),
                  !grepl("tournament", tolower(game_comments)))

# examine comments from each game
comments <- non_special %>% group_by(game_comments, date) %>% tally()
filtered_games <- anti_join(df, non_special, by = "game") %>% group_by(game_comments) %>% tally()


# EXPLORATION + VIZ
# ---------------------------------------------------------------------
# triple stumpers -- no filtering
df %>%
  group_by(date, game) %>%
  summarize(stumps = sum(triple_stump)) %>%
  group_by(date) %>% 
  summarize(stumps = mean(stumps)) %>% 
  arrange(date) %>% 
  mutate(rolling_avg = rollmean(stumps, k = 90, fill = NA, align = "center")) %>%
  ggplot(aes(x = date)) +
  # geom_line(aes(y = stumps)) +
  geom_line(aes(y = rolling_avg), color = "red") +
  theme_minimal()

ggsave("../img/triple_stumper_timeline.pdf")


# triple stumpers -- filtering
non_special %>%
  group_by(date, game) %>%
  summarize(stumps = sum(triple_stump)) %>%
  group_by(date) %>% 
  summarize(stumps = mean(stumps)) %>% 
  mutate(rolling_avg = rollmean(stumps, k = 30, fill = NA, align = "right")) %>%
  mutate(group = cumsum(c(0, diff(as.numeric(date)) > 5))) %>%
  ggplot(aes(x = date)) +
  # geom_line(aes(y = stumps)) +
  geom_line(aes(y = rolling_avg), color = "red", na.rm = TRUE) + 
  theme_minimal()


ggsave("../img/triple_stumper_timeline_filtered.pdf")

# beeswarm of all games -- import into RAWGRAPHS
df %>% 
  filter(date >= '2015-01-01') %>%
  group_by(date, game) %>%
  summarize(stumps = sum(triple_stump), .groups = "keep")  %>%
  mutate(period = ifelse(date>='2024-01-01', "recent", "old")) %>% 
  write_csv("stumps.csv") 

# STUMPS
# ---------------------------------------------------------------------

jeopardy_questions <- non_special %>% 
  filter(triple_stump,
         value == 200) %>% 
  select(clue_text, correct_response, value) %>% 
  rename("clue" = "clue_text", 
         "answer" = "correct_response")


write_json(jeopardy_questions, "../data/jeopardy_questions.json", pretty = TRUE)


# OTHER EXPLORATION/DUMP
# ---------------------------------------------------------------------

# rolling average of triple stumpers -- filtered
non_special %>% 
  group_by(date, game) %>%
  summarize(stumps = sum(triple_stump)) %>%
  group_by(date) %>% 
  summarize(stumps = mean(stumps)) %>% 
  mutate(rolling_avg = rollmean(stumps, k = 180, fill = NA, align = "right")) %>%
  ggplot(aes(x = date)) +
   geom_line(aes(y = stumps)) +
  geom_line(aes(y = rolling_avg), color = "red") +
  ggtitle("Rolling average of number of clues that no one got right")


# triple stumpers -- monthly average

non_special%>% 
  group_by(date = floor_date(date, unit = "month"), game) %>%
  summarize(stumps = sum(triple_stump)) %>%
  group_by(date) %>% 
  summarize(stumps = mean(stumps)) %>% 
  mutate(rolling_avg = rollmean(stumps, k = 12, fill = NA, align = "right")) %>%
  ggplot(aes(x = date)) +
  geom_line(aes(y = stumps)) +
  geom_line(aes(y = rolling_avg), color = "red") 



df %>%
  filter(!grepl("master", tolower(game_comments)),
         !grepl("invitation", tolower(game_comments)),
         !grepl("college", tolower(game_comments)),
         !grepl("celebrity", tolower(game_comments)),
         !grepl("championship", tolower(game_comments)),
         !grepl("second chance", tolower(game_comments)),
         !grepl("champions", tolower(game_comments)),
         
         # !grepl("final", tolower(game_comments)),
         !grepl("tournament", tolower(game_comments)))%>%
  mutate(wrong_flag= ifelse(wrong_count >= 1,1,0)) %>% 
  group_by(date, game) %>%
  summarize(wrong_count = sum(wrong_flag)) %>%
  group_by(date) %>% 
  summarize(wrong_count = mean(wrong_count)) %>% 
  mutate(rolling_avg = rollmean(wrong_count, k = 90, fill = NA, align = "right")) %>%
  ggplot(aes(x = date)) +
  geom_line(aes(y = wrong_count)) +
  geom_line(aes(y = rolling_avg), color = "red") 

df %>%
  filter(dd == "TRUE") %>%
  group_by(game,date) %>%
  summarize(wrong_count = sum(wrong_count)) %>%
  group_by(date) %>% 
  summarize(wrong_count = mean(wrong_count)) %>% 
  mutate(rolling_avg = rollmean(wrong_count, k = 180, fill = NA, align = "right")) %>%
  ggplot(aes(x = date)) +
  geom_line(aes(y = wrong_count)) +
  geom_line(aes(y = rolling_avg), color = "red") 


non_special %>% 
  group_by(date, game) %>%
  summarize(stumps = sum(triple_stump)) %>%
  filter(stumps >= 20) %>% 
  group_by(year = year(date)) %>% 
  summarize(stumps = n()) %>% 
  ggplot(aes(x = year, y = stumps)) + 
  geom_bar(stat = "identity") + 
  theme_minimal()

---
# easy stumps
  
  library(forcats)

df %>% 
  filter(triple_stump) %>% 
  mutate(old_new = case_when(
    date >= "2011-01-01" & date < "2012-01-01" ~ "2010",
    date >= "2024-03-01" & date < "2025-03-01" ~ "2025",
    TRUE ~ NA_character_
  )) %>% 
  filter(!is.na(old_new)) %>%
  group_by(old_new) %>%
  mutate(value_top = fct_lump_n(factor(value), n = 5, w = NULL)) %>%
  mutate(value_rank = fct_rev(fct_infreq(value_top)),
         value_rank = fct_rank(value_rank)) %>%
  mutate(value_label = as.character(value_rank)) %>%
  ungroup() %>%
  count(old_new, round, value_label) %>% 
  mutate(n = if_else(round == "round1", -n, n)) %>%
  ggplot(aes(x = value_label, y = n, fill = round)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  facet_wrap(vars(old_new), scales = "free_y") +
  theme_minimal() +
  ylab("Count") +
  xlab("Top 5 Values (Ranked)")


easy_stumps <- non_special %>% 
  filter(triple_stump,
         value == 200)

easy_stumps %>% 
  filter(date >= '2010-01-01') %>% 
  group_by(date, game) %>%
  summarize(stumps = sum(triple_stump)) %>%
  group_by(date) %>% 
  summarize(stumps = mean(stumps)) %>% 
  mutate(rolling_avg = rollmean(stumps, k = 90, fill = NA, align = "right")) %>%
  ggplot(aes(x = date)) +
  geom_line(aes(y = rolling_avg), color = "red") +
  ggtitle("$200 clues that no contestants got right")

non_special %>% 
  mutate(wrong_flag = ifelse(wrong_count > 0,1,0)) %>% 
  filter(value == 200) %>% 
  group_by(date = floor_date(date, "month")) %>%
  summarize(stumps = sum(wrong_flag)) %>%
  mutate(rolling_avg = rollmean(stumps, k = 12, fill = NA, align = "right")) %>%
  ggplot(aes(x = date)) +
  geom_line(aes(y = rolling_avg), color = "red") +
  ggtitle("$200 clues that no contestants got right")


non_special %>% 
  group_by(date, game) %>%
  filter(date < '2025-01-01') %>% 
  summarize(stumps = sum(triple_stump))  %>% 
  mutate(stumps = ifelse(stumps >= 10, "big", "tiny")) %>% 
  group_by(stumps, date = floor_date(date, "year")) %>%
  summarize(count = n()) %>%
  ggplot(aes(x = date, fill = factor(stumps))) +
  geom_bar(aes(y = count),stat = "identity", position = "fill") + 
  scale_fill_viridis_d(option = "plasma") +  # Use the viridis color palette
  theme_minimal()


# stumps beeswarm 

df %>% 
  filter((date >= "2024-01-01" & date < "2025-02-01") | (date >= '2023-01-01' & date < "2024-01-01")) %>% 
  group_by(date, game) %>%
  summarize(stumps = sum(triple_stump), .groups = "drop") %>%  # Explicitly drop the grouping
  arrange(date) %>%
  mutate(period = ifelse(date >= "2024-01-01" & date < "2025-02-01", 
                         "recent", 
                         "old")) %>%
   write_csv("stumps_cat.csv") 
  



df %>% 
  filter(date >= '2015-01-01') %>%
  group_by(date, game) %>%
  summarize(stumps = sum(triple_stump), .groups = "keep")  %>%
  filter(stumps >= 15) %>% 
  mutate(period = ifelse(date>='2024-01-01', "recent", "old")) %>% 
  write_csv("big_stumps.csv") 


#streak 

non_

non_special %>%
  mutate(streak_flag = ifelse(grepl("game\\s+\\d+", game_comments), "streak", "not streak")) %>% 
  group_by(date, streak_flag) %>% 
  summarize(games = n_distinct(game)) %>% 
  group_by(year = floor_date(date, "year"),
           streak_flag) %>% 
  summarize(games = sum(games)) %>% 
  pivot_wider(names_from = "streak_flag", values_from = "games") %>% 
  mutate(prop_streak = `streak` / (`not streak` + `streak`)) %>% 
  ggplot(aes(x = year, y = prop_streak)) + 
  geom_bar(stat = "identity")
  
  
