/**
 * 
 * 
 * @author HUA_JI_WU_NIAN 
 * @created 2024-00-00
 * @lastModifiedBy HUA_JI_WU_NIAN 
 * @lastModifiedDate 2024-00-00
 * @version 1.0.0
 * @testClass Test_HUA_FileProcessor
 * @description 
 * 本クラスは、CSVファイルを処理し、指定された操作タイプに応じてデータの挿入、更新、または削除を行うためのユーティリティ機能を提供します。
 * 各メソッドは、CSVファイルの解析、データの変換、Bulk API 2.0を使用したデータのアップロード、ジョブの管理などをサポートします。
 * 
 * 
// CSVファイルを処理し、挿入操作を実行する
HUA_FileProcessor.processCSVFile(csvFile, 'Account', 'insert');

// CSVファイルを処理し、更新操作を実行する
HUA_FileProcessor.processCSVFile(csvFile, 'Account', 'update');

// CSVファイルを処理し、削除操作を実行する
HUA_FileProcessor.processCSVFile(csvFile, 'Account', 'delete');
 * @class HUA_FileProcessor - CSVファイル処理ユーティリティクラス
 */
public without sharing class HUA_FileProcessor {
    // 組織ドメインURLとAPIエンドポイントのベースURL
    private static final String BASE_URL = URL.getOrgDomainURL().toExternalForm() + '/services/data/v62.0/jobs/ingest/';
    // 認証トークン
    private static final String AUTH_TOKEN = 'Bearer ' + UserInfo.getSessionId();

    /**
     * CSVファイルを処理し、操作タイプに応じて挿入、更新、または削除操作を実行する
     * @param csvFile CSVファイルの内容
     * @param objectTypeName オブジェクトタイプ名
     * @param operationType 操作タイプ（'insert', 'update', 'delete'）
     */
    public static void processCSVFile(Blob csvFile, String objectTypeName, String operationType) {
        // Blobを文字列に変換する
        String csvContent = csvFile.toString();

        // CSVファイルを解析する
        List<List<String>> parsedData = parseCSV(csvContent);

        // 操作タイプに応じて適切な操作を実行する
        if (operationType == 'insert') {
            performBulkInsert(parsedData, objectTypeName);
        } else if (operationType == 'update') {
            performBulkUpdate(parsedData, objectTypeName);
        } else if (operationType == 'delete') {
            performBulkDelete(parsedData, objectTypeName);
        } else {
            System.debug('サポートされていない操作タイプ: ' + operationType);
        }
    }

    /**
     * CSV内容を解析する
     * @param csvContent CSVファイルの内容
     * @return 解析後の二次元文字列リスト
     */
    private static List<List<String>> parseCSV(String csvContent) {
        List<List<String>> result = new List<List<String>>();
        for (String line : csvContent.split('\n')) {
            if (!String.isEmpty(line.trim())) {
                result.add(line.split(','));
            }
        }
        return result;
    }

    /**
     * 批量插入操作を実行する
     * @param data 解析後のデータ
     * @param objectTypeName オブジェクトタイプ名
     */
    private static void performBulkInsert(List<List<String>> data, String objectTypeName) {
        // 挿入ジョブを作成する
        String jobId = HUA_BulkAPI20Helper.createJob(objectTypeName, 'insert');
        if (jobId == null) {
            System.debug('ジョブの作成に失敗しました。');
            return;
        }

        // データをCSV文字列に変換する
        String csvData = convertListToCsv(data);

        // データをアップロードする
        HUA_BulkAPI20Helper.uploadData(jobId, csvData);

        // ジョブの状態を「アップロード完了」に設定する
        HUA_BulkAPI20Helper.setJobStateToUploadComplete(jobId);

        // ジョブの状態を確認する
        Map<String, Object> jobStatus = HUA_BulkAPI20Helper.checkJobStatus(jobId);
        while ((String) jobStatus.get('state') != 'JobComplete') {
            System.debug('ジョブはまだ処理中です...');
            jobStatus = HUA_BulkAPI20Helper.checkJobStatus(jobId);
        }

        // 挿入結果を取得する
        String successfulResults = HUA_BulkAPI20Helper.getSuccessfulResults(jobId);
        System.debug('成功した結果: ' + successfulResults);
    }

    /**
     * 批量更新操作を実行する
     * @param data 解析後のデータ
     * @param objectTypeName オブジェクトタイプ名
     */
    private static void performBulkUpdate(List<List<String>> data, String objectTypeName) {
        // 更新ジョブを作成する
        String jobId = HUA_BulkAPI20Helper.createJob(objectTypeName, 'update');
        if (jobId == null) {
            System.debug('ジョブの作成に失敗しました。');
            return;
        }

        // データをCSV文字列に変換する
        String csvData = convertListToCsv(data);

        // データをアップロードする
        HUA_BulkAPI20Helper.uploadData(jobId, csvData);

        // ジョブの状態を「アップロード完了」に設定する
        HUA_BulkAPI20Helper.setJobStateToUploadComplete(jobId);

        // ジョブの状態を確認する
        Map<String, Object> jobStatus = HUA_BulkAPI20Helper.checkJobStatus(jobId);
        while ((String) jobStatus.get('state') != 'JobComplete') {
            System.debug('ジョブはまだ処理中です...');
            jobStatus = HUA_BulkAPI20Helper.checkJobStatus(jobId);
        }

        // 更新結果を取得する
        String successfulResults = HUA_BulkAPI20Helper.getSuccessfulResults(jobId);
        System.debug('成功した結果: ' + successfulResults);
    }

    /**
     * 批量删除操作を実行する
     * @param data 解析後のデータ
     * @param objectTypeName オブジェクトタイプ名
     */
    private static void performBulkDelete(List<List<String>> data, String objectTypeName) {
        // レコードIDリストを抽出する
        List<String> recordIds = new List<String>();
        for (List<String> row : data) {
            if (!row.isEmpty()) {
                recordIds.add(row[0]);
            }
        }

        // 批量删除操作を実行する
        HUA_BulkAPI20Helper.performBulkDelete(recordIds, objectTypeName);
    }

    /**
     * 二次元文字列リストをCSV文字列に変換する
     * @param data 二次元文字列リスト
     * @return CSV文字列
     */
    private static String convertListToCsv(List<List<String>> data) {
        List<String> lines = new List<String>();
        for (List<String> row : data) {
            lines.add(String.join(row, ','));
        }
        return String.join(lines, '\n');
    }
}