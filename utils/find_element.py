from selenium.webdriver.common.by import By

def find_information(driver, xpath):
    infor_elements = driver.find_elements(By.XPATH, xpath)
    infors = []
    for infor in infor_elements:
        infor = infor.text.strip()
        infors.append(infor)
    return infors

def find_link(driver, xpath):
    infor_elements = driver.find_elements(By.XPATH, xpath)
    infors = []
    for infor in infor_elements:
        infor = infor.get_attribute('href')
        infors.append(infor)
    return infors

def find_interaction(driver, iteration):
    votes = []
    views = []
    comments = []
    for i in range(iteration):
        try:  
            vote = driver.find_element(By.XPATH, f'//*[@id="new-card-{i}"]/div/div/div[2]/div/div[2]/div[2]/a[1]/span').text.strip()      
            view = driver.find_element(By.XPATH, f'//*[@id="new-card-{i}"]/div/div/div[2]/div/div[2]/div[2]/a[2]/span').text.strip()
            comment = driver.find_element(By.XPATH, f'//*[@id="new-card-{i}"]/div/div/div[2]/div/div[2]/div[2]/a[3]/span').text.strip()
            votes.append(vote)
            views.append(view)
            comments.append(comment)
        except:
            vote = driver.find_element(By.XPATH, f'//*[@id="new-card-{i}"]/div/div/div[2]/div/div[2]/div[2]/a[1]/span').text.strip()      
            view = '0'
            comment = driver.find_element(By.XPATH, f'//*[@id="new-card-{i}"]/div/div/div[2]/div/div[2]/div[2]/a[2]/span').text.strip()
            votes.append(vote)
            views.append(view)
            comments.append(comment)
        
    interaction = {"votes":votes, "views":views, "comments":comments}
    return interaction