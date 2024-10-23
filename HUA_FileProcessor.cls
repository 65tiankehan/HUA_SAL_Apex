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
 * @class HUA_FileProcessor - CSVファイル処理ユーティリティクラス
 */
public without sharing class HUA_FileProcessor {
   
    /**
     * CSVファイルを処理し、操作タイプに応じて挿入、更新、または削除操作を実行する
     * @param csvFile CSVファイルの内容
     * @param objectTypeName オブジェクトタイプ名
     * @param operationType 操作タイプ（'insert', 'update', 'delete'）
     */
    public static void processCSVFile(Blob csvFile, String objectTypeName, String operationType,String lineEnding) {
      
        
        // Blobを文字列に変換する
        String csvContent = csvFile.toString();

        // CSVファイルを解析する
        List<List<String>> parsedData = parseCSV(csvContent);
        
        
        // 操作タイプに応じて適切な操作を実行する
        if (operationType == 'insert') {
            HUA_BulkAPI20Helper.performBulkInsert(convertListToMap(parsedData), objectTypeName, 'insert',lineEnding);
        } else if (operationType == 'update') {
            HUA_BulkAPI20Helper.performBulkInsert(convertListToMap(parsedData), objectTypeName, 'update',lineEnding);
        } else if (operationType == 'delete') {
            HUA_BulkAPI20Helper.performBulkDelete(extractRecordIds(parsedData), objectTypeName,lineEnding);
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
     * 二次元文字列リストをMapに変換する
     * @param data 二次元文字列リスト
     * @return Map
     */
    private static Map<String, List<String>> convertListToMap(List<List<String>> data) {
        Map<String, List<String>> mapData = new Map<String, List<String>>();
        List<String> headers = data[0];
        for (Integer i = 1; i < data.size(); i++) {
            List<String> row = data[i];
            for (Integer j = 0; j < headers.size(); j++) {
                String header = headers[j];
                String value = row[j];
                if (!mapData.containsKey(header)) {
                    mapData.put(header, new List<String>());
                }
                mapData.get(header).add(value);
            }
        }
        return mapData;
    }

    /**
     * 二次元文字列リストからレコードIDリストを抽出する
     * @param data 二次元文字列リスト
     * @return レコードIDリスト
     */
    private static List<String> extractRecordIds(List<List<String>> data) {
        List<String> recordIds = new List<String>();
        for (List<String> row : data) {
            if (!row.isEmpty()) {
                recordIds.add(row[0]);
            }
        }
        return recordIds;
    }
}