import pytest
import subprocess

from cudf.tests.utils import assert_eq

__numGPUSkipReason = ""

try:
    __numGPUs = int(subprocess.check_output("nvidia-smi --list-gpus|wc -l",
                                            shell=True))
except Exception as e:
    __numGPUs = 0
    __numGPUSkipReason = str(e)


@pytest.mark.skipif(__numGPUs <= 1,
                    reason="requires >1 GPUs, detected %s %s" % (__numGPUs, __numGPUSkipReason))
def test_cluster():
    from dask_cuda import LocalCUDACluster
    from dask.distributed import Client

    cluster = LocalCUDACluster()
    client = Client(cluster)
    # this assumes running on a machine with more than one GPU
    assert len(client.scheduler_info()['workers']) >= 1

def test_multicolumn_groupby():
    import cudf, dask_cudf

    tmp_df = cudf.DataFrame()
    tmp_df['id'] = [0, 0, 1, 2, 2, 2]
    tmp_df['val1'] = [0, 1, 0, 0, 1, 2]
    tmp_df['val2'] = [9, 9, 9, 9, 9, 9]

    ddf = dask_cudf.from_cudf(tmp_df, npartitions=2)

    actual = ddf.groupby(['id', 'val1']).count().compute()

    # FIXME: this is not idiomatic cudf!
    expectedVals = [1, 1, 1, 1, 1, 1]
    expected = cudf.DataFrame()
    expected['val'] = expectedVals

    assert False not in (expected.to_pandas().values == actual.to_pandas().values)
