from selenium.webdriver.common.by import By
import time

def close_popup(driver):
    # Tìm phần tử bằng class name
    try:
        close_button = driver.find_element(By.CLASS_NAME, 'fa-times-circle')
        close_button.click()
        print("Đã click vào nút đóng.")
    except Exception as e:
        print("Không thể tìm thấy phần tử:", e)


def scroll_end_page(driver):
    # Lặp lại việc cuộn xuống trang đến khi không còn nội dung mới được tải
    scroll_pause_time = 1  # Thời gian chờ sau mỗi lần cuộn, có thể điều chỉnh
    scroll_increment = 600  # Khoảng cách cuộn (pixel), có thể điều chỉnh

    last_height = driver.execute_script("return document.body.scrollHeight")

    # Khởi tạo thời gian bắt đầu
    start_time = time.time()

    # Thiết lập thời gian tối đa cho vòng lặp là 10 giây
    max_time = 12  # Đơn vị: giây
    while True:
        # Cuộn xuống một khoảng cách ngắn
        driver.execute_script(f"window.scrollBy(0, {scroll_increment});")
        
        # Đợi một chút cho nội dung mới được tải
        time.sleep(scroll_pause_time)
        
        # Tính chiều cao mới của trang
        new_height = driver.execute_script("return document.body.scrollHeight")
        
        # Kiểm tra nếu không có nội dung mới được tải
        if new_height == last_height:
            break

        # Kiểm tra thời gian thực thi vòng lặp
        elapsed_time = time.time() - start_time
        if elapsed_time > max_time:
            print(f"Thời gian thực thi vòng lặp vượt quá {max_time} giây. Dừng vòng lặp.")
            break