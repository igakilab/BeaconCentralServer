# Beacon Central server

iBeaconのビーコン信号を受信して記録するアプリケーションです。
webアプリケーションとしても動作し、リクエストを送ることでjson形式で
認識しているビーコンの情報を返します。

## アプリケーションの実行

coffee scriptで記述することを目標としています。
srcフォルダにソースを記述し、コンパイルは下記のコマンドを実行します。
```
> coffee -b -o lib/ -c src/
```

エントリーポイントはindex.coffee(index.js)にすることにしています。
コンパイル後に下記を実行します
```
> node lib/index.js
```
