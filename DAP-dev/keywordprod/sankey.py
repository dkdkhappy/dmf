# import networkx as nx
# import matplotlib.pyplot as plt
import datetime
from dateutil.relativedelta import relativedelta
from velzon.db_helpers import Databases
import pandas as pd

DB = Databases()
db = DB.db


def sql_load(
        keyword: str,
        base_column: str,
        target_column: str,
        table_name: str,
        cutoff: int,
        max_level: int) -> pd.DataFrame:
    if 'naver' in table_name:
        vol_col = 'lst_mon_vol'
        key_col = 'base_keyword'
        stat_table_name = 'rel_naver_stat'
    elif 'google' in table_name:
        vol_col = 'volume'
        key_col = 'keyword'
        stat_table_name = 'rel_google_stat'
        
    else:
        raise "Inappropriate table name"
    
    sql = f"""
        WITH RECURSIVE
        related_keywords AS (
            -- Base case (level 0)
            SELECT 
                base_table.{base_column}, 
                base_table.{target_column}, 
                stat_table.{vol_col}, 
                0 as level
            FROM 
                keywordpd.{table_name} base_table
            LEFT JOIN 
                keywordpd.{stat_table_name} stat_table ON base_table.{target_column} = stat_table.{key_col}
            WHERE 
                base_table.{base_column} = '{keyword}' AND COALESCE(stat_table.{vol_col}, 0) >= {cutoff}

            UNION ALL

            -- Recursive step
            SELECT 
                rel_table.{base_column}, 
                rel_table.{target_column}, 
                stat_table.{vol_col}, 
                rel_key.level + 1
            FROM 
                related_keywords rel_key
            JOIN 
                keywordpd.{table_name} rel_table ON rel_key.{target_column} = rel_table.{base_column}
            LEFT JOIN 
                keywordpd.{stat_table_name} stat_table ON rel_table.{target_column} = stat_table.{key_col}
            WHERE 
                rel_key.level < {max_level} AND COALESCE(stat_table.{vol_col}, 0) >= {cutoff}
        )
        SELECT 
            {base_column}, 
            {target_column}, 
            COALESCE({vol_col}, 0),
            level 
        FROM related_keywords
        """
    print(sql)
    return pd.read_sql(sql=sql, con=db)


# 샹키그래프 베이스 데이터 베이스 불러오기
def fetch_related_keywords(
    keyword: str,
    max_level: int,
    cutoff: int,
    direction: str,
    google_search: bool = True,
    google_trend: bool = True,
    naver_search: bool = True
) -> pd.DataFrame:
    if direction == "forward":
        base_column, target_column = "base_keyword", "keyword"
    elif direction == "backward":
        base_column, target_column = "keyword", "base_keyword"
    else:
        raise ValueError(
            "Invalid direction. Choose either 'forward' or 'backward'.")

    related_keywords_list = []
    # Google Search
    if google_search:
        google_search_df = sql_load(
            keyword.lower(),
            base_column,
            target_column,
            table_name='rel_google',
            cutoff=cutoff,
            max_level=max_level)
        related_keywords_list.append(google_search_df)

    # Google Trend
    if google_trend:
        google_trend_df = sql_load(
            keyword.lower(),
            base_column,
            target_column,
            table_name='rel_google_trend_rel',
            cutoff=cutoff,
            max_level=max_level)
        related_keywords_list.append(google_trend_df)

    # Naver Search
    if naver_search:
        naver_search_df = sql_load(
            keyword,
            base_column,
            target_column,
            table_name='rel_naver_relkey',
            cutoff=cutoff,
            max_level=max_level)
        related_keywords_list.append(naver_search_df)

    if related_keywords_list:
        related_keywords = pd.concat(related_keywords_list)
    else:
        related_keywords = pd.DataFrame(
            columns=['base_keyword', 'keyword', 'level'])

    return related_keywords


def get_related_keywords(
    keyword: str,
    steps: int,
    direction: str,
    cutoff: int,
    google_search: bool,
    google_trend: bool,
    naver_search: bool
) -> pd.DataFrame:
    if direction == 'bipath':
        forward_keywords = fetch_related_keywords(
            keyword,
            steps+0,
            cutoff,
            "forward",
            google_search,
            google_trend,
            naver_search)

        forward_keywords['level'] = forward_keywords['level'] + steps + 1
        backward_keywords = fetch_related_keywords(
            keyword, 
            steps,
            cutoff, 
            "backward", 
            google_search, 
            google_trend, 
            naver_search)
        backward_keywords['level'] = (backward_keywords['level'] - steps) * -1
        combined_keywords = pd.concat([forward_keywords, backward_keywords], axis = 0)
    elif direction == 'backward':
        combined_keywords = fetch_related_keywords(
            keyword, 
            steps, 
            cutoff, 
            direction, google_search, google_trend, naver_search)
        combined_keywords['level'] = (combined_keywords['level'] - steps) * -1
    else:
        combined_keywords = fetch_related_keywords(
            keyword, steps, cutoff, direction, google_search, google_trend, naver_search)
    return combined_keywords


