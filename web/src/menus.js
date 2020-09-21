import { ajax } from 'src/commons/ajax';
/*
* 菜单数据 返回Promise各式，支持前端硬编码、异步获取菜单数据
* */
export default function getMenus(userId) {
    return ajax.get('/api/mixbox?action=get_menu').then(res => {
        return (res.menu || []).map(item => ({ ...item }));
    });

    // // TODO 根据userId获取菜单数据 或在此文件中前端硬编码菜单
    // return Promise.resolve([
    //     { key: 'home', text: '首页', icon: 'ant-design', path: '/', order: 99999 },

    //     { key: 'antDesign', text: 'Ant Design 官网', icon: 'ant-design', url: 'https://ant-design.gitee.io', target: '', order: 2000 },
    //     { key: 'document', text: '文档', icon: 'book', url: 'http://shubin.wang/docs', target: '_blank', order: 1200 },

    //     { key: 'customer-header', text: '自定义头部', icon: 'api', path: '/example/customer-header', order: 998 },
    //     { key: 'user', text: '用户管理', icon: 'user', path: '/users', order: 900 },
    //     // {key: 'role', text: '角色管理', icon: 'lock', path: '/roles', order: 900},
    //     { key: 'menu', text: '菜单管理', icon: 'align-left', path: '/menu-permission', order: 900 },
    //     { key: 'gen', text: '代码生成', icon: 'code', path: '/gen', order: 900 },
    //     { key: 'koolproxy', text: 'KoolProxy', icon: 'lock', path: '/app/koolproxy', order: 1001 },
    //     { key: 'koolproxy-general', text: 'KoolProxyGeneral', icon: 'lock', path: '/app/general/koolproxy', order: 1002 },
    //     { key: 'page404', text: '404页面不存在', icon: 'file-search', path: '/404', order: 700 },
    //     { key: 'example', text: '示例', icon: 'align-left', order: 600 },
    //     { key: 'table-editable', parentKey: 'example', text: '可编辑表格', icon: 'align-left', path: '/example/table-editable', order: 600 },
    // ]);
}
