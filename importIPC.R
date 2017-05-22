library(readxl)
library(dplyr)
library(lubridate)
library(ggplot2)

# import FEWS NET historic IPC monitoring ---------------------------------
ipc2017 = read.csv('~/Documents/USAID/FEWSNET/rawdata/HFIC_FDW_Submission_Data_20170201.csv')
ipc2016 = read.csv('~/Documents/USAID/FEWSNET/rawdata/HFIC_FDW_Submission_Data_20160526.csv')
ipc_countries = read.csv('~/Documents/USAID/FEWSNET/rawdata/HFIC_FDW_Submission_FS_World_20170201.csv')


# filter out just the “current scenarios” (current not proj) --------------
# filter out parks and lakes
ipc2016 = ipc2016 %>% 
  mutate(PHASE = as.numeric(as.character(PHASE)), 
         HA = as.numeric(as.character(HA))) # converting 'NC' to NA

ipc = bind_rows(ipc2016, ipc2017) %>% 
  filter(SCENARIO == 'CS',
         ! PHASE %in% c(88,99), 
         !is.na(PHASE)) %>% 
  mutate(start = as.Date(COVERAGE_START),
         end = as.Date(COVERAGE_END),
         year_start = year(start),
         year_end = year(end),
         year = (year_start + year_end)/ 2,
         phase = PHASE) %>% 
  select(start, end, year, phase, COUNTRY)

# IPC categories http://www.fews.net/IPC
# 1: minimal
# 2: stressed
# 3: crisis
# 4: emergency
# 5: catastrophe

# merge in country names --------------------------------------------------

ipc  = left_join(ipc, ipc_countries %>% select(COUNTRY, ADMIN0), by = 'COUNTRY')



# parks and lakes
# ipc = ipc %>% 
#   mutate(phase = na_if(PHASE, 99),
#          phase = na_if(phase, 88))

max_ipc = ipc %>% group_by(ADMIN0, year) %>% 
  summarise(max_ipc = max(phase, na.rm = T),
            avg = mean(phase, na.rm = T),
            min(start),
            max(end)) %>% 
  arrange(desc(max_ipc))

ipc_class = c('minimal', 'stressed', 'crisis', 'emergency', 'catastrope')
fews_colour = c('#C3E2C3', '#F3E838', '#EB7D24', '#CD2026', '#5D060C')
ipc_colour = rev(c('#79435B', '#D990A3', '#EACAB5', '#FAECE1', '#FAF9D7'))

ipc_breaks = data.frame(phase = 1:5,
                        ymin = 1:5 - 0.5,
                        ymax = 1:5 + 0.5,
                        ipc_class = ipc_class,
                        ipc_colour = ipc_colour)


ipc_order = max_ipc %>% 
  ungroup() %>% 
  group_by(ADMIN0) %>% 
  summarise(avg_max = mean(max_ipc)) %>% 
  arrange(desc(avg_max))

max_ipc$ADMIN0 = factor(max_ipc$ADMIN0, levels = ipc_order$ADMIN0)

ggplot(max_ipc) +
  geom_rect(aes(xmin = min(max_ipc$year), 
                xmax = max(max_ipc$year),
                ymin = ymin,
                ymax = ymax,
                fill = ipc_colour), 
            alpha = 0.95,
            data = ipc_breaks) +
  geom_line(aes(x = year, y = max_ipc, group = ADMIN0), size = 0.25, colour = grey75K) +
  geom_point(aes(x = year, y = max_ipc), size = 1.5, colour = grey75K) +
  
  scale_y_continuous(labels = ipc_class, breaks = 1:5) +
  scale_x_continuous(breaks = seq(2009, 2017, by = 3)) +
  scale_fill_identity() +
  
  ggtitle('Highest IPC classification in any part of the country, per year') +
  
  facet_wrap(~ADMIN0) +
  theme_xgrid()
