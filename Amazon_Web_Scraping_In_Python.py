from bs4 import BeautifulSoup
import pandas as pd
import requests
import datetime
import csv

def check_price():
    URL = 'https://www.amazon.co.jp/-/en/dp/B098VZ34QX?smid=AN1VRQENFRJN5&ref_=chk_typ_imgToDp&th=1'

    headers = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.54 Safari/537.36"}

    page = requests.get(URL, headers=headers)

    soup1 = BeautifulSoup(page.content, 'html.parser')

    soup2 = BeautifulSoup(soup1.prettify(), 'html.parser')

    title = soup2.find(id='productTitle').get_text().strip()

    price = soup2.find('span', {'class' : 'a-offscreen'}).get_text().strip()[1:]

    today = datetime.date.today()

    data = [title, price, today]

    with open('MaskScraping.csv', 'a+', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(data)

# while True:
#     check_price()
#     time.sleep(86400)
#     df = pd.read_csv('MaskScraping.csv')
#     print(df)

