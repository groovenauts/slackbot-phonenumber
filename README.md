Slackに電話番号(+811234567890形式)が貼られたらSansan APIから電話番号検索して、ついでにjpnumberのリンクを貼るbot。

## Usage

```
bundle
WATCH_CHANNEL='<Watch Channel>' INTERVAL='<Polling interval>' APP_ID='<SLACK App ID>' TOKEN='<SLACK Bot User OAuth Access Token>' SANSAN_API_KEY='<Sansan Api Key>' bundle exec ruby slackclient-phonenumber.rb
```
