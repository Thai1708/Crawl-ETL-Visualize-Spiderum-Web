import os
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains

from utils.find_element import find_information, find_link, find_interaction
from utils.interaction import close_popup, scroll_end_page

from config.xpaths import xpath

import time
import csv
import psycopg2

# Thiết lập đường dẫn đến thư mục chứa driver của bạn (ví dụ là ChromeDriver)
driver_path = r"C:/SeleniumDrivers/chromedriver.exe"

# Thiết lập biến môi trường để có thể sử dụng driver
os.environ['PATH'] += os.pathsep + driver_path

# Khởi tạo driver
driver = webdriver.Chrome(service=Service(driver_path))


# Tạo hoặc mở file CSV để ghi thông tin
csv_file = 'data.csv'

# Đặt tên cho các cột
fieldnames = ['ten_bai_viet', 'link_bai_viet', 'thoi_luong_doc', 'thoi_gian_dang', 'ten_tac_gia', 'link_tac_gia', 'vote', 'view', 'comment', 'chu_de']

conn = psycopg2.connect(
    dbname="painting",
    user="postgres",
    password="pthai332277",
    host="localhost",
    port="5432"
)
# Tạo một con trỏ
cur = conn.cursor()

# Xác định tên bảng
table_name = "stg_spiderum"
create_table_query = f"""
CREATE TABLE IF NOT EXISTS {table_name} (
    id SERIAL PRIMARY KEY,
    ten_bai_viet VARCHAR(600),
    link_bai_viet VARCHAR(1000),
    thoi_luong_doc VARCHAR(20),
    thoi_gian_dang VARCHAR(50),
    ten_tac_gia VARCHAR(100),
    link_tac_gia VARCHAR(1000),
    vote VARCHAR(20),
    view VARCHAR(20),
    comment VARCHAR(20),
    chu_de VARCHAR(100),
    id_thoi_luong_doc int,
    id_thoi_gian_dang int,
    id_ten_tac_gia int,
    id_vote int,
    id_view int,
    id_comment int,
    id_chu_de int
);
"""
cur.execute(create_table_query)

# Cam kết thay đổi
conn.commit()


for i in range(63,89):
    driver.get(f"https://spiderum.com/danh-muc/khoa-hoc-cong-nghe?sort=new&page_idx={i+1}")
    time.sleep(3)

    close_popup(driver)
    scroll_end_page(driver)

    time.sleep(2)
    print(f"************************************TRANG THU {i+1}****************************************")
    titles = find_information(driver, xpath["title"])
    links = find_link(driver, xpath["link"])
    reading_mins = find_information(driver, xpath["reading_min"])
    time_creates = find_information(driver, xpath["time_create"])
    authors = find_information(driver, xpath["author_name"])
    author_links = find_link(driver, xpath["author_link"])
    topics = find_information(driver, xpath["category"])
    iteration = len(titles)
    interaction = find_interaction(driver, iteration)
    votes = interaction["votes"]
    views = interaction["views"]
    comments = interaction["comments"]

    for i in range(iteration):
        print("######################")
        print(f"Item thu {i}")
        print(titles[i], links[i], reading_mins[i], time_creates[i], authors[i], author_links[i], votes[i], views[i], comments[i])

        data = {
                        'ten_bai_viet': titles[i],
                        'link_bai_viet': links[i],
                        'thoi_luong_doc': reading_mins[i],
                        'thoi_gian_dang':time_creates[i],
                        'ten_tac_gia':authors[i],
                        'link_tac_gia':author_links[i],
                        'vote':votes[i],
                        'view':views[i],
                        'comment':comments[i],
                        'chu_de':topics[i]
                        }
        columns = ', '.join(data.keys())
        values = ', '.join(['%s'] * len(data))
        sql = f"INSERT INTO {table_name} ({columns}) VALUES ({values})"
        cur.execute(sql, list(data.values()))
    # Cam kết thay đổi
    conn.commit()
        
    driver.quit()
    # Khởi tạo lại driver cho URL tiếp theo
    driver = webdriver.Chrome(service=Service(driver_path))
    time.sleep(1)


# Đóng con trỏ và kết nối
cur.close()
conn.close()
driver.quit()