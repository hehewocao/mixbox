import React, {useState, useEffect} from 'react';
import {Button, Col, Form, Input, Row, Tabs, Spin} from 'antd';
import PageContent from 'src/layouts/page-content';
import {useGet} from 'src/commons/ajax';
import config from 'src/commons/config-hoc';
import {notification} from 'antd';
import {
    QueryBar,
    FormRow,
    FormElement,
    Table,
    Operator,
    Pagination,
} from 'src/library/components';
const TabPane = Tabs.TabPane;
const TextArea = Input.TextArea;

export default config({
    path: '/',
    ajax: true,
})((props) => {

    const [loading, getApplist] = useGet(`/api/mixbox?action=get_applist`);
    const [watchLoading,setWatch] = useGet(`/api/mixbox?action=set_watch`, { error: '设置守护进程失败！' });
    const [installLoading,installApp] = useGet(`/api/mixbox?action=install_app`, {successTip: '插件安装成功！刷新页面后可见！'});
    const [uninstallLoading,uninstallApp] = useGet(`/api/mixbox?action=uninstall_app`);
    const [logLoading, getLog] = useGet(`/api/mixbox?action=get_log&appname=mixbox`);

    const [log, setLog] = useState("");
    const [searchKey, setSearchKey] = useState("");
    const [applist, setApplist] = useState([]);
    const [selectedRowKeys, setSelectedRowKeys] = useState([]);
    const [columns, ] = useState([
        {
            title: '是否安装',
            dataIndex: 'installStatus', width: 100,
            render: value => value
                ? <span style={{ color: 'green' }}>已安装</span>
                : <span style={{ color: 'red' }}>未安装</span>
        },
        { title: '名称', dataIndex: 'service', width: 100 },
        { title: '介绍', dataIndex: 'appinfo', width: 200 },
        { title: '版本', dataIndex: 'version', width: 50 },
        { title: '最新版本', dataIndex: 'newver', width: 50 },
        { title: '更新信息', dataIndex: 'newinfo', width: 200 },
        { title: '工具箱版本', dataIndex: 'needver', width: 60 },
        {
            title: '进程守护',
            dataIndex: 'watchStatus',
            width: 60,
            render: value => value
                ? <span style={{ color: 'green' }}>已启用</span>
                : <span style={{ color: 'red' }}>未启用</span>
        },
    ]);


    useEffect(() => {
        fetchApplist();
        fetchLog();
    }, []);

    async function fetchApplist(e) {
        setSearchKey("")
        setSelectedRowKeys([])
        let res = await getApplist()
        const list = e ? res.applist.filter(i => i.appname.match(e)) : res.applist
        setApplist(list)
    }

    async function fetchLog() {
        const res = await getLog()
        setLog(res)
    }

    async function handleInstall() {
        setSelectedRowKeys([])
        const res = await installApp({appnames: selectedRowKeys.join(",")});
        setApplist(res.applist)
    }

    async function handleUninstall() {
        setSelectedRowKeys([])
        const res = await uninstallApp({appnames: selectedRowKeys.join(",")});
        setApplist(res.applist)
    }

    async function handleWatch() {
        setSelectedRowKeys([])
        const res = await setWatch({appnames: selectedRowKeys.join(",")})
        setApplist(res.applist)
    }

    const pageLoading = loading || logLoading || installLoading || uninstallLoading || watchLoading;

    return (
        <PageContent loading={pageLoading}>
            <QueryBar style={{ paddingLeft: 10 }}>
                <h3>MIXBOX</h3>
                <p>集成了多种插件的工具箱</p>
            </QueryBar>
            <QueryBar style={{ paddingLeft: 10, paddingRight: 10, paddingBottom: 8 }}>
                <Row>
                    <Col span={18}>
                        <Button disabled={selectedRowKeys.length === 0} onClick={handleInstall} style={{ marginRight: 10 }} type="primary">安装</Button>
                        <Button disabled={selectedRowKeys.length === 0} onClick={handleUninstall} style={{ marginRight: 10 }} type="danger">卸载</Button>
                        <Button disabled={selectedRowKeys.length === 0} onClick={handleWatch} style={{ marginRight: 10 }}>进程守护</Button>
                    </Col>
                    <Col span={6}>
                        <Input.Search enterButton value={searchKey} onChange={e => setSearchKey(e.target.value)} onSearch={fetchApplist} />
                    </Col>
                </Row>

            </QueryBar>
            <Tabs defaultActiveKey="appcenter">
                <TabPane key="appcenter" tab="插件中心">
                    <Table
                        rowSelection={{
                            selectedRowKeys,
                            onChange: selectedRowKeys =>  setSelectedRowKeys(selectedRowKeys),
                        }}
                        // loading={loading}
                        columns={columns}
                        dataSource={applist}
                        rowKey="appname"
                        // serialNumber
                    />
                </TabPane>
                <TabPane key="log" tab="日志">
                    <Button type="primary" onClick={(fetchLog)}>刷新</Button>
                    {logLoading ? <Spin /> :<TextArea style={{ height: 500, marginTop: 10 }} value={log} />}
                </TabPane>
            </Tabs>
        </PageContent>
    );
});
