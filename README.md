# Easy Auth を使用する App Service でユーザーとして別のアプリに接続する手順

## 参考 URL

- https://learn.microsoft.com/ja-jp/azure/app-service/tutorial-auth-aad
- https://learn.microsoft.com/ja-jp/azure/app-service/configure-authentication-oauth-tokens#refresh-auth-tokens
- https://jpazpaas.github.io/blog/2023/05/31/Access-to-EasyAuth-enabled-App-Service-via-Azure-Front-Door.html
- https://learn.microsoft.com/ja-jp/azure/app-service/overview-authentication-authorization#considerations-when-using-azure-front-door

## デプロイ手順

### Infra

```bash
cd terraform
terraform plan
terraform apply
```

### backend

Docker イメージを push 後、AppService のデプロイセンターを開いて push したイメージを指定する

```bash
cd backend

repoName="easyauthdevacr"
acrServer="$repoName.azurecr.io"
image=fastapi
az acr login --name $repoName

docker build -t ${acrServer}/${image}:1 .
docker push ${acrServer}/${image}:1
```

### frontend

Kudu で SSH 接続して index.html の内容をコピペする

```bash
cd site/wwwroot
vi index.html
```

## AD 認証の有効化と構成

ユーザーサインインの認証で付与されたアクセストークンを利用して frontend → backend の API を呼び出すにはスコープに対するアクセス許可とログインパラメータの追加が必要

1. frontend/backend の AppService で AD 認証を有効化する
2. frontend のアプリに backend のアクセス権を付与する（スコープはデフォルトの user_impersonation）
3. frontend の AppService の authsettingsV2 に loginParameters を追加する（scripts/webapp-auth-set.sh を実行）

## Azure Front Door を経由して Azure AD 認証を有効にした App Service へアクセスするための手順

1. frontend/backend のアプリのリダイレクト URL のホスト部分を FrontDoor のエンドポイントに書き換える（<app_name>.azurewebsites.net → <endpoint_name>-xxxxx.xxx.azurefd.net）
2. App Service の proxy を設定する（scripts/az-rest-set-forward-proxy.sh を実行）

## 動作確認

1. frontend のエンドポイントに接続してサインインする（ゲストモード推奨）
2. API URL の初期値を backend の FrontDoor の FQDN に書き換える
3. GET ボタンを押して Hello World が返ってくれば OK
