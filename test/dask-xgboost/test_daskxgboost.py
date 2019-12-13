import pytest

@pytest.fixture
def startDaskClient() :
    from dask.distributed import Client
    return Client('scheduler-address:8786')  # connect to cluster

@pytest.mark.skip(reason="not done")
def test_daskxgboost(startDaskClient) :
    client = startDaskClient
    import dask.dataframe as dd
    df = dd.read_csv('...')  # use dask.dataframe to load and
    df_train = False           # preprocess data
    labels_train = False

    import dask_xgboost as dxgb
    params = {'objective': 'binary:logistic', }  # use normal xgboost params
    bst = dxgb.train(client, params, df_train, labels_train)

    predictions = dxgb.predict(client, bsg, data_test)
