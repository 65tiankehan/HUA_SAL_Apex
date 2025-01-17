const axios = require('axios');

/**
 * 获取 Salesforce 的访问令牌
 * @param {string} clientId - 客户端 ID
 * @param {string} clientSecret - 客户端密钥
 * @param {string} username - 用户名
 * @param {string} password - 密码
 * @returns {Promise<string>} - 访问令牌
 */
async function getToken(clientId, clientSecret, username, password) {
    // 参数验证
    if (!clientId || !clientSecret || !username || !password) {
        console.error('Error: 必须的参数不足。');
        return null;
    }

    // 构建请求体
    const requestBody = new URLSearchParams({
        grant_type: 'password',
        client_id: clientId,
        client_secret: clientSecret,
        username: username,
        password: password
    });

    // 构建请求选项
    const options = {
        method: 'POST',
        url: 'https://login.salesforce.com/services/oauth2/token', // 或者使用沙盒环境的 URL
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        data: requestBody.toString()
    };

    try {
        // 发送 HTTP 请求
        const response = await axios(options);

        // 处理响应
        if (response.status === 200) {
            return response.data.access_token;
        } else {
            console.error('Error: ' + response.status + ' - ' + response.statusText);
            return null;
        }
    } catch (error) {
        console.error('Error: ' + error.message);
        if (error.response) {
            console.error('Response Body: ' + JSON.stringify(error.response.data));
        }
        return null;
    }
}

// 示例调用
(async () => {

    const clientId = '3MVG9GCMQoQ6rpzQI0GePgNq4tZvcJQu_Zqj9U3Cnde9sts5FqlwqTzsyswEDw.daNNmUmPVAFGj3FAQWbdfI';
    const clientSecret = '42FEFF2FE174E10F4DCF7EF0B8EAF7F5970EADA03F9C9CD1503465565940E2BC';
    const username = 'huajiwunian@huawuji.cn';
    const password = 'Tgnhuanwet4324#%@5KzDompg53Mkunl6F0vFJ6KLj3';

    const token = await getToken(clientId, clientSecret, username, password);
    if (token) {
        console.log('Access Token: ' + token);
    } else {
        console.log('Failed to get access token.');
    }
})();