def get_naver_search_vol(keyword_list: list, base_mnth: str) -> pd.DataFrame:
    return pd.read_sql(
        f"""
            SELECT * FROM keywordpd.rel_naver_vol 
            WHERE base_keyword in ('{"', '".join(keyword_list)}') 
            AND period = '{base_mnth}'""", con=db)


def get_google_search_vol(keyword_list: list, base_mnth: str) -> pd.DataFrame:
    keyword_list2= []
    for keywords in keyword_list:
        keyword_list2.append(keywords.lower())
    return pd.read_sql(
        f"""
            SELECT * FROM keywordpd.rel_google_vol
            WHERE keyword in ('{"', '".join(keyword_list2)}')
            AND date = '{base_mnth}'""", con=db)


def get_gender_value() -> pd.DataFrame:
    return pd.read_sql("SELECT * FROM keywordpd.rel_naver_stat", con=db)


def add_gender_value(base_mnth: str, datafile: pd.DataFrame) -> pd.DataFrame:
    keyword_df = pd.concat(
        [datafile['base_keyword'], datafile['keyword']], axis=0).drop_duplicates()

    gender_df = get_gender_value().drop_duplicates(subset='base_keyword')
    naver_vol = get_naver_search_vol(keyword_df.to_list(), base_mnth).drop_duplicates(subset='base_keyword')
    google_vol = get_google_search_vol(keyword_df.to_list(), base_mnth).drop_duplicates(subset='keyword')

    return pd.concat([
        gender_df.set_index('base_keyword')[['male', 'female']],
        naver_vol.set_index('base_keyword')[
            'searchvolume'].rename('naver_vol'),
        google_vol.set_index('keyword')['volume'].rename('google_vol')
    ], axis=1).reindex(keyword_df)


def process_gender(mod_datafile: pd.DataFrame, gender: str = None) -> pd.DataFrame:
    if gender:
        return pd.concat([
            (mod_datafile['naver_vol'] *
             (mod_datafile[gender] / 100)).dropna().rename('naver'),
            (mod_datafile['google_vol'] *
                 (mod_datafile[gender] / 100)).dropna().rename('google')
        ], axis=1)
    else:
        return pd.concat([
            mod_datafile['naver_vol'].rename('naver'),
            mod_datafile['google_vol'].rename('google')
        ], axis=1)


def make_sankey_db(
    keyword: str,
    steps: int,
    direction: str,
    fr_mnth: str,
    to_mnth: str,
    gender: str = None,
    cutoff: int = None,
    google_search: bool = True,
    google_trend: bool = True,
    naver_search: bool = True
) -> dict:
    """
    Db만들기 양방향 : bipath
    시작 : forward
    종료 : backward
    
    Args:
        keyword (_type_): 검색할 키워드
        steps (_type_): 앞뒤 2단계면 1만 입력 (입력에서 1빼서 넣기)
        direction (_type_): 기본은 bipath
    """
    datafile = get_related_keywords(
        keyword,
        steps,
        direction,
        cutoff,
        google_search,
        google_trend,
        naver_search)
    datafile = datafile.reset_index(drop=True)
    datafile['count'] = 1

    print(f"fr_mnth : {fr_mnth}")
    print(f"to_mnth : {to_mnth}")

    base_mnth = (datetime.datetime.today().replace(day=1) -
                 relativedelta(months=2, days=1)).strftime('%Y-%m')
    
    # Consider gender
    datafile_gender_added = add_gender_value(base_mnth, datafile)
    processed_df = process_gender(datafile_gender_added, gender)

    if cutoff:
        filtered_keywords = processed_df[((processed_df > cutoff).sum(1) > 0) | pd.Series(processed_df.index == keyword, index=processed_df.index)]
    else:
        filtered_keywords = processed_df.copy()

    filtered_df = datafile[datafile['base_keyword'].isin(
        filtered_keywords.index) & datafile['keyword'].isin(filtered_keywords.index)]

    nameset = pd.DataFrame(
        pd.concat([filtered_df['base_keyword'].rename('name'),
                  filtered_df['keyword'].rename('name')]).drop_duplicates())

    ddf = filtered_df.drop_duplicates(subset=['base_keyword', 'keyword'])[
        ['base_keyword', 'keyword']]
    mod_ddf = ddf[(ddf['base_keyword'] == ddf['keyword']) == False]
    
    mod_ddf['value'] = 1
    mod_ddf.columns = ['source', 'target', 'value']        

    data = dict(
        nodes=nameset.to_dict(orient='records'),
        links=mod_ddf.to_dict(orient='records')
    )
    return data


if __name__ == "__main__":
    keyword = '미백'
    steps = 2
    direction = 'forward'  # 'forward', 'backword'
    gender = None  # 'female', 'male'
    cutoff = 10  # int 0인 경우 nan도 포함하도록 로직 생성
    google_search=True
    google_trend=True
    naver_search=True

    data = make_sankey_db(
        keyword,
        steps,
        direction,
        gender,
        cutoff=cutoff,
        google_search=google_search,
        google_trend=google_trend,
        naver_search=naver_search
    )
    
    data
