#!/usr/bin/env python3

from bs4 import BeautifulSoup
import requests
import pandas as pd

url = "https://en.wikipedia.org/wiki/Solar_power_by_country"

page = requests.get(url)

soup = BeautifulSoup(page.text, "html.parser")

table = soup.find("table")

solar_global = table.find_all("th")

solar_global_title = [title.text.strip() for title in solar_global]

df = pd.DataFrame(columns=solar_global_title)

column_data = table.find_all("tr")

for row in column_data[1:]:
    row_data = row.find_all("td")
    individual_row_data = [data.text.strip() for data in row_data]

    length = len(df)
    df.loc[length] = individual_row_data


df.to_csv(r"path")
