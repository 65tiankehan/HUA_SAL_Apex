import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import processCSVFile from '@salesforce/apex/HUA_FileProcessorService.processCSVFile';
import getAllObjects from '@salesforce/apex/HUA_FileProcessorService.getAllObjects';
import getSeatchObjects from '@salesforce/apex/HUA_FileProcessorService.getSeatchObjects';

export default class CsvUploader extends LightningElement {
    @track file; // アップロードされたファイル
    @track isUploadButtonDisabled = true; // アップロードボタンの無効化状態
    @track objectTypeName = ''; // オブジェクトタイプ名
    @track operationType = ''; // 操作タイプ（挿入、更新、削除）
    @track lineEnding = 'LF'; // 行終端のデフォルト値（LF）
    @track objectTypeOptions = []; // オブジェクトタイプの選択肢
    @track operationTypeOptions = [ // 操作タイプの選択肢
        { label: '挿入', value: 'insert' },
        { label: '更新', value: 'update' },
        { label: '削除', value: 'delete' },
        // 他の操作タイプを追加
    ];
    @track lineEndingOptions = [ // 行終端の選択肢
        { label: 'LF', value: 'LF' },
        { label: 'CRLF', value: 'CRLF' }
    ];
    @track searchText = ''; 

    @wire(getAllObjects, { objectNames: ['account', 'contact'] })
    wiredObjects({ error, data }) {
        if (data) {
         
            this.objectTypeOptions = [];
            for (let label in data) {
                data[label].forEach(objectInfo => {
                    this.objectTypeOptions.push({
                        label: `${objectInfo.label} (${objectInfo.name})`, // ラベルと名前の表示
                        value: objectInfo.name
                    });
                });
            }
        } else if (error) {
            console.error('Error fetching objects:', error); // エラーメッセージ
        }
    }

    handleFileChange(event) {
        this.file = event.target.files[0]; // 選択されたファイルを取得
        if (this.file) {
            this.isUploadButtonDisabled = false; // ファイルが選択された場合、アップロードボタンを有効化
        } else {
            this.isUploadButtonDisabled = true; // ファイルが選択されていない場合、アップロードボタンを無効化
        }
    }

    handleObjectTypeChange(event) {
        this.objectTypeName = event.detail.value; // オブジェクトタイプの変更を処理
    }

    handleOperationTypeChange(event) {
        this.operationType = event.detail.value; // 操作タイプの変更を処理
    }

    handleLineEndingChange(event) {
        this.lineEnding = event.detail.value; // 行終端の変更を処理
    }

    handleSearchTextChange(event) {
        this.searchText = event.detail.value; 
    }

    handleSearchClick() {
        getSeatchObjects({ searchText: this.searchText })
            .then(result => {
             
                
                this.objectTypeOptions = [];
                for (let label in result) {
                    result[label].forEach(objectInfo => {
                        this.objectTypeOptions.push({
                            label: `${objectInfo.label} (${objectInfo.name})`, // ラベルと名前の表示
                            value: objectInfo.name
                        });
                    });
                }
                
            })
            .catch(error => {
                console.error('Error fetching objects:', error.message); 
                this.dispatchEvent(new ShowToastEvent({
                    title: '错误',
                    message: error.message, 
                    variant: 'error'
                }));
            });
    }
    
    async uploadFile() {
        if (!this.file || !this.objectTypeName || !this.operationType) {
            return; // 必要な情報が不足している場合は終了
        }

        const reader = new FileReader();
        reader.onloadend = async () => {
            const csvContent = reader.result; // CSV コンテンツを取得
          
            try {
                const parsedData = await this.parseCSV(csvContent); // CSV を解析
                
                const batches = this.chunkArray(parsedData.records, 5799); // レコードをバッチに分割

                

                for (let i = 0; i < batches.length; i++) {
                    const batch = batches[i];
                    const batchContent = this.generateCSV(batch, parsedData.headers); // バッチの CSV コンテンツを生成
                    const base64Content = btoa(batchContent); // CSV コンテンツを Base64 にエンコード

                   

                    await processCSVFile({ 
                        base64Content, 
                        objectTypeName: this.objectTypeName, 
                        operationType: this.operationType,
                        lineEnding: this.lineEnding 
                    }); // バッチを処理

                    this.dispatchEvent(new ShowToastEvent({
                        title: '成功',
                        message: `第${i + 1}バッチファイルのアップロードに成功しました`, // 成功メッセージ
                        variant: 'success'
                    }));
                }

                this.dispatchEvent(new ShowToastEvent({
                    title: '成功',
                    message: 'すべてのファイルのアップロードに成功しました', // 全てのファイルが成功したメッセージ
                    variant: 'success'
                }));
            } catch (error) {
                console.error('Error processing CSV:', error); // エラーメッセージ
                this.dispatchEvent(new ShowToastEvent({
                    title: '错误',
                    message: error.message, // エラーメッセージ
                    variant: 'error'
                }));
            }
        };
        reader.readAsText(this.file); // ファイルをテキストとして読み込む
    }

    parseCSV(csvContent) {
        const lines = csvContent.split(/\r\n|\n/).filter(line => line.trim() !== ''); // 行を分割し、空行をフィルタリング
        const headers = lines[0].split(','); // ヘッダー行を取得
        const records = lines.slice(1).map(line => {
            const values = line.split(','); // 各行の値を取得
            const record = {};

            for (let j = 0; j < values.length; j++) {
                record[headers[j]] = values[j]; // レコードを作成
            }

            return record;
        });

        return { headers, records }; // ヘッダーとレコードを返す
    }

    chunkArray(array, size) {
        const chunks = [];
        for (let i = 0; i < array.length; i += size) {
            chunks.push(array.slice(i, i + size)); // 配列を指定サイズで分割
        }
        return chunks; // 分割された配列を返す
    }

    generateCSV(records, headers) {
        const headerRow = headers.join(',') + '\n'; // ヘッダー行を生成
        const rows = records.map(record => Object.values(record).join(',')).join('\n'); // 各レコード行を生成
        return headerRow + rows; // ヘッダー行とレコード行を結合して CSV コンテンツを返す
    }
}