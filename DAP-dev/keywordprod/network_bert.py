from sklearn.cluster import AgglomerativeClustering
from velzon.db_helpers import Databases
import pandas as pd
import numpy as np
from sklearn.metrics.pairwise import euclidean_distances

import networkx as nx


DB = Databases()

def sql_vol_load(
    word_list_txt: list    
    ) -> pd.DataFrame : 
    query =  f"""
    with wt_rgs as (
    select keyword
    ,coalesce (max(volume), 0) as vol
    from keywordpd.rel_google_stat
    where keyword in ('{word_list_txt}')
    GROUP BY keyword
    ), wt_rns as (
    select base_keyword as keyword 
    ,coalesce (max(lst_mon_vol), 0) as vol
    from keywordpd.rel_naver_stat
    where base_keyword in ('{word_list_txt}')
    GROUP BY base_keyword 
    ) select a.keyword
    ,coalesce(a.vol, 0)+ coalesce(b.vol, 0) as vol
    from wt_rgs as a left outer join wt_rns as b on a.keyword  = b.keyword     """

    return pd.read_sql(sql=query, con=DB.db)


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
            COALESCE({vol_col}, 0) as vol,
            level 
        FROM related_keywords;
        """
    return pd.read_sql(sql=sql, con=DB.db)


def load_embedding(word_list: list) -> pd.DataFrame:
    word_list_txt = "', '".join(word_list)
    raw_embed = pd.read_sql(f"SELECT * FROM keywordpd.keyword_base_table WHERE keyword in ('{word_list_txt}')", con=DB.db)
    return pd.DataFrame(raw_embed['embedding'].to_list(), index = raw_embed['keyword'].values).T


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
            columns=['base_keyword', 'keyword', 'vol','level'])

    return related_keywords


# Data Loading
def load_keywords(
    keyword: str, 
    direction: str, 
    steps: int = 2, 
    cutoff: str = 0,
    google_search: bool = True,
    google_trend: bool = True,
    naver_search: bool = True
) -> pd.DataFrame:
    # data setting
    if direction == 'bipath':
        df1 = fetch_related_keywords(
            keyword, 
            max_level=steps, 
            cutoff=cutoff, 
            direction='forward',
            google_search=google_search,
            google_trend=google_trend,
            naver_search=naver_search
        ).drop_duplicates(subset=['base_keyword', 'keyword'])
        
        df2 = fetch_related_keywords(
            keyword, 
            max_level=steps, 
            cutoff=cutoff, 
            direction='backward',
            google_search=google_search,
            google_trend=google_trend,
            naver_search=naver_search
        ).drop_duplicates(subset=['base_keyword', 'keyword'])

        agg_df = pd.concat([
            df1['base_keyword'],
            df1['keyword'],
            df2['base_keyword'],
            df2['keyword']
        ]).drop_duplicates()
        
    else:
        df = fetch_related_keywords(
            keyword, 
            max_level=steps, 
            cutoff=cutoff, 
            direction='forward',
            google_search=google_search,
            google_trend=google_trend,
            naver_search=naver_search
        ).drop_duplicates(subset=['base_keyword', 'keyword'])
        agg_df = pd.concat([
            df['base_keyword'],
            df['keyword']
        ]).drop_duplicates()
        
    return agg_df.reset_index(drop=True)


# Agglo Cluster
def agglo_cluster(embedded: pd.DataFrame, dist_threshold: int) -> pd.DataFrame:
    clustering = AgglomerativeClustering(
        n_clusters=None,
        compute_full_tree=True,
        linkage='complete',
        distance_threshold=dist_threshold,
        compute_distances=True
    ).fit_predict(embedded.T)

    result = pd.DataFrame([
        embedded.columns,
        clustering+1
    ], index=['keyword', 'cluster']).T.sort_values('cluster')
    return result

# Euclidean Distance
def get_euclidean_dist(embedded: pd.DataFrame, one_sided: bool = False, scale: bool=True) -> pd.DataFrame:
    eu_dist = pd.DataFrame(euclidean_distances(
        embedded.T), index=embedded.columns, columns=embedded.columns)
    if scale:
        scaled_eu_dist = (1 - eu_dist / eu_dist.max().max())
    else:
        scaled_eu_dist = eu_dist

    if one_sided:
        upper_triangle = scaled_eu_dist.where(
            np.triu(np.ones(scaled_eu_dist.shape), k=1).astype(bool))
        one2one_df = upper_triangle.stack().reset_index()
    else:
        one2one_df = scaled_eu_dist.stack().reset_index()
        one2one_df = one2one_df[one2one_df['level_0'] != one2one_df['level_1']]
    one2one_df.columns = ['from', 'to', 'dist']
    return one2one_df


# Draw Network
def create_network_obj(filtered: pd.DataFrame, cluster_dict: dict, agg_df_vol: pd.DataFrame) -> pd.DataFrame:
    G = nx.Graph()
    nodes = pd.DataFrame(
        pd.concat([filtered['from'], filtered['to']]).drop_duplicates())
    nodes['cluster'] = nodes[0].apply(lambda x: cluster_dict[x])
    ### 검색량 넣기 
    for node, cluster in nodes.values:
        try : 
            vols = agg_df_vol.set_index('keyword').loc[node,'vol']
        except :
            vols = 0
        G.add_node(node_for_adding=node, vol=vols, name=node, category=cluster)

    for edge in filtered[['from', 'to']].values:
        G.add_edge(edge[0],  edge[1])
    return G


# Helper
def get_each_cluster(result: pd.DataFrame, cluster: int) -> pd.DataFrame:
    return result[result['cluster'] == cluster]


def get_color(i, r_off=1, g_off=1, b_off=1):
    '''Assign a color to a vertex.'''
    r0, g0, b0 = 0, 0, 0
    n = 16
    low, high = 0.1, 0.9
    span = high - low
    r = low + span * (((i + r_off) * 3) % n) / (n - 1)
    g = low + span * (((i + g_off) * 5) % n) / (n - 1)
    b = low + span * (((i + b_off) * 7) % n) / (n - 1)
    return (r, g, b)


#
def final_network_obj(embedded: pd.DataFrame, cluster_dict: dict, agg_df_vol: pd.DataFrame,return_type: str = 'json'):
    eu_dist_2side = get_euclidean_dist(embedded)

    cluster_embed = embedded.T
    cluster_embed['cluster'] = [cluster_dict[word]
                                for word in cluster_embed.index]

    cluster_keyword = cluster_embed['cluster'].reset_index().groupby('cluster')[
        'index'].apply(list).to_dict()

    clust_center = cluster_embed.groupby('cluster').median()
    center_node = {}
    for group in sorted(set(cluster_dict.values())):
        center_node[group] = pd.concat([
            cluster_embed[cluster_embed['cluster']
                          == group].drop(columns=['cluster']),
            clust_center.loc[[group]]
        ]).T.corr()[group][:-1].sort_values(ascending=False).index[0]

    groups = []
    for group in cluster_keyword.keys():
        temp = eu_dist_2side[eu_dist_2side['to'].isin(cluster_keyword[group])]
        internal_group = temp[temp['from'] == center_node[group]]
        groups.append(internal_group)

    # Method 1
    ## 문제 발생 : outer connection 이 서로 마주보고 있는상황(두개의 동일한 케이스) : index error out-of-bound 발생
    ## 이유 : 그룹이 단 두개인데 여기서 서로 이어지면 outer_connection 에서 each center에 있는걸 못잡음  
    ## 이때, 남은 인덱서가 없으니 발생하는 문제, 
    ## 해결방안 이경우는 동일한 경우에서 발생하는 거니깐, 동일한지 체크하고 동일하면 패스   
    center_network = eu_dist_2side[(eu_dist_2side['from'].isin(
        pd.Series(center_node))) & (eu_dist_2side['to'].isin(pd.Series(center_node)))]
    for each_center in center_network['from'].drop_duplicates():
        if (len(center_network) == 1) & (center_network['to'].iloc[0] == each_center):
            print('same-path-network')
            pass
        else : 
            outer_connection = center_network[center_network['from'] == each_center].sort_values(
                'dist', ascending=False).iloc[[0]]
            center_network = center_network[~((center_network['to'] == outer_connection['from'].iloc[0]) & (
                center_network['from'] == outer_connection['to'].iloc[0]))]
            groups.append(outer_connection)

    filtered = pd.concat(groups).reset_index(drop=True)
    G = create_network_obj(filtered, cluster_dict, agg_df_vol)
    if return_type == 'json':
        return_file = nx.node_link_data(G)
        return_file['categories'] = [{"name": center_node[node]} for node in sorted(set([ind['category'] for ind in return_file['nodes']]))]
        return return_file
    else:
        return G


def network_json(
    keyword: str,
    steps: int,
    direction: str,
    gender: str = None,
    cutoff: int = 0,
    google_search: bool = True,
    google_trend: bool = True,
    naver_search: bool = True
    ) : 
    agg_df = load_keywords(
        keyword=keyword, 
        direction=direction, 
        steps=steps, 
        cutoff=cutoff, 
        google_search=google_search,
        google_trend=google_trend,
        naver_search=naver_search
        )
    embedded = load_embedding(agg_df.to_list())
        
    eu_dist_1side = get_euclidean_dist(embedded, True, False)
    result = agglo_cluster(embedded, np.quantile(eu_dist_1side['dist'], 0.75))

    cluster_dict = result.set_index('keyword')['cluster'].to_dict()
    
    agg_df_vol = sql_vol_load("', '".join(agg_df.to_list()))
        
    return final_network_obj(embedded, cluster_dict, agg_df_vol)

if __name__ == "__main__":
    keyword: str = 'PDRN'
    steps: int = 1
    direction: str = 'bipath'
    gender: str = None
    cutoff: int = 100
    google_search: bool = True
    google_trend: bool = True
    naver_search: bool = False
    
    jsonfile2 = network_json(
        keyword=keyword,
        steps=steps,
        direction=direction,
        gender=None,
        cutoff=cutoff,
        google_search=google_search,
        google_trend=google_trend,
        naver_search=naver_search
    )
    

    