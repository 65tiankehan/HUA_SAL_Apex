# HUA_Meta_tool.cls ドキュメント
    作者 ：HUA_JI_WU_NIAN
    作成日：2024年10月17日
    更新日：2024年10月17日
    目的：Salesforce では、オブジェクトやフィールドの処理（フィールド値の更新、フィールド情報の取得、承認フローの処理など）を頻繁に行います。これらのプロセスを簡素化するために、このツールクラスを使用できます。

![コード例](code.png)

## 目次

- [概要](#概要)
- [メソッドリスト](#メソッドリスト)
  - [updateObjects](#updateobjects)
  - [getAllFieldNames](#getallfieldnames)
  - [clearingObjectProperties](#clearingobjectproperties)
  - [createOjbects](#createojbects)
  - [mergeObjects](#mergeobjects)
  - [handleException](#handleexception)
  - [flexibleConfigurationObjectInfo](#flexibleconfigurationobjectinfo)
  - [getPicklistValues](#getpicklistvalues)
  - [getApprovalHistory](#getapprovalhistory)
  - [submitApprovalWorkitems](#submitapprovalworkitems)
  - [isLockedObjects](#islockedobjects)
  - [fetchRecordLayout](#fetchrecordlayout)
  - [updateUserPassword](#updateuserpassword)
  - [resetUserPassword](#resetuserpassword)
  - [describeListView](#describelistview)
  - [fetchListViewResults](#fetchlistviewresults)
  - [getAnyQuery](#getanyquery)
  - [getObjectisInformation](#getobjectisinformation)
  - [getFieldInformation](#getfieldinformation)
  - [getAllObjects](#getAllObjects)
  - [searchObjectsLike](#searchObjectsLike)
## 概要

`HUA_Meta_tool.cls` は、Salesforce Apex クラスで、Salesforce のオブジェクトとフィールドを操作および管理するための複数の静的メソッドを提供します。これらのメソッドは、オブジェクトフィールドの更新、フィールド情報の取得、承認フローの処理、ユーザーのパスワード管理など、さまざまな機能をカバーしています。

## メソッドリスト

### updateObjects

**機能**：指定された SObject のフィールド値を更新します。

**パラメータ**：
- `SObject Objects`：更新対象の SObject。
- `Map<String, Object> fieldMaps`：フィールド名と新しい値のマップ。

**戻り値**：更新後の SObject。

### getAllFieldNames

**機能**：指定されたオブジェクトタイプのすべてのフィールド名を取得します。

**パラメータ**：
- `String objectName`：フィールド名を取得したいオブジェクトの名前。

**戻り値**：指定されたオブジェクトのすべてのフィールド名を含む文字列リスト。

### clearingObjectProperties

**機能**：指定された SObject の特定のフィールド値をクリアします。

**パラメータ**：
- `SObject masterObj`：フィールド値をクリアしたい SObject。
- `List<String> fields`：クリアしたいフィールド名のリスト。

**戻り値**：特定のフィールド値がクリアされた SObject。

### createOjbects

**機能**：指定されたオブジェクトタイプとフィールドマップを使用して新しい SObject を作成します。

**パラメータ**：
- `String objectTypeName`：作成したいオブジェクトタイプの名前。
- `Map<String, Object> fieldMaps`：フィールド名と値のマップ。

**戻り値**：新しく作成された SObject オブジェクトまたは null。

### mergeObjects

**機能**：2つの Salesforce オブジェクトをマージします。

**パラメータ**：
- `SObject masterObj`：更新対象のオブジェクト。
- `SObject mergeObj`：値のソースオブジェクト。

**戻り値**：マージ後の SObject。

### handleException

**機能**：例外を処理し、詳細情報を記録します。

**パラメータ**：
- `Exception e`：発生した例外。

### flexibleConfigurationObjectInfo

**機能**：柔軟な構成を使用して Salesforce オブジェクトを更新します。

**パラメータ**：
- `String strJson`：更新したいフィールドを表す JSON 文字列。
- `Id id`：更新したいオブジェクトの ID。

### getPicklistValues

**機能**：指定された SObject とフィールドのピックリスト値を取得します。

**パラメータ**：
- `String sObjectName`：SObject の名前。
- `String sFieldName`：フィールドの名前。

**戻り値**：ピックリスト値を含むマップ。

### getApprovalHistory

**機能**：指定されたレコード ID の承認履歴を取得します。

**パラメータ**：
- `Id recordId`：対象のレコード ID。
- `Map<String, String> statusParams`：状態パラメータのマップ。

**戻り値**：承認履歴情報を含むリスト。

### submitApprovalWorkitems

**機能**：指定されたレコード ID の承認ワークアイテムを提出します。

**パラメータ**：
- `Id recordId`：対象のレコード ID。
- `String status`：承認ステータス（例：'Approve', 'Reject'）。
- `String message`：承認時のコメント。
- `Id nextApproverId`：次の承認者の ID。

**戻り値**：処理が成功したかどうかのブーリアン値。

### isLockedObjects

**機能**：指定されたオブジェクト ID リストのオブジェクトがロックされているかどうかを確認します。

**パラメータ**：
- `Map<Id, Object> params`：オブジェクト ID とオブジェクトのマップ。

**戻り値**：各オブジェクトがロックされているかどうかの結果マップ。

### fetchRecordLayout

**機能**：指定されたオブジェクトとレコードタイプ ID のレイアウト情報を取得します。

**パラメータ**：
- `String objectName`：オブジェクトの名前。
- `String recordTypeId`：レコードタイプ ID。

**戻り値**：レイアウト情報を含むマップ。

### updateUserPassword

**機能**：指定されたユーザー ID を使用してユーザーのパスワードを設定します。

**パラメータ**：
- `String userId`：ユーザー ID。
- `String newPassword`：新しいパスワード。

**戻り値**：更新が成功したかどうかのブーリアン値。

### resetUserPassword

**機能**：指定されたユーザー ID を使用してユーザーのパスワードをリセットします。

**パラメータ**：
- `String userId`：ユーザー ID。

**戻り値**：リセットが成功したかどうかのブーリアン値。

### describeListView

**機能**：指定されたオブジェクトとクエリロケーターを使用してリストビューの詳細情報を取得します。

**パラメータ**：
- `String sObjectName`：オブジェクトの名前。
- `String queryLocator`：クエリロケーター。

**戻り値**：リストビューの詳細情報を含むマップ。

### fetchListViewResults

**機能**：指定されたオブジェクトとリストビュー ID を使用してリストビューの結果を取得します。

**パラメータ**：
- `String sObjectName`：オブジェクトの名前。
- `String listViewId`：リストビュー ID。
- `Integer limit`：最大返却レコード数（1-2000）。デフォルトは 25。
- `Integer offset`：返却される最初のレコード。このパラメータは結果のページングに使用されます。デフォルトは 0。

**戻り値**：リストビューの結果を含むマップ。

### getAnyQuery
- **説明**: 任意の SOQL クエリを実行し、結果を返します。
- **パラメータ**:
  - `soqlQuery` (String): 実行する SOQL クエリ文字列。
- **戻り値**: `List<SObject>` - クエリ結果のリスト。

### getObjectisInformation
- **説明**: 指定されたオブジェクトの

### getAllObjects

**機能**：すべてのアクセス可能なカスタムおよび標準オブジェクトの情報を取得します。

**パラメータ**：
- `List<String>  objectNames`：オオブジェクト名。


**戻り値**：オブジェクトラベルをキーとし、オブジェクト情報（名前とラベル）のリストを値とするマップを返します。

### searchObjectsLike

**機能**：単一の名詞を受け取り、Schema.getGlobalDescribe() が返す key で like モードでの検索を行う

**パラメータ**：
- `String searchKeyword`：検索キーワード。


**戻り値**：マッチしたオブジェクト情報の Map。