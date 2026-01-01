#!/usr/bin/env python3
import os
import aws_cdk as cdk
from cdk_stack import StartupCoIamStack

app = cdk.App()

StartupCoIamStack(
    app, 
    "StartupCoIamStack",
    description="StartupCo IAM Security Implementation - Groups, Users, and Policies",
    env=cdk.Environment(
        account=os.getenv('CDK_DEFAULT_ACCOUNT'),
        region=os.getenv('CDK_DEFAULT_REGION', 'us-east-1')
    )
)

app.synth()
