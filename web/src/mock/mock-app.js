// import { getUsersByPageSize } from './mockdata/user';

export default {
    'get /mock/app/koolproxy': (config) => {
        return new Promise((resolve) => {
            setTimeout(() => {
                resolve([200, {
                    desc: '净网工具koolproxy',
                    enabled: true,
                    status: '运行中',
                    statusBool: true,
                    mode: 'video',
                    certUrl: 'http://110.110.110.110'
                }]);
            }, 1000);
        });
    },
    'get /mock/app/general/koolproxy': (config) => {
        return new Promise((resolve) => {
            setTimeout(() => {
                resolve([200, {
                    desc: '净网工具koolproxy',
                    enabled: true,
                    status: '运行中',
                    statusBool: true,
                    mode: 'black',
                    certUrl: 'http://110.110.110.110'
                }]);
            }, 1000);
        });
    },
    'get /mock/app/general/koolproxy/form': (config) => {
        return new Promise((resolve) => {
            setTimeout(() => {
                resolve([200, [
                    {
                        'type': 'select',
                        'label': '运行模式',
                        'name': 'mode',
                        'options': [
                            { 'label': '黑名单', 'value': 'black' },
                            { 'label': '白名单', 'value': 'white' }
                        ]
                    },
                    {
                        'type': 'hyperlink',
                        'label': '证书下载',
                        'url': 'http://110.110.110.110'
                    }
                ]]);
            }, 1000);
        });
    },
    'post /mock/app/general/koolproxy': (config) => {
        console.log(config)
        return new Promise((resolve) => {
            setTimeout(() => {
                resolve([200, {
                    desc: '净网工具koolproxy',
                    enabled: true,
                    status: '启动失败',
                    statusBool: false,
                    mode: 'black',
                    certUrl: 'http://110.110.110.110'
                }]);
            }, 1000);
        });
    },
    'get /mock/app/list': (config) => {
        return new Promise((resolve) => {
            setTimeout(() => {
                resolve([200, [
                    {
                        key: 'ads',
                        text: '广告过滤',
                        icon: 'align-left',
                        order: 1000
                    },
                    {
                        key: 'koolproxy',
                        parentKey: 'ads',
                        text: 'KoolProxy',
                        icon: 'lock',
                        path: '/app/general/koolproxy',
                        order: 1001
                    }
                ]]);
            }, 1000);
        });
    }
    // 'delete re:/mock/users/.+': true,
}
