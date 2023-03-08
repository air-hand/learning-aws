# Manage S3 for backend

backendにS3を使いたいが、backendそれ自体を循環参照的に管理はできないため、別途ローカルでステート管理

*.tfvars.sample を元に必要なファイルを作成して、terraform init -backend-config で指定できるように
