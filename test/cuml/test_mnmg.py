from cuml.dask.linear_model import LinearRegression
from dask_cuda import LocalCUDACluster
from dask.distributed import Client
import cudf
import dask_cudf


def test_mnmg():
    cluster = LocalCUDACluster(threads_per_worker=1)
    _ = Client(cluster)

    # Create and populate a GPU DataFrame
    df_float = cudf.DataFrame()
    df_float['0'] = [1.0, 2.0, 5.0]
    df_float['1'] = [4.0, 2.0, 1.0]
    df_float['2'] = [4., 2, 1]

    ddf_float = dask_cudf.from_cudf(df_float, npartitions=2)

    X = ddf_float[ddf_float.columns.difference(['2'])]
    y = ddf_float['2']
    mod = LinearRegression()
    mod = mod.fit(X, y)

    actual_output = str(mod.predict(X).compute())
    expected_output = """0    4.0
1    2.0
2    1.0
dtype: float64"""
    assert actual_output == expected_output
