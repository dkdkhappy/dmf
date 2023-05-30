from .sankey import get_related_keywords, add_gender_value, process_gender
from dateutil.relativedelta import relativedelta
import datetime
import networkx as nx
import operator
import networkx.algorithms.community as nxcom
import operator
import pandas as pd  
### network db 만들기

def make_network_db(
    keyword: str,
    steps: int,
    direction: str,
    gender: str = None,
    cutoff: int = None,
    google_search: bool = True,
    google_trend: bool = True,
    naver_search: bool = True
    ):
    """
    Db만들기 양방향 : bipath
    시작 : forward
    종료 : backward
   
    Args:
        keyword (_type_): 검색할 키워드
        steps (_type_): 앞뒤 2단계면 1만 입력 (입력에서 1빼서 넣기)
        direction (_type_): 기본은 bipath
    """
    if cutoff == None : 
        cutoff = 0

    datafile = get_related_keywords(keyword, steps, direction, cutoff, google_search , google_trend , naver_search)
    datafile = datafile.reset_index(drop = True)
    datafile['count'] = 1

    base_mnth = (datetime.datetime.today().replace(day=1) -
                 relativedelta(months=2, days=1)).strftime('%Y-%m')

    # Consider gender
    datafile_gender_added = add_gender_value(base_mnth, datafile)
    processed_df = process_gender(datafile_gender_added, gender)

    if cutoff:
        filtered_keywords = processed_df[(processed_df > cutoff).sum(1) > 0]
    else:
        filtered_keywords = processed_df.copy()

    filtered_df = datafile[datafile['base_keyword'].isin(
        filtered_keywords.index) & datafile['keyword'].isin(filtered_keywords.index)]

    ddf = filtered_df.drop_duplicates(subset=['base_keyword', 'keyword'])[
        ['base_keyword', 'keyword']]
    mod_ddf = ddf[(ddf['base_keyword'] == ddf['keyword']) == False]
    
    mod_ddf['value'] = 1
    mod_ddf.columns = ['source', 'target', 'value']        

    return mod_ddf

def set_node_community(G, communities):
        '''Add community to node attributes'''
        for c, v_c in enumerate(communities):
            for v in v_c:
                # Add 1 to save 0 for external edges
                G.nodes[v]['category'] = c + 1
def set_edge_community(G):
    '''Find internal edges and add their community to their attributes'''
    for v, w, in G.edges:
        if G.nodes[v]['category'] == G.nodes[w]['category']:
            # Internal edge, mark with community
            G.edges[v, w]['category'] = G.nodes[v]['category']
        else:
            # External edge, mark as 0
            G.edges[v, w]['category'] = 0
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


### db로 네트워크 분석 진행  
def network_json(
    keyword: str,
    steps: int,
    direction: str,
    gender: str = None,
    cutoff: int = None,
    google_search: bool = True,
    google_trend: bool = True,
    naver_search: bool = True
    ) : 
    network_db = make_network_db(keyword = keyword, steps = steps, direction = direction, gender = gender, cutoff= cutoff,google_search = google_search,  google_trend = google_trend, naver_search = naver_search)
    G = nx.Graph()
    G.add_weighted_edges_from( network_db.apply(tuple, axis= 1 ).to_list())

    ### degree centrality stage
    G_centrality = nx.from_pandas_edgelist(network_db, 'source', 'target')
    print(G_centrality)
    dgr = nx.degree_centrality(G_centrality)

    sorted_dgr = sorted(dgr.items(), key=operator.itemgetter(1), reverse=True)
    G = nx.Graph()
    for ids, nodesize in sorted_dgr : 
        # print(id, nodesize)
        G.add_node(node_for_adding = ids,  value= nodesize, name = ids )

    for ind in range(len(network_db)):
        G.add_edges_from([(network_db['source'].iloc[ind], network_db['target'].iloc[ind])])

    communities = sorted(nxcom.greedy_modularity_communities(G), key=len, reverse=True)

    # Set node and edge communities
    set_node_community(G, communities)
    # set_edge_community(G)
    jsonfile= nx.node_link_data(G)  

    check_file = pd.DataFrame(sorted_dgr)
    jsonfile['categories'] = list()
    for com in communities:
        jsonfile['categories'].append({"name": check_file[check_file[0].isin(list(com))].sort_values([1], ascending = False)[0].iloc[0]})
  
    return jsonfile

# if __name__ : "__main__"  :
# #     jsonfile = network_json(keyword = '펩타이드', steps = 0, google_search = False, google_trend = True, naver_search = False) 
# import json
# with open(r'C:\DermaFrim Project\datacheck\data2.json', 'w') as f:
#     json.dump(jsonfile, f)
# jsonfile

# f = open(r'C:\DermaFrim Project\datacheck\data.json', 'wb')
# f.write(jsonfile)

# node_color = [get_color(G.nodes[v]['community']) for v in G.nodes]
# # Set community color for edges between members of the same community (internal) and intra-community edges (external)
# external = [(v, w) for v, w in G.edges if G.edges[v, w]['community'] == 0]
# internal = [(v, w) for v, w in G.edges if G.edges[v, w]['community'] > 0]
# internal_color = ['black' for e in internal]

# karate_pos = nx.spring_layout(G)

# dbs = nx.node_link_data(G)
# dbs['nodes']['category'] = dbs['nodes']['community']

# node_db = dbs['nodes']
# for
# node_db.pop('community')

# dbs['nodes'][0]['community']

# ax = plt.gca()

# # # Draw external edges
# nx.draw_networkx(
#     G,
#     pos=karate_pos,
#     node_size=0,
#     edgelist=external,
#     edge_color="silver")
# # Draw nodes and internal edges
# nx.draw_networkx(
#     G,
#     pos=karate_pos,
#     node_color=node_color,
#     edgelist=internal,
#     edge_color=internal_color, font_family=font_name)
# ax.collections[0].set_edgecolor("#555555")

