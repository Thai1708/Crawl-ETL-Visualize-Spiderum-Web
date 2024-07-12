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



for i in range(61,89):
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

    with open(csv_file, mode='a', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        # writer.writeheader()  # Ghi tiêu đề cột
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
            fieldnames = ['ten_bai_viet', 'link_bai_viet', 'thoi_luong_doc', 'thoi_gian_dang', 'ten_tac_gia', 'link_tac_gia', 'vote', 'view', 'comment', 'chu_de']
            # Ghi dictionary vào file CSV
            writer.writerow(data)
    driver.quit()
    # Khởi tạo lại driver cho URL tiếp theo
    driver = webdriver.Chrome(service=Service(driver_path))
    time.sleep(1)

driver.quit()


