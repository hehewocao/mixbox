import React, {useState, useEffect} from 'react';
import {Form, Tabs, Input, Button, Spin} from 'antd';
import { QueryBar } from 'src/library/components';
import config from 'src/commons/config-hoc';
import PageContent from 'src/layouts/page-content';
import {useGet} from 'src/commons/ajax';
import Basic from './basic';
const TabPane = Tabs.TabPane;
const TextArea = Input.TextArea;

export default config({
    path: '/app/general/:name',
    ajax: true,
})((props) => {

    const {name} = props.match.params;
    const [data, setData] = useState({});
    // 表单字段数据
    const [formData, setFormData] = useState([]);
    const [log, setLog] = useState("");
    const [form] = Form.useForm();
    const [loading, getData] = useGet(`/api/mixbox?action=get_app_config&appname=${name}`);
    const [saving, saveData] = useGet(`/api/mixbox?action=save_app_config&appname=${name}`, {successTip: '保存成功！'});
    const [formLoading, getForm] = useGet(`/api/mixbox?action=get_app_form&appname=${name}`);
    const [logLoading, getLog] = useGet(`/api/mixbox?action=get_log&appname=${name}`);

    useEffect(() => {
        fetchData();
        fetchForm();
        fetchLog();
    }, [name]);

    async function fetchLog() {
        const res = await getLog()
        setLog(res)
    }

    async function fetchData() {

        if (loading) return;
        const res = await getData();
        // 不处理null，下拉框不显示placeholder
        // Object.entries(res).forEach(([key, value]) => {
        //     if (value === null) res[key] = undefined;
        // });
        setFieldsValue(res)

    }

    async function fetchForm() {
        if (formLoading) return;
        const res = await getForm();
        setFormData(res || [])
    }

    async function submit(values) {
        const res = await saveData({ data: { ...data, ...values } });
        setFieldsValue(res)
        fetchLog()
    }

    function setFieldsValue(res) {
        setData(res || {});
        form.setFieldsValue(res || {});
    }

    const formProps = {
        labelWidth: '100',
        width: '100%',
        elementStyle: { width: '50%', marginLeft: '15%' },
    };
    const pageLoading = loading || saving || formLoading;

    return (
        <PageContent>
            <QueryBar>
                <h3 style={{ marginLeft: 10 }}>{data.service}</h3>
                <p style={{ marginLeft: 10 }}>{data.appinfo}</p>
            </QueryBar>
            <Tabs defaultActiveKey="basic">
                <TabPane key="basic" tab="基础设置">
                    <Basic
                        data={data}
                        loading={pageLoading}
                        formProps={formProps}
                        submit={submit}
                        form={form}
                        formData={formData} />
                </TabPane>
                <TabPane key="log" tab="日志">
                    <Button type="primary" onClick={fetchLog}>刷新</Button>
                    {logLoading ? <Spin /> :<TextArea style={{ height: 500, marginTop: 10 }} value={log} />}
                </TabPane>
            </Tabs>
        </PageContent>
    );
});
