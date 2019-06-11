# Machine Learning Pipeline

POC for a production ML training and deployment pipeline.

## Flow

Training Data hits an S3 bucket, triggers AWS orchestration in Step Functions. Glue preprocesses the data and saves a post-processor too. SageMaker then trains an XGBoost model. Model metrics are saved to a relational database.

When a new model is trained, lambda checks if the new model has better metrics than the old model (out of the database metastore). If better, blue/green deploy a new endpoint to SageMaker.

The SageMaker endpoint is a little complex to explain. But basically, instead of feeding raw-features into the endpoint, the features are stored in a noSQL database (DynamoDB), where each entry has a unique id. The payload to the endpoint is an id, which then is used to get the features out of the feature cache, and then it's preprocessed using the pipeline from glue, inference is obtained from the XGBoost model from SageMaker, then it's postprocessed from another artifact from the Glue job.

A caching database is put in front of the endpoint, so if the same request happens twice, it doesn't have to rerun the inference, it can just read the result out of an in-memory store using ElasticCache.

Finally, the way this is plugged into an application is with a streaming architecture. Applications publish to the Kinesis ingress stream, and that triggers a lambda function that hits the cache/endpoint, and then it publishes to a kinesis egress stream.

So your application just has to do two calls to get an inference: publish id to ingress stream, get result from egress stream.

## Project Guidelines

Requirements:

- Everything must be defined in Terraform
- All traffic must flow within a private VPC
- Encryption at rest and in-transit where appropriate
- IAM permissions defined using principles of least privilege
- A live demo presentation
- Ability to handle Q&A about tradeoffs in the design (edited)

Nice to have:

- TFX integration
- Actual GG model
