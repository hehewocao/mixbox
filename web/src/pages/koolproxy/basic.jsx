import React from 'react';
import {Form, Button, Col} from 'antd';
import {FormElement, FooterBar} from 'src/library/components';
import PageContent from 'src/layouts/page-content';

export default function (props) {

    const { submit, data, formProps, form } = props;

    return (
        <PageContent>
            <Form
                name="koolproxy-edit"
                form={form}
                onFinish={submit}
                initialValues={data}
                style={{ marginTop: 30 }}
            >
                {/* {isEdit ? <FormElement {...formProps} type="hidden" name="id"/> : null} */}
                <Col offset={5} span={18}>
                    <FormElement
                        {...formProps}
                        type="switch"
                        label="启动程序"
                        name="enabled"
                    />
                    <FormElement
                        {...formProps}
                        label="运行状态"
                        name="status"
                    >
                        <div><span style={{ color: data.statusBool ? 'green' : 'red' }}>{data.status}</span></div>
                    </FormElement>
                    <FormElement
                        {...formProps}
                        type="select"
                        label="运行模式"
                        name="mode"
                        options={[
                            {value: 'black', label: '黑名单模式'},
                            {value: 'video', label: '视频模式'},
                            {value: 'global', label: '全局模式'},

                        ]}
                    />
                    <FormElement
                        {...formProps}
                        label="证书下载"
                        name="cert"
                    >
                        <Button onClick={() => window.open(data.certUrl)}>证书下载</Button>
                    </FormElement>
                </Col>

                <FooterBar>
                    <Button type="primary" htmlType="submit" style={{ marginRight: 10 }}>保存</Button>
                    <Button onClick={() => form.resetFields()}>重置</Button>
                </FooterBar>
            </Form>
        </PageContent>
    );}
