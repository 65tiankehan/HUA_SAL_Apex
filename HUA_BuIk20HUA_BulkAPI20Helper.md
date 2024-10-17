# HUA_BulkAPI20Helper 使用手册
    作者 ：HUA_JI_WU_NIAN
    作成日：2024年10月17日
    更新日：2024年10月17日
    目的：`HUA_BulkAPI20Helper` クラスは、Salesforce の Bulk API 2.0 を使用して大量のデータを効率的に処理するためのユーティリティ機能を提供します。各メソッドは、ジョブの作成、データのアップロード、ジョブの状態の設定とチェック、成功したレコードの取得などの操作をサポートします。

## 目次

- [サマリー](#サマリー)
- [メソッドリスト](#メソッドリスト)
  - [createJob](#createjob)
  - [uploadData](#uploaddata)
  - [setJobStateToUploadComplete](#setjobstatetouploadcomplete)
  - [checkJobStatus](#checkjobstatus)
  - [getSuccessfulResults](#getsuccessfulresults)
  - [performBulkInsert](#performbulkinsert)
  - [performBulkDelete](#performbulkdelete)

## サマリー

`HUA_BulkAPI20Helper` は、Salesforce Apex クラスで、Salesforce の Bulk API 2.0 を使用して大量のデータを効率的に処理するための複数の静的メソッドを提供します。これらのメソッドは、ジョブの作成、データのアップロード、ジョブの状態の設定とチェック、成功したレコードの取得などの操作をサポートします。

## メソッドリスト

### createJob

**機能**：Bulk API 2.0 のジョブを作成します。

**パラメータ**：
- `objectTypeName` (String)：オブジェクトのタイプ名。
- `operation` (String)：実行する操作（例: `insert`, `update`）。

**戻り値**：作成されたジョブの ID。

### uploadData

**機能**：CSV データをアップロードします。

**パラメータ**：
- `jobId` (String)：ジョブの ID。
- `csvData` (String)：アップロードする CSV データ。

### setJobStateToUploadComplete

**機能**：ジョブの状態を「アップロード完了」に設定します。

**パラメータ**：
- `jobId` (String)：ジョブの ID。

### checkJobStatus

**機能**：ジョブの状態をチェックします。

**パラメータ**：
- `jobId` (String)：ジョブの ID。

**戻り値**：ジョブの状態情報。

### getSuccessfulResults

**機能**：成功したレコードを取得します。

**パラメータ**：
- `jobId` (String)：ジョブの ID。

**戻り値**：成功したレコードの CSV データ。

### performBulkInsert

**機能**：一括挿入を実行します。

**パラメータ**：
- `dataMap` (Map<String, List<String>>)：CSV データを含む Map。
- `objectTypeName` (String)：オブジェクトのタイプ名。
- `operation` (String)：実行する操作（例: `insert`, `update`）。

### performBulkDelete

**機能**：一括削除を実行します。

**パラメータ**：
- `recordIds` (List<String>)：削除対象のレコード ID リスト。
- `objectTypeName` (String)：オブジェクトタイプ名。

## ほじょほうほう

### convertMapToCsv

**機能**：Map を CSV 文字列に変換します。

**パラメータ**：
- `dataMap` (Map<String, List<String>>)：CSV データを含む Map。

**戻り値**：CSV 文字列。

### convertListToCsv

**機能**：レコード ID リストを CSV 文字列に変換します。

**パラメータ**：
- `recordIds` (List<String>)：レコード ID リスト。

**戻り値**：CSV 文字列。

### 使用例

#### 一括挿入の例

```apex
Map<String, List<String>> accountData = new Map<String, List<String>> {
    'Name' => new List<String> { 'Lorem Ipsum', 'Posuere Inc', 'Angeles Urban', 'Madaline Neubert Shoes', 'Times Online UK', 'The Washington Post', 'Amazon' },
    'ShippingCity' => new List<String> { 'Milano', 'Bodø', 'Aykol', 'Xukou', 'Varadero', 'Hengdaohezi', 'Quintães' },
    'NumberOfEmployees' => new List<String> { '2676', '141603', '197724', '190305', '121802', '190944', '80285' },
    'AnnualRevenue' => new List<String> { '912260031', '896852810', '257060529', '71664061', '58284123', '164329406', '684173825' },
    'Website' => new List<String> { 'https://ft.com/lacus/at.jsp', 'http://webs.com/in/faucibus/orci/luctus/et/ultrices/posuere.json', 'http://odnoklassniki.ru/sapien.aspx', 'https://blogs.com/faucibus/orci/luctus/et/ultrices/posuere/cubilia.json', 'http://timesonline.co.uk/eu/magna.html', 'http://washingtonpost.com/vestibulum/proin/eu/mi/nulla/ac/enim.png', 'http://amazon.co.uk/potenti/cras/in/purus/eu.png' },
    'Description' => new List<String> { 'Lorem ipsum dolor sit amet', 'consectetur adipiscing elit', 'sed do eiusmod tempor incididunt ut labore et dolore magna aliqua', 'Ut enim ad minim veniam', 'quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat', 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur', 'Excepteur sint occaecat cupidatat non proident' }
};

HUA_BulkAPI20Helper.performBulkInsert(accountData, 'Account', 'insert');
```

### 一括削除の例

```apex
List<String> accountIdsToDelete = new List<String> {
    '001XXXXXXXXXXXXXXX1',
    '001XXXXXXXXXXXXXXX2',
    '001XXXXXXXXXXXXXXX3'
};

HUA_BulkAPI20Helper.performBulkDelete(accountIdsToDelete, 'Account');
```

### 注意事項

-Salesforceの接続と権限が適切に設定されていることを確認します。
-本番環境で使用する場合は、デバッグと監視を効率化するためにエラー処理とログを追加することをお勧めします。