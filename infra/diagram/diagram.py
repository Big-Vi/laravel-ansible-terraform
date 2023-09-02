from diagrams import Cluster, Diagram, Edge
from diagrams.aws.compute import EC2
from diagrams.aws.database import RDS
from diagrams.aws.network import Route53
from diagrams.aws.management import SystemsManager
from diagrams.onprem.iac import Terraform
from diagrams.onprem.iac import Ansible

with Diagram("Laravel server infrastructure & configuration", show=False):
    dns = Route53("dns")

    with Cluster("Laravel infra"):
        web = EC2("EC2")
        web - [SystemsManager("Parameter Store")]
        web - RDS("Postgres-RDS")

    dns >> web << Edge(label="Infra provisioning") << Terraform() << Ansible() >> Edge(label="Configure, Manage & Secure") >> web
