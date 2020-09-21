import React, {useState, useEffect} from 'react';
import {Form, Tabs} from 'antd';
import { QueryBar } from 'src/library/components';
import config from 'src/commons/config-hoc';
import PageContent from 'src/layouts/page-content';
import {useGet, usePost} from 'src/commons/ajax';
import Appcenter from './appcenter';
import Installed from './installed';
const TabPane = Tabs.TabPane;

export default config({
    path: '/',
    ajax: true,
})((props) => {


    const pageLoading = false;

    return (
        <PageContent>
            <QueryBar style={{ paddingLeft: 10 }}>
                <h3>MIXBOX</h3>
                <p>集成了多种插件的工具箱</p>
            </QueryBar>
            <Tabs defaultActiveKey="installed">
                <TabPane key="installed" tab="已安装">
                    <Installed />
                </TabPane>
                <TabPane key="appcenter" tab="插件中心">
                    <Appcenter />
                </TabPane>
            </Tabs>
        </PageContent>
    );
});
