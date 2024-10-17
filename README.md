# HUA_Meta_tool.cls 文档
    作者 ：HUA_JI_WU_NIAN
    创建时间：2024年10月17日
    更新时间：2024年10月17日
    出发点：在 Salesforce 中，我们经常需要处理对象和字段，例如更新字段值、获取字段信息、处理审批流程等。为了简化这一过程，我们可以使用这个工具类。
## 目录

- [简介](#简介)
- [方法列表](#方法列表)
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

## 简介

`HUA_Meta_tool.cls` 是一个 Salesforce Apex 类，提供了多种静态方法来操作和管理 Salesforce 中的对象和字段。这些方法涵盖了从更新对象字段、获取字段信息、到处理审批流程和用户密码管理等多个方面。

## 方法列表

### updateObjects

**功能**：更新指定 SObject 的字段值。

**参数**：
- `SObject Objects`：要更新的 SObject。
- `Map<String, Object> fieldMaps`：字段名及其新值的映射。

**返回**：更新后的 SObject。

### getAllFieldNames

**功能**：获取指定对象类型的全部字段名。

**参数**：
- `String objectName`：要获取字段名的对象名称。

**返回**：包含指定对象所有字段名的字符串列表。

### clearingObjectProperties

**功能**：清除指定 SObject 的特定字段值。

**参数**：
- `SObject masterObj`：要清除字段值的 SObject。
- `List<String> fields`：要清除值的字段名列表。

**返回**：特定字段值被清除后的 SObject。

### createOjbects

**功能**：使用指定的对象类型和字段映射创建新的 SObject。

**参数**：
- `String objectTypeName`：要创建的对象类型名称。
- `Map<String, Object> fieldMaps`：字段名及其值的映射。

**返回**：新创建的 SObject 对象或 null。

### mergeObjects

**功能**：合并两个 Salesforce 对象。

**参数**：
- `SObject masterObj`：更新目标对象。
- `SObject mergeObj`：值来源对象。

**返回**：合并后的 SObject。

### handleException

**功能**：处理异常并记录详细信息。

**参数**：
- `Exception e`：发生的异常。

### flexibleConfigurationObjectInfo

**功能**：使用灵活配置更新 Salesforce 对象。

**参数**：
- `String strJson`：表示要更新字段的 JSON 字符串。
- `Id id`：要更新的对象 ID。

### getPicklistValues

**功能**：获取指定 SObject 和字段的 picklist 值。

**参数**：
- `String sObjectName`：SObject 名称。
- `String sFieldName`：字段名称。

**返回**：包含 picklist 值的映射。

### getApprovalHistory

**功能**：获取指定记录 ID 的审批历史。

**参数**：
- `Id recordId`：目标记录 ID。
- `Map<String, String> statusParams`：状态参数映射。

**返回**：包含审批历史信息的列表。

### submitApprovalWorkitems

**功能**：提交指定记录 ID 的审批工作项。

**参数**：
- `Id recordId`：目标记录 ID。
- `String status`：审批状态（例如：'Approve', 'Reject'）。
- `String message`：审批时的评论。
- `Id nextApproverId`：下一个审批者的 ID。

**返回**：处理是否成功的布尔值。

### isLockedObjects

**功能**：检查指定对象 ID 列表中的对象是否被锁定。

**参数**：
- `Map<Id, Object> params`：对象 ID 和对象的映射。

**返回**：包含每个对象是否被锁定的结果映射。

### fetchRecordLayout

**功能**：获取指定对象和记录类型 ID 的布局信息。

**参数**：
- `String objectName`：对象名称。
- `String recordTypeId`：记录类型 ID。

**返回**：包含布局信息的映射。

### updateUserPassword

**功能**：使用指定用户 ID 设置用户的密码。

**参数**：
- `String userId`：用户 ID。
- `String newPassword`：新密码。

**返回**：更新是否成功的布尔值。

### resetUserPassword

**功能**：使用指定用户 ID 重置用户的密码。

**参数**：
- `String userId`：用户 ID。

**返回**：重置是否成功的布尔值。

### describeListView

**功能**：使用指定对象和查询定位器获取列表视图的详细信息。

**参数**：
- `String sObjectName`：对象名称。
- `String queryLocator`：查询定位器。

**返回**：包含列表视图详细信息的映射。

### fetchListViewResults

**功能**：使用指定对象和列表视图 ID 获取列表视图的结果。

**参数**：
- `String sObjectName`：对象名称。
- `String listViewId`：列表视图 ID。
- `Integer limit`：最大返回记录数（1-2000）。默认为 25。
- `Integer offset`：返回的第一条记录。此参数用于对结果进行分页。默认为 0。

**返回**：包含列表视图结果的映射。