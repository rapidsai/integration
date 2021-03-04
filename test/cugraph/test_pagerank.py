import pytest
from os import path

import cudf

# Assumes the datasets are located in a directory that's peer to the
# directory this file is contained in.
thisDir = path.dirname(path.abspath(__file__))
datasetDir = path.join(thisDir, "datasets")
csvFile = path.join(datasetDir, "dolphins.csv")

def read_csv_file(csv_file):
    """
    Read csv_file and return a cuDF DataFrame
    """
    return cudf.read_csv(csv_file, delimiter=' ',
                         dtype=['int32', 'int32', 'float32'], header=None)

# PageRanks for each vertex for csvFile
expectedPageRanks = [
    0.016964989,
    0.024651665,
    0.013337773,
    0.009628838,
    0.005079706,
    0.014428924,
    0.020054877,
    0.015643409,
    0.017097909,
    0.023459984,
    0.015108048,
    0.005079706,
    0.0048352256,
    0.026158556,
    0.032143496,
    0.019882523,
    0.016626319,
    0.031729873,
    0.01939494,
    0.012928585,
    0.02464034,
    0.016938455,
    0.005416102,
    0.009863298,
    0.016905222,
    0.011504734,
    0.0112105915,
    0.017130828,
    0.0148456935,
    0.026457744,
    0.01530216,
    0.005416102,
    0.013309369,
    0.028422212,
    0.015919494,
    0.004918124,
    0.020613264,
    0.029874478,
    0.023938559,
    0.0077649346,
    0.021965932,
    0.016138505,
    0.01761831,
    0.021690488,
    0.0128305005,
    0.029513286,
    0.008825701,
    0.017339252,
    0.0052618985,
    0.008876556,
    0.019231373,
    0.03129846,
    0.012072265,
    0.008180864,
    0.021652013,
    0.007493997,
    0.008326691,
    0.030097133,
    0.00496281,
    0.014767586,
    0.0061903875,
    0.011038934,
]

def test_pagerank() :
    import cugraph

    gdf = read_csv_file(csvFile)

    # Assuming that data has been loaded into a cuDF (using read_csv) Dataframe
    # create a Graph using the source and destination vertex pairs
    G = cugraph.Graph()
    G.from_cudf_edgelist(gdf, "0", "1")

    # Call cugraph.pagerank to get the pagerank scores
    # Sort values since renumbering may have changed expected order
    gdf_page = cugraph.pagerank(G)
    gdf_page = gdf_page.sort_values('vertex').reset_index(drop=True)

    assert len(expectedPageRanks) == len(gdf_page["pagerank"])
    for (actual, expected) in zip(gdf_page["pagerank"].to_pandas(),
                                  expectedPageRanks):
        assert actual == pytest.approx(expected, rel=1e-3)
