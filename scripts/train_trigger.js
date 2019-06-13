#!/usr/bin/env node

const aws = require('aws-sdk');
const s3 = new aws.S3({signatureVersion: 'v4'});

exports.handler = (event, context, callback) => {

    const key = event.Records[0].s3.object.key;
    console.log('Image uploaded: ', key);

    callback(null, {
        statusCode: '201',
        headers: {
            'training image': key
        },
        body: `${key} was uploaded.`
    });
};
