/**
 * 
 * 
 * @author HUA_JI_WU_NIAN 
 * @created 2024-00-00
 * @lastModifiedBy HUA_JI_WU_NIAN 
 * @lastModifiedDate 2024-00-00
 * @version 1.0.0
 * @testClass Test_HUA_Meta_tool
 * @description 
 * 本クラスは、指定されたオブジェクトタイプの情報を取得および操作するためのユーティリティ機能を提供します。
 * 各メソッドは、オブジェクトタイプの詳細情報を取得したり、フィールド情報を操作したりするのに役立ちます。
 * さらに、フィールドの更新、クリア、新規作成、マージなどもサポートします。
 * 
 * @class HUA_Meta_tool - オブジェクトタイプのメタデータ操作ユーティリティクラス
 */
//https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_schema.htm
public without sharing class HUA_Meta_tool {

    /**
    * HUA_Meta_tool.cls
    *
    * 指定されたオブジェクトタイプとパラメータを使って、データを取得する関数。
    *
    * @param objectTypeName 取得したいオブジェクトタイプ名
    * @param params 取得に使用するパラメータ
    * @param conditions 取得に使用する条件
    * @return 指定された条件でデータを取得できれば結果のリストを返す。パラメータや条件が空またはオブジェクトタイプが存在しない場合は null を返す
    */
    public static List<SObject> getAnyQuery(String objectTypeName,Map<String,Object> params,Map<String,Object> conditions) {
        try{
            
            // パラメータとコンディションが空またはオブジェクトタイプが存在しない場合、null を返す
            if (params == null || params.isEmpty() || !Schema.getGlobalDescribe().containsKey(objectTypeName)) {
                return null;
            }
           
             Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectTypeName);
             Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();

             Set<String> copyableFields = new Set<String>();

            // フィールド情報を取得
             for (String fieldName : params.keySet()) {
                if (fieldMap.containsKey(fieldName) && fieldMap.get(fieldName).getDescribe().isAccessible()) {
                    copyableFields.add(fieldName);
                }
             }
             
            // クエリを作成
            String fields = String.join(new List<String>(copyableFields), ', ');
            String query = 'SELECT ' + fields + ' FROM ' + objectTypeName;
            
             if(conditions != null && !conditions.isEmpty()) {
                 query += ' WHERE ';
                 for(String key : conditions.keySet()) {
                     query += key + ' ' + conditions.get(key) +' ' + params.get(key) + ' AND ';
                 }
                 query = query.removeEnd(' AND ');
             }
             System.debug('query: ' + query);
             return Database.query(query);
             
            
        }catch(Exception e) {
            handleException(e);
        }
        
        return null; // 例外が発生した場合、null を返す
    }

    /**
    * HUA_Meta_tool.cls
    *
    * 指定されたオブジェクトタイプが現在のユーザーによってアクセスできるかどうかを確認する関数。
    *
    * @param objectTypeName アクセス可能なオブジェクトタイプ名
    * @return 指定されたオブジェクトタイプがアクセス可能な場合は true、そうでない場合は false、存在しない場合は null を返す
    */
    public static Map<String, object> getObjectisInformation(String objectTypeName) {
        Map<String, object> Objectinformation = new Map<String, object>(); 
        
        try {
            // 全ての SObject の情報を取得
            Map<String, Schema.SObjectType> sObjectDescribeMap = Schema.getGlobalDescribe();

            // 指定されたオブジェクトタイプが存在しない場合は null を返す
            if (!sObjectDescribeMap.containsKey(objectTypeName)) {
                return null;
            }
            
            // 指定されたオブジェクトタイプの情報を取得
            Schema.SObjectType sObjectType = sObjectDescribeMap.get(objectTypeName);
            

            // オブジェクトタイプの名前を取得して格納
            Objectinformation.put('getLabel',
                new Map<String, Object>{'value' => sObjectType.getDescribe().getLabel(), 
                'describe' => 'オブジェクトタイプの名前を返します。'});

            // 現在のユーザーがこのオブジェクトを見ることができるかどうかをチェック
            Objectinformation.put('isAccessible',
                new Map<String, Object>{'value' => sObjectType.getDescribe().isAccessible(), 
                'describe' => '現在のユーザーがこのオブジェクトを見ることができるかどうかを返します。見ることができない場合は false を返します。'});

            // 現在のユーザーがこのオブジェクトを作成できるかどうかをチェック
            Objectinformation.put('isCreateable',
                new Map<String, Object>{'value' => sObjectType.getDescribe().isCreateable(), 
                'describe' => '現在のユーザーがこのオブジェクトを作成できるかどうかを返します。作成できない場合は false を返します。'});

            // オブジェクトがカスタムオブジェクトかどうかをチェック
            Objectinformation.put('isCustom',
                new Map<String, Object>{'value' => sObjectType.getDescribe().isCustom(), 
                'describe' => 'オブジェクトがカスタムオブジェクトの場合、true を返し、標準オブジェクトの場合は false を返します。'});

            // オブジェクトがカスタム設定かどうかをチェック
            Objectinformation.put('isCustomSetting',
                new Map<String, Object>{'value' => sObjectType.getDescribe().isCustomSetting(), 
                'describe' => 'オブジェクトがカスタム設定の場合、true を返し、それ以外の場合は false を返します。'});

            // 現在のユーザーがこのオブジェクトを削除できるかどうかをチェック
            Objectinformation.put('isDeletable',
                new Map<String, Object>{'value' => sObjectType.getDescribe().isDeletable(), 
                'describe' => '現在のユーザーがこのオブジェクトを削除できるかどうかを返します。削除できない場合は false を返します。'});

            // 現在のユーザーがこのオブジェクトを問い合わせることができるかどうかをチェック
            Objectinformation.put('isQueryable',
                new Map<String, Object>{'value' => sObjectType.getDescribe().isQueryable(), 
                'describe' => '現在のユーザーがこのオブジェクトを問い合わせることができる場合は、true を返します。そうでない場合は false を返します。'});

            // 現在のユーザーがこのオブジェクトを検索できるかどうかをチェック
            Objectinformation.put('isSearchable',
                new Map<String, Object>{'value' => sObjectType.getDescribe().isSearchable(), 
                'describe' => '現在のユーザーがこのオブジェクトを検索できる場合は、true を返します。そうでない場合は false を返します。'});

            // 現在のユーザーがこのオブジェクトの削除を取り消すことができるかどうかをチェック
            Objectinformation.put('isUndeletable',
                new Map<String, Object>{'value' => sObjectType.getDescribe().isUndeletable(), 
                'describe' => '現在のユーザーがこのオブジェクトの削除を取り消すことができる場合は、true を返します。そうでない場合は false を返します。'});

            // 現在のユーザーがこのオブジェクトを更新できるかどうかをチェック
            Objectinformation.put('isUpdateable',
                new Map<String, Object>{'value' => sObjectType.getDescribe().isUpdateable(), 
                'describe' => '現在のユーザーがこのオブジェクトを更新できるかどうかを返します。更新できない場合は false を返します。'});
        } catch (Exception e) {
            handleException(e);
        }
        return Objectinformation;
    }

    /**
    * HUA_Meta_tool.cls
    *
    * この関数は、指定されたオブジェクトタイプとフィールド名のフィールド情報を取得します。オブジェクトタイプ名とフィールド名を受け取り、
    * そのフィールドのさまざまな属性を含むマップを返します。
    *
    * @param objectTypeName - フィールド情報を取得したいオブジェクトタイプ名
    * @param sFieldName - フィールド情報を取得したいフィールド名
    * @return Map<String, Object> - フィールド属性情報のマップ
    */
    public static Map<String, object> getFieldInformation(String objectTypeName,String sFieldName) {
        Map<String, object> fieldinformation = new Map<String, object>(); 

        try {
            // 全てのSObjectの情報を取得
            Map<String, Schema.SObjectType> sObjectDescribeMap = Schema.getGlobalDescribe();
            
            // 指定されたオブジェクトタイプが存在しない場合はnullを返す
            if (!sObjectDescribeMap.containsKey(objectTypeName)) {
                return null;
            }
            
            // 指定されたオブジェクトタイプの情報を取得
            Schema.SObjectType sObjectType = sObjectDescribeMap.get(objectTypeName);
            
            // 指定されたフィールド名の情報を取得
            Schema.SObjectField sObjectField = sObjectType.getDescribe().fields.getMap().get(sFieldName);
            
            // フィールドのラベル情報を追加
            fieldInformation.put('label', 
                new Map<String, Object>{'value' => sObjectField.getDescribe().getLabel(), 
                'describe' => 'Salesforceユーザーインタフェースのフィールドの横に表示されるテキストラベルを返します。このラベルはローカライズできます。'});
            
            // フィールドがカスタムフィールドかどうかを追加
            fieldInformation.put('Custom', 
                new Map<String, Object>{'value' => sObjectField.getDescribe().isCustom(),
                'describe' => 'フィールドがカスタムフィールドの場合は、Nameなどの標準フィールドを返します。'});
            
            // 現在のユーザーがこのフィールドを見ることができるかどうかを追加
            fieldInformation.put('isAccessible',
                new Map<String, Object>{'value' => sObjectField.getDescribe().isAccessible(), 
                'describe' => '現在のユーザーがこのフィールドを見ることができる場合は、trueを返します。'});
            
            // アインシュタインの予測データを表示するために現在のフィールドが有効になっているかどうかを追加
            fieldInformation.put('isAiPredictionField', 
                new Map<String, Object>{'value' => sObjectField.getDescribe().isAiPredictionField(), 
                'describe' => 'アインシュタインの予測データを表示するために現在のフィールドが有効になっている場合は、trueを返します。'});
            
            // フィールドが自動番号フィールドかどうかを追加
            fieldInformation.put('isAutoNumber',
                new Map<String, Object>{'value' => sObjectField.getDescribe().isAutoNumber(), 
                'describe' => 'フィールドが自動番号フィールドの場合はtrueを返し、そうでない場合はfalseを返します。'});
            
            // フィールドがカスタム式フィールドかどうかを追加
            fieldInformation.put('isCalculated', 
                new Map<String, Object>{'value' => sObjectField.getDescribe().isCalculated(), 
                'describe' => 'フィールドがカスタム式フィールドの場合はtrueを返し、そうでない場合はfalseを返します。カスタム式フィールドは常に読み取り専用であることに注意してください。'});
            
            // 親オブジェクトを削除するときに子オブジェクトが削除されるかどうかを追加
            fieldInformation.put('isCascadeDelete',
                new Map<String, Object>{'value' => sObjectField.getDescribe().isCascadeDelete(), 
                'describe' => '親オブジェクトを削除するときに子オブジェクトが削除された場合はtrueを返し、そうでない場合はfalseを返します。'});
            
            // フィールドに大文字と小文字が区別されているかどうかを追加
            fieldInformation.put('isCaseSensitive',
                new Map<String, Object>{'value' => sObjectField.getDescribe().isCaseSensitive(), 
                'describe' => 'フィールドに大文字と小文字が区別されている場合はtrueを返し、そうでない場合はfalseを返します。'});
            
            // 現在のユーザーがフィールドを作成できるかどうかを追加
            fieldInformation.put('isCreateable',
                new Map<String, Object>{'value' => sObjectField.getDescribe().isCreateable(), 
                'describe' => '現在のユーザーがフィールドを作成できるかどうかを返します。'});
            
            // フィールドが作成時にデフォルト値を受信したかどうかを追加
            fieldInformation.put('isDefaultedOnCreate',
                new Map<String, Object>{'value' => sObjectField.getDescribe().isDefaultedOnCreate(), 
                'describe' => 'フィールドが作成時にデフォルト値を受信した場合はtrueを返し、そうでない場合はfalseを返します。'});
            
            // 選択リストが依存選択リストであるかどうかを追加
            fieldInformation.put('isDependentPicklist',
                new Map<String, Object>{'value' => sObjectField.getDescribe().isDependentPicklist(), 
                'describe' => '選択リストが依存選択リストである場合はtrueを返し、そうでない場合はfalseを返します。'});
            
            // 将来の使用のために予約されているかどうかを追加
            fieldInformation.put('isDeprecatedAndHidden', 
                new Map<String, Object>{'value' => sObjectField.getDescribe().isDeprecatedAndHidden(), 
                'describe' => '将来の使用のために予約しています。'});
            
            // フィールドがShield Platform Encryption暗号化を使用しているかどうかを追加
            fieldInformation.put('isEncrypted',
                new Map<String, Object>{'value' => sObjectField.getDescribe().isEncrypted(), 
                'describe' => 'フィールドがShield Platform Encryption暗号化を使用している場合はtrueを返し、そうでない場合はfalseを返します。'});
            
            // フィールドが外部IDとして使用されているかどうかを追加
            fieldInformation.put('isExternalID',
                new Map<String, Object>{'value' => sObjectField.getDescribe().isExternalID(), 
                'describe' => 'フィールドが外部IDとして使用されている場合はtrueを返し、そうでない場合はfalseを返します。'});
            
            // このフィールドが文フィルタ条件の一部として使用できるかどうかを追加
            fieldInformation.put('isFilterable',
                new Map<String, Object>{'value' => sObjectField.getDescribe().isFilterable(), 
                'describe' => 'このフィールドが文フィルタ条件の一部として使用できる場合はtrueを返し、そうでない場合はfalseを返します。'});
            
            // 式フィールドでゼロとみなされているかどうかを追加
            fieldInformation.put('isFormulaTreatNullNumberAsZero', 
                new Map<String, Object>{'value' => sObjectField.getDescribe().isFormulaTreatNullNumberAsZero(), 
                'describe' => '式フィールドでゼロとみなされている場合はtrueを返し、そうでない場合はfalseを返します。'});
            
            // フィールドがグループ化可能かどうかを追加
            fieldInformation.put('isGroupable', 
                new Map<String, Object>{'value' => sObjectField.getDescribe().isGroupable(), 
                'describe' => 'フィールドがグループ化可能であればtrueを返し、そうでない場合はfalseを返します。'});
            
            // フィールドがHTML形式にフォーマットされているかどうかを追加
            fieldInformation.put('isHtmlFormatted',
                new Map<String, Object>{'value' => sObjectField.getDescribe().isHtmlFormatted(),
                'describe' => 'フィールドがHTML形式にフォーマットされているかどうかを返します。'});
            
            // このフィールドを使用してレコードを指定できるかどうかを追加
            fieldInformation.put('isIdLookup', 
                new Map<String, Object>{'value' => sObjectField.getDescribe().isIdLookup(),
                'describe' => 'このフィールドを使用してレコードを指定できる場合はtrueを返し、そうでない場合はfalseを返します。'});
            
            // フィールドが名前フィールドかどうかを追加
            fieldInformation.put('isNameField', 
                new Map<String, Object>{'value' => sObjectField.getDescribe().isNameField(), 
                'describe' => 'フィールドが名前フィールドの場合はtrueを返し、そうでない場合はfalseを返します。'});
            
            // フィールドが空かどうかを追加
            fieldinformation.put('isNillable', 
                new Map<String, object>{'value' => sObjectField.getDescribe().isNillable(),
                'describe' => 'フィールドが空の場合は戻り、そうでない場合は戻ります。nillableフィールドには空きコンテンツがあります。オブジェクトを作成または保存するには、非nillableフィールドに値が必要です。'});
        
        // 指定されたフィールドにフィールドレベルのアクセス権限を設定できるかどうかをチェック
            fieldinformation.put('isPermissionable', 
                new Map<String, Object>{'value' => sObjectField.getDescribe().isPermissionable(), 
                'describe' => 'フィールドにフィールドレベルのアクセス権限を設定できる場合はtrueを返します。そうでない場合はfalseを返します。'});

            // 親オブジェクトが削除されたときに参照されている子オブジェクトが削除できないかどうかをチェック
            fieldinformation.put('isRestrictedDelete', 
                new Map<String, Object>{'value' => sObjectField.getDescribe().isRestrictedDelete(), 
                'describe' => '親オブジェクトが削除されたときに参照されている子オブジェクトが削除できない場合はtrueを返します。そうでない場合はfalseを返します。'});

            // フィールドが制限付き選択リストかどうかをチェック
            fieldinformation.put('isRestrictedPicklist', 
                new Map<String, Object>{'value' => sObjectField.getDescribe().isRestrictedPicklist(), 
                'describe' => 'フィールドが制限付き選択リストの場合はtrueを返します。そうでない場合はfalseを返します。'});

            // SOSL検索文でフィールドを使用するとき、外部キーを事前フィルタに含めることができるかどうかをチェック
            fieldinformation.put('isSearchPrefilterable', 
                new Map<String, Object>{'value' => sObjectField.getDescribe().isSearchPrefilterable(), 
                'describe' => 'SOSL検索文で使用するとき、外部キーを事前フィルタに含めることができる場合はtrueを返します。そうでない場合はfalseを返します。'});

            // フィールドをクエリ結果のソートに使用できるかどうかをチェック
            fieldinformation.put('isSortable', 
                new Map<String, Object>{'value' => sObjectField.getDescribe().isSortable(), 
                'describe' => 'クエリ結果のソートにフィールドを使用できる場合はtrueを返します。そうでない場合はfalseを返します。'});

            // フィールドの値が一意である必要があるかどうかをチェック
            fieldinformation.put('isUnique', 
                new Map<String, Object>{'value' => sObjectField.getDescribe().isUnique(), 
                'describe' => 'フィールドの値が一意である必要がある場合はtrueを返します。そうでない場合はfalseを返します。'});

            // 現在のユーザーがフィールドを更新できるかどうかをチェック
            fieldinformation.put('isUpdateable', 
                new Map<String, Object>{'value' => sObjectField.getDescribe().isUpdateable(), 
                'describe' => '現在のユーザーがフィールドを更新できるか、またはカスタムオブジェクトの主詳細関係フィールドの子レコードを別の親レコードに再割り当てできる場合はtrueを返します。それ以外の場合はfalseを返します。'});

            // 書き込み操作が親オブジェクトの読み取り共有を必要とするかどうかをチェック
            fieldinformation.put('isWriteRequiresMasterRead', 
                new Map<String, Object>{'value' => sObjectField.getDescribe().isWriteRequiresMasterRead(), 
                'describe' => '書き込み操作が親オブジェクトの読み取り共有を必要とする場合はtrueを返します。それ以外の場合はfalseを返します。'});
        } catch (Exception e) {
            handleException(e);
        }
        return fieldinformation;
    }
    /**
    * HUA_Meta_tool.cls
    *
    * この関数は、指定された SObject のフィールド値を更新するためのものです。SObject とフィールド名および新しい値のマップを受け取り、
    * フィールドを走査します。フィールドが存在し、かつ更新可能な場合、そのフィールドの新しい値を SObject に設定します。
    * 最後に更新後の SObject を返します。
    *
    * @param Objects - フィールド値を更新したい SObject
    * @param fieldMaps - フィールド名および新しい値のマップ
    * @return SObject - 更新後の SObject
    */
    public static SObject updateObjects(SObject Objects, Map<String, Object> fieldMaps) {
        try {
            for(String fieldName : fieldMaps.keySet()) {
                if (Objects.getSObjectType().getDescribe().fields.getMap().containsKey(fieldName) &&
                    Objects.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().isUpdateable()) {
                        Objects.put(fieldName, fieldMaps.get(fieldName));
                }
            }
        } catch (Exception e) {
            handleException(e);
        }
        return Objects;
    }
 

    /**
    * HUA_Meta_tool.cls
    *
    * この関数は、指定されたオブジェクトタイプのすべてのフィールド名を取得するためのものです。オブジェクト名を受け取り、
    * そのオブジェクトのすべてのフィールド名を含む文字列リストを返します。
    *
    * @param objectName - フィールド名を取得したいオブジェクト名
    * @return List<String> - 指定されたオブジェクトのすべてのフィールド名を含むリスト
    */
    public static List<String> getAllFieldNames(String objectName) {
        List<String> fieldNames = new List<String>();
        try {
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            for (Schema.SObjectField field : objectType.getDescribe().fields.getMap().values()) {
                fieldNames.add(field.getDescribe().getName());
            }
        } catch (Exception e) {
            handleException(e);
        }
        return fieldNames;
    }
    

    /**
    * HUA_Meta_tool.cls
    *
    * この関数は、指定された SObject の特定のフィールド値をクリアするためのものです。SObject とクリアするフィールド名のリストを受け取り、
    * これらのフィールドについて確認し、フィールドが存在し、かつ作成可能な場合にその値を null に設定します。
    * 条件がすべて満たされた場合、処理後の SObject を返します。条件が一致しない場合は変更せずに元のオブジェクトを返します。
    *
    * @param masterObj - フィールド値をクリアしたい SObject
    * @param fields - 値をクリアしたいフィールド名のリスト
    * @return SObject - 特定のフィールド値がクリアされた SObject
    */
    public static SObject clearingObjectProperties(SObject masterObj, List<String> fields) {
        try {
            for(String fieldName : fields) {
                if (masterObj.getSObjectType().getDescribe().fields.getMap().containsKey(fieldName) &&
                    masterObj.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().isCreateable()) {
                        masterObj.put(fieldName, null);
                }
            }
        } catch (Exception e) {
            handleException(e);
        }
        return masterObj;
    }
    /**
    * HUA_Meta_tool.cls
    *
    * このクラスは、指定されたオブジェクトタイプとフィールドマップを使用して新しい SObject を作成するためのメソッドを提供します。
    * 指定されたオブジェクトタイプが存在する場合、そのタイプの新しい SObject を作成し、フィールドマップから値を設定します。
    * ただし、フィールドが存在し、かつ作成可能である場合のみ値を設定します。
    * これらの条件が満たされない場合は null を返します。
    *
    * @param ojectTypeName - 作成するオブジェクトのタイプ名
    * @param fieldMaps - フィールド名とその値のマップ
    * @return SObject - 新しく作成された SObject オブジェクトまたは null
    */
    public static SObject createOjbects(String objectTypeName, Map<String, Object> fieldMaps) {
        // オブジェクトが存在するかどうかを確認する
        if (!Schema.getGlobalDescribe().containsKey(objectTypeName)) {
            return null;
        }

        // フィールドマップから、オブジェクトタイプに基づいて新しいオブジェクトを作成する
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectTypeName);
        SObject newObj = Schema.getGlobalDescribe().get(objectTypeName).newSObject();

        try {
            // フィールドマップからフィールドをフィルタリングする
            for (String fieldName : fieldMaps.keySet()) {
                if (objectType.getDescribe().fields.getMap().containsKey(fieldName) &&
                    objectType.getDescribe().fields.getMap().get(fieldName).getDescribe().isCreateable()) {
                    newObj.put(fieldName, fieldMaps.get(fieldName));
                }
            }
        } catch (Exception e) {
            handleException(e);
        }

        return newObj;
    }

    /**
    * HUA_Meta_tool.cls
    *
    * このクラスは、2 つの Salesforce オブジェクトをマージするためのメソッドを提供します。
    * `masterObj` は更新先のオブジェクトで、`mergeObj` はその値をコピーする元のオブジェクトです。
    * まず、2 つのオブジェクトが同じタイプであることを確認します。
    * 次に、オブジェクトのフィールド情報を取得し、更新可能なフィールドをフィルタリングします。
    * 最後に、更新可能なフィールドの値をコピーし、`masterObj` を更新します。
    * 成功とエラーメッセージは適切にログに記録されます。
    * プロセス中に発生した例外はキャッチされ、詳細情報がログに記録されます。
    *
    * @param masterObj - 更新先のオブジェクト
    * @param mergeObj - 値をコピーする元のオブジェクト
    */
    public static SObject mergeObjects(SObject masterObj, SObject mergeObj) {
        try {
            // 2つのオブジェクトが同じタイプであるかどうかを確認する
            if (masterObj.getSObjectType() != mergeObj.getSObjectType()) {
                System.debug('The two objects are not the same type.');
                return null;
            }

            // オブジェクトのフィールド情報を取得する
            Map<String, Schema.SObjectField> fieldMap = masterObj.getSObjectType().getDescribe().fields.getMap();
            Set<String> copyableFields = new Set<String>();

            // 更新可能なフィールドをフィルタリングする
            for (String fieldName : fieldMap.keySet()) {
                if (fieldMap.get(fieldName).getDescribe().isCreateable() || fieldMap.get(fieldName).getDescribe().isUpdateable()) {
                    copyableFields.add(fieldName);
                }
            }

            // mergeObj のフィールドを小文字に変換して、マップに格納する
            Map<String, Object> mergeFieldValues = new Map<String, Object>();
            for (String fieldName : mergeObj.getPopulatedFieldsAsMap().keySet()) {
                mergeFieldValues.put(fieldName.toLowerCase(), mergeObj.get(fieldName));
            }

            // マスターの値の置き換えを開始
            for (String fieldName : copyableFields) {
                if (mergeFieldValues.containsKey(fieldName.toLowerCase())) {
                    masterObj.put(fieldName, mergeFieldValues.get(fieldName.toLowerCase()));
                }
            }
        } catch (Exception e) {
            handleException(e);
        }
        return masterObj;
    }


    
    /**
    * 例外を処理する
    *
    * @param e - 発生した例外
    */
    private static void handleException(Exception e) {
        String errorMessage = 'An exception occurred: ' + e.getMessage() + '\n';
        errorMessage += 'Exception type: ' + e.getTypeName() + '\n';
        errorMessage += 'Exception line number: ' + e.getLineNumber() + '\n';
        errorMessage += 'Exception stack trace: ' + e.getStackTraceString();
        System.debug(errorMessage);
    }
     
    /**
     * HUA_Meta_tool.cls
     *
     * This class provides a method to update a Salesforce object with flexible configuration.
     * It takes a JSON string and an object ID as parameters.
     * The JSON string is validated and filtered before updating the object.
     * The object type is also validated before updating.
     * The fields to be updated are filtered based on the object's describe information.
     * The updated object is then saved using the Database.update method.
     * Success and error messages are logged accordingly.
     * Any exceptions that occur during the process are caught and detailed information is logged.
     *
     * @param strJson - JSON string representing the fields to be updated
     * @param id - ID of the object to be updated
     */
    public static void flexibleConfigurationObjectInfo(String strJson, Id id) {
        try {
            // validate_and_filter_the_input_json_string
            if (strJson == null || String.isEmpty(strJson)) {
                return;
            }
            Map<String, Object> fieldMap = (Map<String, Object>) JSON.deserializeUntyped(strJson);
            if (fieldMap == null) {
                return;
            }

            // validate_and_filter_the_input_s_object_type
            if (id == null || id.getSobjectType() == null || id.getSobjectType().getDescribe() == null || id.getSobjectType().getDescribe().getName() == null) {
                return;
            }
            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(id.getSobjectType().getDescribe().getName());
            if (objectType == null) {
                return;
            }

            SObject newObj = objectType.newSObject();

          
            // validate_and_filter_the_updated_fields
            for (String fieldName : fieldMap.keySet()) {
                
                if (objectType.getDescribe().fields.getMap().containsKey(fieldName) && objectType.getDescribe().fields.getMap().get(fieldName).getDescribe().isUpdateable()) {
                    
                    newObj.put(fieldName, fieldMap.get(fieldName));
                }
            }
            
            newObj.put('Id', id);
            
            Database.SaveResult updateResult = Database.update(newObj, false);

            if (updateResult.isSuccess()) {
                System.debug('object_update_success');
                // Add additional processing logic for successful updates
            } else {
                for (Database.Error error : updateResult.getErrors()) {
                    System.debug('the_object_update_failed_procedure: ' + error.getMessage());
                    // Add additional processing logic where updates were unsuccessful
                }
            }
        } catch (Exception e) {
            handleException(e);
        }
    }

    
   /**
    * HUA_Meta_tool.cls
    *
    * このクラスは、指定された SObject とフィールドのピックリスト値を取得するためのメソッドを提供します。
    * 指定された SObject とフィールドが存在する場合、そのピックリスト値をマップとして返します。
    * 存在しない場合はエラーメッセージを返します。
    * ピックリストの各エントリは値、アクティブフラグ、デフォルトフラグ、およびラベルを含むマップとして格納されます。
    *
    * @param sObjectName - SObject の名前
    * @param sFieldName - フィールドの名前
    * @return Map<String, object> - ピックリスト値のマップ
    */
    public static Map<String, object> getPicklistValues(String sObjectName, String sFieldName) {
        Map<String, object> picValues = new Map<String, object>(); // Initialize the map to store Picklist values.

        // Get a map of all global SObject types.
        Map<String, Schema.SObjectType> sObjectDescribeMap = Schema.getGlobalDescribe();

        if (sObjectDescribeMap.containsKey(sObjectName)) { // Check if the provided SObject exists.
            // Get a map of fields for the specified SObject.
            Map<String, Schema.SobjectField> sObjectFieldsMap = 
                    sObjectDescribeMap.get(sObjectName).getDescribe().fields.getMap();

            if (sObjectFieldsMap.containsKey(sFieldName)) { // Check if the specified field exists.
                // Get the describe result for the specified field.
                Schema.DescribeFieldResult sObjectFieldDescribe = sObjectFieldsMap.get(sFieldName).getDescribe();

                // Retrieve the list of Picklist entries for the field.
                List<Schema.PicklistEntry> lPickEntryList = sObjectFieldDescribe.getPicklistValues();

                // Iterate through each Picklist entry and add it to the map.
                for (Schema.PicklistEntry tPicklistEntry : lPickEntryList) {
                    picValues.put(tPicklistEntry.getValue(), new Map<String, object>{
                            'value' => tPicklistEntry.getValue(),
                            'isActive' => tPicklistEntry.isActive(),
                            'isDefaultValue' => tPicklistEntry.isDefaultValue(),
                            'label' => tPicklistEntry.getLabel()
                    });
                }
            } else {
                // エラーメッセージを返す
                picValues.put('error', 'Field does not exist.');
            }
        } else {
            // エラーメッセージを返す
            picValues.put('error', 'SObject does not exist.');
        }

        return picValues; // Return the map of Picklist values.
    }
    

  
    /**
     * HUA_Meta_tool.cls
     *
     * 承認履歴取得メソッド
     *
     * このメソッドは、指定されたレコードIDの承認履歴を取得し、リストとして返します。
     * 承認履歴には、プロセス定義名、作成日時、ステータス、アクター名、アクターIDなどの情報が含まれます。
     * Workitem と Step の両方の情報を取得し、それぞれの情報をマップとしてリストに追加します。
     *
     * @param recordId - 対象のレコードID
     * @param statusParams - ステータスのパラメータを含むマップ
     * @return List<Object> - 承認履歴情報のリスト
     */
    public static List<Object> getApprovalHistory(Id recordId, Map<String, String> statusParams) {

        // 承認履歴情報を格納するリストを初期化します。
        List<Object> processInstanceValues = new List<Object>();

        // ProcessInstance オブジェクトのクエリを実行し、指定されたレコードIDに関連する承認プロセスを取得します。
        List<ProcessInstance> processInstanceList = [
            SELECT ProcessDefinition.Name, Id, Status, TargetObjectId, TargetObject.Name, SubmittedById, SubmittedBy.Name, CreatedDate,
                (SELECT Id, Actor.Name, ActorId, OriginalActorId, OriginalActor.Name, ProcessInstanceId, CreatedDate FROM Workitems),
                (SELECT Id, Comments, Actor.Name, ActorId, CreatedDate, StepStatus, OriginalActorId, OriginalActor.Name FROM Steps ORDER BY CreatedDate DESC)
            FROM ProcessInstance
            WHERE TargetObjectId = :recordId
            ORDER BY CreatedDate DESC
        ];

        // 取得した各承認プロセスに対してループを実行します。
        for (ProcessInstance processInstanceTemporary : processInstanceList) {

            // 各承認プロセスのWorkitemに対してループを実行します。
            for (ProcessInstanceWorkitem workitem : processInstanceTemporary.Workitems) {
                // 承認履歴情報をマップに格納し、リストに追加します。
                processInstanceValues.add(new Map<String, Object> {
                    'recordId' => workitem.Id,
                    'LatestArticle' => true,
                    'ProcessDefinitionName' => processInstanceTemporary.ProcessDefinition.Name,
                    'CreatedDate' => processInstanceTemporary.Workitems[0].CreatedDate.format(),
                    'status' => statusParams.containsKey('workitemStatus') ? statusParams.get('workitemStatus') : '未承認',
                    'OriginalActorName' => processInstanceTemporary.Workitems[0].Actor.Name,
                    'OriginalActorId' => processInstanceTemporary.Workitems[0].ActorId
                });
            }

            // 各承認プロセスのStepに対してループを実行します。
            for (ProcessInstanceStep steps : processInstanceTemporary.Steps) {
                // 承認履歴情報をマップに格納し、リストに追加します。
                processInstanceValues.add(new Map<String, Object> {
                    'recordId' => steps.Id,
                    'LatestArticle' => false,
                    'ProcessDefinitionName' => processInstanceTemporary.ProcessDefinition.Name,
                    'CreatedDate' => steps.CreatedDate.format(),
                    'status' => statusParams.containsKey(steps.StepStatus) ? statusParams.get(steps.StepStatus) : steps.StepStatus,
                    'OriginalActorName' => steps.Actor.Name,
                    'OriginalActorId' => steps.ActorId
                });
            }
        }

        // 承認履歴情報のリストを返します。
        return processInstanceValues;
    }

    
    /**
     * HUA_Meta_tool.cls
     *
     * 承認ワークアイテムの提出メソッド
     *
     * このメソッドは、指定されたレコードIDの承認ワークアイテムを提出します。
     * ステータス、メッセージ、次の承認者のIDをパラメータとして受け取り、承認プロセスを進めるか否かを制御します。
     * 成功した場合は `true` を、失敗した場合は `false` を返します。
     *
     * @param recordId - 対象のレコードID
     * @param status - 承認ステータス（例: 'Approve', 'Reject'）
     * @param message - 承認時のコメント
     * @param nextApproverId - 次の承認者のID
     * @return Boolean - 処理が成功したかどうか
     */
    public static Boolean submitApprovalWorkitems(Id recordId, String status, String message, Id nextApproverId) {
        
        try {
            
            // ステータスが空の場合、処理を終了して `false` を返します。
            if(String.isEmpty(status)) 
                return false;
            

            // 指定されたレコードIDに関連する承認プロセスを取得します。
            List<ProcessInstance> processInstanceList = [
                SELECT ProcessDefinition.Name, Id, Status, TargetObjectId, TargetObject.Name, SubmittedById, SubmittedBy.Name, CreatedDate,
                    (SELECT Id, Actor.Name, ActorId, OriginalActorId, OriginalActor.Name, ProcessInstanceId, CreatedDate FROM Workitems),
                    (SELECT Id, Comments, Actor.Name, ActorId, CreatedDate, StepStatus, OriginalActorId, OriginalActor.Name FROM Steps ORDER BY CreatedDate DESC)
                FROM ProcessInstance
                WHERE TargetObjectId = :recordId
                ORDER BY CreatedDate DESC
            ];
            
            // 最新のワークアイテムIDを取得します。
            String workItemId = '';

            for (ProcessInstance processInstanceTemporary : processInstanceList) {
                for (ProcessInstanceWorkitem workitem : processInstanceTemporary.Workitems) {
                    workItemId = workitem.Id;
                }
            }

            // ワークアイテムIDが空の場合、処理を終了して `false` を返します。
            if(String.isEmpty(workItemId))
                return false;
            
            // 承認ワークアイテムリクエストを作成します。
            Approval.ProcessWorkitemRequest approvalProcessRequest = new Approval.ProcessWorkitemRequest(); 
            approvalProcessRequest.setComments(String.isEmpty(message) ? '' : message); // コメントを設定します。
            approvalProcessRequest.setAction(status); // アクション（承認/却下）を設定します。
            approvalProcessRequest.setNextApproverIds(nextApproverId != null ? new Id[] {nextApproverId} : new Id[] {UserInfo.getUserId()}); // 次の承認者を設定します。
            approvalProcessRequest.setWorkitemId(workItemId); // ワークアイテムIDを設定します。
            Approval.process(approvalProcessRequest); // 承認プロセスを実行します。
            
            // 成功した場合、`true` を返します。
            return true;
        } catch (Exception e) {
            // 例外が発生した場合、例外ハンドリングを行います。
            handleException(e);
        }
        
        // 例外が発生した場合や他のエラーが発生した場合は `false` を返します。
        return false;
    }

    
    /**
     * HUA_Meta_tool.cls
     *
     * オブジェクトがロックされているかどうかを確認するメソッド
     *
     * このメソッドは、指定されたオブジェクトIDのリストに対して、各オブジェクトがロックされているかどうかを確認し、結果をマップとして返します。
     * マップのキーはオブジェクト自体、値はそのオブジェクトがロックされているかどうかのブーリアン値です。
     *
     * @param params - オブジェクトIDとオブジェクトのマップ
     * @return Map<Object, Boolean> - 各オブジェクトがロックされているかどうかの結果
     */
    public static Map<Object, Boolean> isLockedObjects(Map<Id, Object> params) {
        // 結果を格納するマップを初期化します。
        Map<Object, Boolean> result = new Map<Object, Boolean>();
        
        try {

            // 入力パラメータが空の場合、null を返します。
            if (params.isEmpty()) {
                return null;
            }
            
            // 各オブジェクトIDに対して、そのオブジェクトがロックされているかどうかを確認します。
            for (Id id : params.keySet()) {
                // オブジェクトがロックされているかどうかをチェックし、結果をマップに追加します。
                result.put(params.get(id), Approval.isLocked(id));
            }

        } catch (Exception e) {
            // 例外が発生した場合、例外ハンドリングを行います。
            handleException(e);
        }
        
        // 結果マップを返します。
        return result;
    }
    

   
     /**
     * HUA_Meta_tool.cls
     *
     * 指定されたオブジェクトとレコードタイプIDのレイアウト情報を取得する。
     * 
     * @param objectName オブジェクト名
     * @param recordTypeId レコードタイプID
     * @return レイアウト情報のマップ
     */
    public static Map<String, Object> fetchRecordLayout(String objectName, String recordTypeId) {
        
        // 現在のユーザーのセッションIDを取得
        String sessionId = UserInfo.getSessionId();
        
        // 現在のSalesforceインスタンスのURLを取得
        String instanceUrl = URL.getOrgDomainURL().toExternalForm();
        // REST APIエンドポイントを構築
        String endpoint = instanceUrl + '/services/data/v62.0/sobjects/' + objectName + '/describe/layouts/' + recordTypeId;
        
        // HTTPリクエストを構築
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        
        // HTTPリクエストを送信
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        // レスポンスを処理
        if (res.getStatusCode() == 200) {
            // レスポンスボディを未タイプのマップにデシリアライズ
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            
            // レイアウト情報を返す
            return responseMap;
        } else {
            // エラーメッセージをログに出力
            System.debug('Error: ' + res.getStatusCode() + ' - ' + res.getStatus());
        }
        
        // エラーまたはレイアウト情報が見つからない場合、nullを返す
        return null;
    }

    
     /**
     * HUA_Meta_tool.cls
     *
     * 指定されたユーザーIDを使用してユーザーのパスワードを設定する。
     * 
     * @param userId ユーザーID
     * @param newPassword 新しいパスワード
     * @return 更新が成功したかどうかのブール値
     */
    public static Boolean updateUserPassword(String userId, String newPassword) {
        // 現在のユーザーのセッションIDを取得
        String sessionId = UserInfo.getSessionId();
        
        // 現在のSalesforceインスタンスのURLを取得
        String instanceUrl = URL.getOrgDomainURL().toExternalForm();
        // REST APIエンドポイントを構築
        String endpoint = instanceUrl + '/services/data/v62.0/sobjects/User/' + userId + '/password';
        
        // パスワード更新用のJSONペイロードを作成
        Map<String, String> payload = new Map<String, String>();
        payload.put('NewPassword', newPassword);
        
        // JSONペイロードを文字列に変換
        String jsonPayload = JSON.serialize(payload);
        
        // HTTPリクエストを構築
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonPayload);
        
        // HTTPリクエストを送信
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        // レスポンスを処理
        if (res.getStatusCode() == 204) {
            // 204 No Content は成功を示す
            System.debug('Password updated successfully for user: ' + userId);
            return true;
        } else {
            // エラーメッセージをログに出力
            System.debug('Error updating password for user: ' + userId + ' - Status Code: ' + res.getStatusCode() + ' - Response Body: ' + res.getBody());
            return false;
        }
    }
    

     /**
     * HUA_Meta_tool.cls
     *
     * 指定されたユーザーIDを使用してユーザーのパスワードをリセットする。
     * 
     * @param userId ユーザーID
     * @return リセットが成功したかどうかのブール値
     */
    public static Boolean resetUserPassword(String userId) {
        // 現在のユーザーのセッションIDを取得
        String sessionId = UserInfo.getSessionId();
        
        // 現在のSalesforceインスタンスのURLを取得
        String instanceUrl = URL.getOrgDomainURL().toExternalForm();
        // REST APIエンドポイントを構築
        String endpoint = instanceUrl + '/services/data/v62.0/sobjects/User/' + userId + '/password';
        
        // HTTPリクエストを構築
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('DELETE');
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        
        // HTTPリクエストを送信
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        // レスポンスを処理
        if (res.getStatusCode() == 204) {
            // 204 No Content は成功を示す
            System.debug('Password reset successfully for user: ' + userId);
            return true;
        } else {
            // エラーメッセージをログに出力
            System.debug('Error resetting password for user: ' + userId + ' - Status Code: ' + res.getStatusCode() + ' - Response Body: ' + res.getBody());
            return false;
        }
    }
    

     /**
     * HUA_Meta_tool.cls
     *
     * 指定されたオブジェクトとクエリロケータを使用してリストビューの詳細情報を取得する。
     * 
     * @param sObjectName オブジェクト名
     * @param queryLocator クエリロケータ
     * @return リストビューの詳細情報のマップ
     */
    public static Map<String, Object> describeListView(String sObjectName, String queryLocator) {
        // 現在のユーザーのセッションIDを取得
        String sessionId = UserInfo.getSessionId();
        
        // 現在のSalesforceインスタンスのURLを取得
        String instanceUrl = URL.getOrgDomainURL().toExternalForm();
        // REST APIエンドポイントを構築
        String endpoint = instanceUrl + '/services/data/v62.0/sobjects/' + sObjectName + '/listviews/' + queryLocator + '/describe';
        
        // HTTPリクエストを構築
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        
        // HTTPリクエストを送信
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        // レスポンスを処理
        if (res.getStatusCode() == 200) {
            // レスポンスボディを未タイプのマップにデシリアライズ
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            
            // リストビューの詳細情報を返す
            return responseMap;
        } else {
            // エラーメッセージをログに出力
            System.debug('Error describing list view for object: ' + sObjectName + ' and query locator: ' + queryLocator + ' - Status Code: ' + res.getStatusCode() + ' - Response Body: ' + res.getBody());
            return null;
        }
    }
    
    /**
     * HUA_Meta_tool.cls
     *
     * 指定されたオブジェクトとリストビューIDを使用してリストビューの結果を取得する。
     * 
     * @param sObjectName オブジェクト名
     * @param listViewId リストビューID
     * @param limit 最大返却レコード数（1-2000）。デフォルトは25
     * @param offset 返却する最初のレコード。このパラメータを使用して結果をページングします。デフォルトは0
     * @return リストビューの結果のマップ
     */
    public static Map<String, Object> fetchListViewResults(String sObjectName, String listViewId, Integer limitOne, Integer offsetEnd) {
        // 現在のユーザーのセッションIDを取得
        String sessionId = UserInfo.getSessionId();
        
        // 現在のSalesforceインスタンスのURLを取得
        String instanceUrl = URL.getOrgDomainURL().toExternalForm();
        // REST APIエンドポイントを構築
        String endpoint = instanceUrl + '/services/data/v62.0/sobjects/' + sObjectName + '/listviews/' + listViewId + '/results?limit=' + limitOne + '&offset=' + offsetEnd;
        
        // HTTPリクエストを構築
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + sessionId);
        
        // HTTPリクエストを送信
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        // レスポンスを処理
        if (res.getStatusCode() == 200) {
            // レスポンスボディを未タイプのマップにデシリアライズ
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            
            // リストビューの結果を返す
            return responseMap;
        } else {
            // エラーメッセージをログに出力
            System.debug('Error fetching list view results for object: ' + sObjectName + ' and list view ID: ' + listViewId + ' - Status Code: ' + res.getStatusCode() + ' - Response Body: ' + res.getBody());
            return null;
        }
    }

    
    /**
     * HUA_Meta_tool.cls
     *
     * すべてのアクセス可能なカスタムおよび標準オブジェクトの情報を取得します。
     * 
     * @return オブジェクトラベルをキーとし、オブジェクト情報（名前とラベル）のリストを値とするマップを返します。
     */
    public static Map<String, List<Object>> getAllObjects(List<String> objectNames) {
        try {
            // グローバルオブジェクトの説明を取得
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            // オブジェクト情報を格納するマップを初期化
            Map<String, List<Object>> objectInfos = new Map<String, List<Object>>();
    
            // すべてのオブジェクトをループ処理
            for (String objectName : globalDescribe.keySet()) {
                
                if (objectNames != null && !objectNames.isEmpty() && !objectNames.contains(objectName)) {
                    continue;
                }
    
                Schema.SObjectType sObjectType = globalDescribe.get(objectName);
                Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
    
               
               
                // オブジェクトがアクセス可能かどうかチェック
                if (describeResult.isAccessible()) {
                    String label = describeResult.getLabel();
                    // 単一のオブジェクト情報を格納するマップを作成
                    Map<String, String> objectInfo = new Map<String, String>{
                        'label' => label,
                        'name' => sObjectType.getDescribe().getName()
                    };
    
                    // マップにそのラベルが存在しない場合、新しいリストを作成
                    if (!objectInfos.containsKey(label)) {
                        objectInfos.put(label, new List<Object>());
                    }
                    // 対応するラベルリストにオブジェクト情報を追加
                    objectInfos.get(label).add(objectInfo);
                }
            }
    
            // すべてのオブジェクト情報を含むマップを返す
            return objectInfos;
        } catch (Exception e) {
            // 处理异常，返回一个空的Map或默认的常用对象
            System.debug('Error in getAllObjects: ' + e.getMessage());
            return new Map<String, List<Object>>();
        }
    }

     /**
     * HUA_Meta_tool.cls
     *
     * 単一の名詞を受け取り、Schema.getGlobalDescribe() が返す key で like モードでの検索を行う
     * @param searchKeyword 検索キーワード
     * @return マッチしたオブジェクト情報の Map
     */
    public static Map<String, List<Object>> searchObjectsLike(String searchKeyword) {
        try {
            // グローバルオブジェクトの説明を取得
            Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
            // オブジェクト情報を格納する Map を初期化
            Map<String, List<Object>> objectInfos = new Map<String, List<Object>>();

            // すべてのオブジェクトをループ処理
            for (String objectName : globalDescribe.keySet()) {
                // オブジェクト名が検索キーワードを含むか確認
                if (objectName.toLowerCase().contains(searchKeyword.toLowerCase())) {
                    Schema.SObjectType sObjectType = globalDescribe.get(objectName);
                    Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();

                    // オブジェクトがアクセス可能かどうかチェック
                    if (describeResult.isAccessible()) {
                        String label = describeResult.getLabel();
                        // 単一のオブジェクト情報を格納する Map を作成
                        Map<String, String> objectInfo = new Map<String, String>{
                            'label' => label,
                            'name' => sObjectType.getDescribe().getName()
                        };

                        // Map にそのラベルが存在しない場合、新しいリストを作成
                        if (!objectInfos.containsKey(label)) {
                            objectInfos.put(label, new List<Object>());
                        }
                        // 対応するラベルリストにオブジェクト情報を追加
                        objectInfos.get(label).add(objectInfo);
                    }
                }
            }

            // すべてのマッチしたオブジェクト情報を含む Map を返す
            return objectInfos;
        } catch (Exception e) {
            // 例外を処理し、空の Map またはデフォルトの一般的なオブジェクトを返す
            System.debug('Error in searchObjectsLike: ' + e.getMessage());
            return new Map<String, List<Object>>();
        }
    }
}