import React, {useState, useEffect} from 'react';
import {Form, Tabs} from 'antd';
import { QueryBar } from 'src/library/components';
import config from 'src/commons/config-hoc';
import PageContent from 'src/layouts/page-content';
import {useGet, usePost} from 'src/commons/ajax';
import Basic from './basic';
const TabPane = Tabs.TabPane;

export default config({
    title: 'KoolProxy',
    path: '/app/koolproxy',
    ajax: true,
})(() => {

    const [data, setData] = useState({});
    const [form] = Form.useForm();
    const [loading, fetchKoolproxy] = useGet('/mock/app/koolproxy');
    const [saving, saveKoolproxy] = usePost('/mock/app/koolproxy', {successTip: '保存成功！'});

    useEffect(() => {
        fetchData();
    }, []);

    async function fetchData() {

        if (loading) return;
        const res = await fetchKoolproxy();
        // 不处理null，下拉框不显示placeholder
        // Object.entries(res).forEach(([key, value]) => {
        //     if (value === null) res[key] = undefined;
        // });
        setFieldsValue(res)

    }

    async function submit(values) {

        const res = await saveKoolproxy(values);
        setFieldsValue(res)

    }

    function setFieldsValue(res) {
        setData(res || {});
        form.setFieldsValue(res || {});
    }

    const formProps = {
        labelWidth: '100',
        width: '100%',
        elementStyle: { width: '40%', marginLeft: '20%' },
    };
    const pageLoading = loading || saving;

    return (
        <PageContent loading={pageLoading}>
            <QueryBar>
                <h3 style={{ marginLeft: 10 }}>{data.desc}</h3>
            </QueryBar>
            <Tabs defaultActiveKey="basic">
                <TabPane key="basic" tab="基础设置">
                    <Basic data={data} formProps={formProps} submit={submit} form={form} />
                </TabPane>
                <TabPane key="log" tab="日志">
                    <div />
                </TabPane>
            </Tabs>
        </PageContent>
    );
});
