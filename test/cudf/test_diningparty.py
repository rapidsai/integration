
import pytest

def test_diningparty() :
    import cudf, requests
    from io import StringIO

    url="https://github.com/plotly/datasets/raw/master/tips.csv"
    content = requests.get(url).content.decode('utf-8')

    tips_df = cudf.read_csv(StringIO(content))
    tips_df['tip_percentage'] = tips_df['tip']/tips_df['total_bill']*100

    # compute the average tip by dining party size
    cudfSeries = tips_df.groupby('size').tip_percentage.mean()

    # the expected average tip percentage for parties sized 1, 2, 3,
    # etc. for the data set.
    expectedValues = [
        21.729201548727808,
        16.571919173482893,
        15.215685473711837,
        14.594900639351332,
        14.149548965142023,
        15.622920072028379,
    ]

    assert len(expectedValues) == len(cudfSeries)

    for (actual, expected) in zip(cudfSeries, expectedValues) :
        assert actual == pytest.approx(expected)
