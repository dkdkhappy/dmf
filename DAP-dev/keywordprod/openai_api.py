import openai
from velzon.utils import call_csv

def call_chatgpt(keywords2):
    secret = call_csv('dap-derma', 'RAW/auth/open_ai_secret.csv')
    openai.api_key = secret['api_key'][0]
    keywords = ', '.join(keywords2)
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages = [
            {"role": "system", "content": "You are a helpful assistant that classify and summarize text based on cosmetics industry knowledge."},
            {"role": "user", "content": f'read these Korean search keywords and make an excel table to classify them into detailed categories based on your knowledge of the cosmetics industry. and you have to write the insights that can be used for marketing or product development or sales strategy in the cosmetics market on below. write in Korean. write in HTML format """{keywords}""" '},
            
            ],
        temperature=0.5,
    )
    return response['choices'][0]['message']['content']


def call_chatgpt_intention(keywords_json, kwrd):
    secret = call_csv('dap-derma', 'RAW/auth/open_ai_secret.csv')
    openai.api_key = secret['api_key'][0]
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages = [
            {"role": "system", "content": "You are a helpful assistant that classify and summarize text based on cosmetics industry knowledge."},
            {"role": "user", "content": f'I have a json file of the top 30 cosmetic keywords related to "{kwrd}" in Korea from search engine. Here, node_key is the search site, kwrd_nm is the search keyword, and finally vol is the search volume. Tell me the insights and business idea you can learn through this based on the knowledge of cosmetics industry. Do not write search volume ranking table. Do not write description of json file. write in Korean. write in HTML format """ {keywords_json}""" '},
            
            ],
        temperature=0.5,
    )
    return response['choices'][0]['message']['content']

# example = ['예민한피부'	,
# '피부장벽강화'	,
# '판테놀'	,
# '나이아신아마이드'	,
# '유리드'	,
# '더랩바이블랑두' ,'올리고' ,'히알루론산'	,
# '속건조']

# call_chatgpt(example)


def call_chatgpt_review_summary(review_json):
    secret = call_csv('dap-derma', 'RAW/auth/open_ai_secret.csv')
    openai.api_key = secret['api_key'][0]
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages = [
            {"role": "system", "content": "You are a helpful assistant that classify and summarize text based on cosmetics industry knowledge."},
            {"role": "user", "content": f'I have an our cosmetic product chinese reviews in china market. Tell me the shortly summarization of our review, insights and product development idea you can learn through this based on the knowledge of cosmetics industry. you must write Korean.  """ {review_json}""" '},
            
            ],
        temperature=0.3,
    )
    return response['choices'][0]['message']['content']
