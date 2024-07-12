# Các nội dung
- [Giới thiệu](#Giới-thiệu)
- [Cấu trúc project](#Cấu-trúc-project)
- [Các bước cài đặt](#Các-bước-cài-đặt)

## Giới thiệu
### Tổng quan
#### Quá trình crawl dữ liệu
- Sử dụng Selenium bằng ngôn ngữ Python để crawl dữ liệu từ trang web [Spiderum](https://spiderum.com/?sort=hot&page_idx=1) theo thứ tự bài đăng mới nhất. Do trang mạng xã hội được chia theo nhiều
chủ đề, thực hiện crawl theo từng chủ đề.
- Quá trình crawl chia làm 2 giai đoạn, crawl tất cả bài đăng và crawl hằng ngày.
- Ứng với dữ liệu bài đăng crawl được sẽ được đổ vào bảng trong cơ sở dữ liệu PostgresSQL bằng thư viện <span style="color: blue;">psycopg2</span> của Python.

#### Quá trình etl dữ liệu
- Dữ liệu sau khi được crawl về sẽ được lưu trữ tại vùng stagging.
- Xây dựng các procedure để biến đổi dữ liệu, sau đó mapping dữ liệu các cột cần phân tích về dạng id.
- Đổ dữ liệu sau khi đã biến đổi về bảng fact, sau đó xây dựng các bảng dim tương ứng theo mô hình OLAP hình sao.

#### Xây dựng dashboard
- Sử dụng PowerBI để kết nối trực tiếp với dữ liệu trong PostgreSQL và tạo dashboard.

### Kết quả đạt được
<table width="100%"> 
<tr>
<td width="50%">      
&nbsp; 
<br>
<p align="center">
  Báo cáo tổng quan
</p>
<img width="508" alt="tongquan_w" src="https://github.com/user-attachments/assets/7e00061b-d8de-49ba-bbe0-a70e8c1c3434">
</td> 
<td width="50%">
<br>
<p align="center">
  Báo cáo hoạt động
</p>
<img width="509" alt="hoatdong_w" src="https://github.com/user-attachments/assets/e9fb22ab-c9cc-4d88-9d80-bf9c27e4c9a9">
</td>
</table>

## Cấu trúc project
- Thư mục config chứa các xpath mà selenium sẽ sử dụng và tên các chủ đề của trang spiderum.
- Thư mục utils chứa các hàm mà selenium sẽ thực hiện bao gồm tương tác với trang web, và lấy dữ liệu theo xpath.
- File crawl_all.py thực hiện crawl tất cả dữ liệu.
- File crawl_daily.py thực hiện crawl dữ liệu từ ngày hôm trước.
- File procedure.sql chứa các procedure để biến đổi dữ liệu.
- File table.sql chứa các câu lệnh để tạo bảng vùng stagging, và các bảng dim, fact.
- File data.csv chứa dữ liệu crawl.
- File requirements.txt chứa các thư viện cần cài đặt.

## Các bước cài đặt
--> Clone repo:
```bash
git clone https://github.com/Thai1708/Crawl-ETL-Visualize-Spiderum-Web.git

```

--> Tạo một virtual environment :
```bash
# Let's install virtualenv first
pip install virtualenv

# Then we create our virtual environment
virtualenv envname

```

--> Kích hoạt virtual environment :
```bash
envname\scripts\activate

```

--> Cài đặt các thư viện cần thiết :
```bash
pip install -r requirements.txt

```
--> Cài đặt các table trong file table.sql bằng PostgreSQL.

--> Cài đặt các procedure trong file procedure.sql bằng PostgreSQL.

--> Chạy file crawl_all.py
