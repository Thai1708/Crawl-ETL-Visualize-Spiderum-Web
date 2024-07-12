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
from datetime import date
import csv
import psycopg2

# Thiết lập đường dẫn đến thư mục chứa driver của bạn (ví dụ là ChromeDriver)
driver_path = r"C:/SeleniumDrivers/chromedriver.exe"

# Thiết lập biến môi trường để có thể sử dụng driver
os.environ['PATH'] += os.pathsep + driver_path

# Khởi tạo driver
driver = webdriver.Chrome(service=Service(driver_path))


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

topic_keywords = ['khoa-hoc-cong-nghe', 'quan-diem-tranh-luan', 'tai-chinh', 'the-thao', 'oto', 'nau-an-am-thuc', 'thinking-out-loud', 'sach', 'game', 'xe-may', 'nguoi-trong-muon-nghe', 'goc-nhin-thoi-su', 'am-nhac', 'sang-tac', 'giao-duc', 'lich-su', 'fitness', 'phat-trien-ban-than', 'fashion', 'movie', 'chuyen-tham-kin', 'life-style', 'nhiep-anh', 'dieu-khac-kien-truc-my-thuat', 'yeu', 'tam-ly-hoc', 'wtf', 'du-lich', 'the-brands', 'su-kien-spiderum']

today = date.today()


for topic_keyword in topic_keywords:
    for i in range(1):
        driver.get(f"https://spiderum.com/danh-muc/{topic_keyword}?sort=new&page_idx={i+1}")
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

        for j in range(iteration):
            if time_creates[j] == 'Hôm qua':
                print("######################")
                print(f"Item thu {j}")
                print(titles[j], links[j], reading_mins[j], time_creates[j], authors[j], author_links[j], votes[j], views[j], comments[j])
                data = {
                                'ten_bai_viet': titles[j],
                                'link_bai_viet': links[j],
                                'thoi_luong_doc': reading_mins[j],
                                'thoi_gian_dang':time_creates[j],
                                'ten_tac_gia':authors[j],
                                'link_tac_gia':author_links[j],
                                'vote':votes[j],
                                'view':views[j],
                                'comment':comments[j],
                                'chu_de':topics[j],
                                'ngay_crawl':today
                                }
                columns = ', '.join(data.keys())
                values = ', '.join(['%s'] * len(data))
                sql = f"INSERT INTO {table_name} ({columns}) VALUES ({values})"
                cur.execute(sql, list(data.values()))
                # Cam kết thay đổi
                conn.commit()
            else:
                continue
        
            
        driver.quit()
        # Khởi tạo lại driver cho URL tiếp theo
        driver = webdriver.Chrome(service=Service(driver_path))
        time.sleep(1)


# Đóng con trỏ và kết nối
cur.close()
conn.close()
driver.quit()