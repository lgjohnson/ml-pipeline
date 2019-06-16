#create spark context as sc

from pyspark.ml.regression import LinearRegression

#constants
S3_BUCKET = 'lgjohnson-ml-pipeline-training-stg'
S3_PREFIX = 'training_data'
S3_URI = "s3://{}/{}/{}".format(S3_BUCKET, S3_PREFIX, '*.csv')

FEATURES = ['Year', 'Month', 'DayofMonth', 'Dest', 'Distance']
TARGET = 'ArrDelay'

#read in airplane training data
airplane_df = spark.read.csv(
    S3_URI,
    header = True,
    inferSchema = True
)

#code to munge into required format

#code to train-test split
train_df, test_df = split_train_test(airplane_df)

lr = LinearRegression(maxIter=10, regParam=0.3, elasticNetParam=0.8)

lrModel = lr.fit(training_df)