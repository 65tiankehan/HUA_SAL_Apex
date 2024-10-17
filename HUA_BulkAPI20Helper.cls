/**
 * 
 * 
 * @author HUA_JI_WU_NIAN 
 * @created 2024-00-00
 * @lastModifiedBy HUA_JI_WU_NIAN 
 * @lastModifiedDate 2024-00-00
 * @version 1.0.0
 * @testClass Test_HUA_BulkAPI20Helper
 * @description 
 * 本クラスは、SalesforceのBulk API 2.0を使用して、大量のデータを効率的に処理するためのユーティリティ機能を提供します。
 * 各メソッドは、ジョブの作成、データのアップロード、ジョブの状態の設定とチェック、成功したレコードの取得などの操作をサポートします。
 * 
 * 
 * @class HUA_BulkAPI20Helper - Bulk API 2.0操作ユーティリティクラス
 */
//https://developer.salesforce.com/docs/atlas.en-us.api_asynch.meta/api_asynch/bulk_common_diff_two_versions.htm
public without sharing class HUA_BulkAPI20Helper {
    private static final String BASE_URL = URL.getOrgDomainURL().toExternalForm() + '/services/data/v62.0/jobs/ingest/';
    private static final String AUTH_TOKEN = 'Bearer ' + UserInfo.getSessionId();

    /**
     * Bulk API 2.0のジョブを作成する
     * @param objectTypeName オブジェクトのタイプ名
     * @param operation 実行する操作（例: insert, update）
     * @return 作成されたジョブのID
     */
    public static String createJob(String objectTypeName, String operation) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL);
        req.setMethod('POST');
        req.setHeader('Authorization', AUTH_TOKEN);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('X-PrettyPrint', '1');

        String jobJson = '{"object" : "' + objectTypeName + '", "contentType" : "CSV", "operation" : "' + operation + '", "lineEnding" : "LF"}';
        req.setBody(jobJson);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) response.get('id');
        } else {
            System.debug('Error creating job: ' + res.getBody());
            return null;
        }
    }

    /**
     * CSVデータをアップロードする
     * @param jobId ジョブのID
     * @param csvData アップロードするCSVデータ
     */
    public static void uploadData(String jobId, String csvData) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + jobId + '/batches/');
        req.setMethod('PUT');
        req.setHeader('Authorization', AUTH_TOKEN);
        req.setHeader('Content-Type', 'text/csv');
        req.setHeader('Accept', 'application/json');
        req.setHeader('X-PrettyPrint', '1');
        req.setBody(csvData);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            System.debug('Error uploading data: ' + res.getBody());
        }
    }

    /**
     * ジョブの状態を「アップロード完了」に設定する
     * @param jobId ジョブのID
     */
    public static void setJobStateToUploadComplete(String jobId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + jobId);
        req.setMethod('PATCH');
        req.setHeader('Authorization', AUTH_TOKEN);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setHeader('Accept', 'application/json');
        req.setHeader('X-PrettyPrint', '1');
        req.setBody('{"state" : "UploadComplete"}');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            System.debug('Error setting job state to UploadComplete: ' + res.getBody());
        }
    }

    /**
     * ジョブの状態をチェックする
     * @param jobId ジョブのID
     * @return ジョブの状態情報
     */
    public static Map<String, Object> checkJobStatus(String jobId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + jobId);
        req.setMethod('GET');
        req.setHeader('Authorization', AUTH_TOKEN);
        req.setHeader('Accept', 'application/json');
        req.setHeader('X-PrettyPrint', '1');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            return (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        } else {
            System.debug('Error checking job status: ' + res.getBody());
            return null;
        }
    }

    /**
     * 成功したレコードを取得する
     * @param jobId ジョブのID
     * @return 成功したレコードのCSVデータ
     */
    public static String getSuccessfulResults(String jobId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + jobId + '/successfulResults/');
        req.setMethod('GET');
        req.setHeader('Authorization', AUTH_TOKEN);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'text/csv');
        req.setHeader('X-PrettyPrint', '1');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            return res.getBody();
        } else {
            System.debug('Error getting successful results: ' + res.getBody());
            return null;
        }
    }

    /**
     * メインメソッド、上記のメソッドを呼び出して一括挿入を実行する
     // サンプルデータ
    Map<String, List<String>> accountData = new Map<String, List<String>> {
        'Name' => new List<String> { 'Lorem Ipsum', 'Posuere Inc', 'Angeles Urban', 'Madaline Neubert Shoes', 'Times Online UK', 'The Washington Post', 'Amazon' },
        'ShippingCity' => new List<String> { 'Milano', 'Bodø', 'Aykol', 'Xukou', 'Varadero', 'Hengdaohezi', 'Quintães' },
        'NumberOfEmployees' => new List<String> { '2676', '141603', '197724', '190305', '121802', '190944', '80285' },
        'AnnualRevenue' => new List<String> { '912260031', '896852810', '257060529', '71664061', '58284123', '164329406', '684173825' },
        'Website' => new List<String> { 'https://ft.com/lacus/at.jsp', 'http://webs.com/in/faucibus/orci/luctus/et/ultrices/posuere.json', 'http://odnoklassniki.ru/sapien.aspx', 'https://blogs.com/faucibus/orci/luctus/et/ultrices/posuere/cubilia.json', 'http://timesonline.co.uk/eu/magna.html', 'http://washingtonpost.com/vestibulum/proin/eu/mi/nulla/ac/enim.png', 'http://amazon.co.uk/potenti/cras/in/purus/eu.png' },
        'Description' => new List<String> { 'Lorem ipsum dolor sit amet', 'consectetur adipiscing elit', 'sed do eiusmod tempor incididunt ut labore et dolore magna aliqua', 'Ut enim ad minim veniam', 'quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat', 'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur', 'Excepteur sint occaecat cupidatat non proident' }
    };

    // 一括挿入メソッドの呼び出し
    HUA_BulkAPI20Helper.performBulkInsert(accountData, 'Account', 'insert');
     * @param dataMap CSVデータを含むMap
     * @param objectTypeName オブジェクトのタイプ名
     * @param operation 実行する操作（例: insert, update）
     */
    public static void performBulkInsert(Map<String, List<String>> dataMap, String objectTypeName, String operation) {
        // MapをCSV文字列に変換する
        String csvData = convertMapToCsv(dataMap);

        // ジョブを作成する
        String jobId = createJob(objectTypeName, operation);
        if (jobId == null) {
            System.debug('Failed to create job.');
            return;
        }

        // データをアップロードする
        uploadData(jobId, csvData);

        // ジョブの状態を「アップロード完了」に設定する
        setJobStateToUploadComplete(jobId);

        // // ジョブの状態をチェックする
        // Map<String, Object> jobStatus = checkJobStatus(jobId);
        // while ((String) jobStatus.get('state') != 'JobComplete') {
        //     System.debug('Job is still processing...');
        //     jobStatus = checkJobStatus(jobId);
        // }

        // // 成功したレコードを取得する
        // String successfulResults = getSuccessfulResults(jobId);
        // System.debug('Successful results: ' + successfulResults);
    }

    /**
     * MapをCSV文字列に変換する
     * @param dataMap CSVデータを含むMap
     * @return CSV文字列
     */
    private static String convertMapToCsv(Map<String, List<String>> dataMap) {
        List<String> headers = new List<String>(dataMap.keySet());
        List<List<String>> rows = new List<List<String>>();

        // 表頭を追加する
        rows.add(headers);

        // データ行を追加する
        Integer rowCount = dataMap.values().iterator().next().size();
        for (Integer i = 0; i < rowCount; i++) {
            List<String> row = new List<String>();
            for (String header : headers) {
                row.add(dataMap.get(header)[i]);
            }
            rows.add(row);
        }

        // CSV文字列に変換する
        String csv = '';
        for (List<String> row : rows) {
            csv += String.join(row, ',') + '\n';
        }
        return csv;
    }
    
    /**
     * バッチ削除操作を実行する
     // サンプルレコードIDリスト
    List<String> accountIdsToDelete = new List<String> {
        '001XXXXXXXXXXXXXXX1',
        '001XXXXXXXXXXXXXXX2',
        '001XXXXXXXXXXXXXXX3'
    };

    // 一括削除メソッドの呼び出し
    HUA_BulkAPI20Helper.performBulkDelete(accountIdsToDelete, 'Account');
     * @param recordIds 削除対象のレコードIDリスト
     * @param objectTypeName オブジェクトタイプ名
     */
    public static void performBulkDelete(List<String> recordIds, String objectTypeName) {
        // 削除ジョブを作成する
        String jobId = createJob(objectTypeName, 'delete');
        if (jobId == null) {
            System.debug('ジョブの作成に失敗しました。');
            return;
        }

        // レコードIDリストをCSV文字列に変換する
        String csvData = convertListToCsv(recordIds);

        // データをアップロードする
        uploadData(jobId, csvData);

        // ジョブの状態を「アップロード完了」に設定する
        setJobStateToUploadComplete(jobId);

        // ジョブの状態を確認する
        Map<String, Object> jobStatus = checkJobStatus(jobId);
        while ((String) jobStatus.get('state') != 'JobComplete') {
            System.debug('ジョブはまだ処理中です...');
            jobStatus = checkJobStatus(jobId);
        }

        // 削除結果を取得する
        String successfulResults = getSuccessfulResults(jobId);
        System.debug('成功した結果: ' + successfulResults);
    }

    /**
     * レコードIDリストをCSV文字列に変換する
     * @param recordIds レコードIDリスト
     * @return CSV文字列
     */
    private static String convertListToCsv(List<String> recordIds) {
        return String.join(recordIds, '\n');
    }
}