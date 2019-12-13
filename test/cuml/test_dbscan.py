
def test_dbscan() :
    import cudf
    from cuml import DBSCAN

    # Create and populate a GPU DataFrame
    gdf_float = cudf.DataFrame()
    gdf_float['0'] = [1.0, 2.0, 5.0]
    gdf_float['1'] = [4.0, 2.0, 1.0]
    gdf_float['2'] = [4.0, 2.0, 1.0]

    # Setup and fit clusters
    dbscan_float = DBSCAN(eps=1.0, min_samples=1)
    dbscan_float.fit(gdf_float)

    actualOutput = str(dbscan_float.labels_)
    expectedOutput = """0    0
1    1
2    2
dtype: int32"""

    assert actualOutput == expectedOutput
    
