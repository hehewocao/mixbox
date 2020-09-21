import React, {Component} from 'react';
import {Button, Form} from 'antd';
import PageContent from 'src/layouts/page-content';
import config from 'src/commons/config-hoc';
import {
    QueryBar,
    FormRow,
    FormElement,
    Table,
    Operator,
    Pagination,
} from 'src/library/components';
import batchDeleteConfirm from 'src/components/batch-delete-confirm';
// import EditModal from './EditModal';

export default function (props) {

    const [form] = Form.useForm();


    const formProps = {
        width: 200,
    };

    return (
        <PageContent>
            <QueryBar>
                    <Form
                        onFinish={() => this.setState({pageNum: 1}, () => this.handleSubmit())}
                        name="koolproxy-edit"
                        form={form}
                        // initialValues={data}
                        // style={{ marginTop: 30 }}
                    >
                        <FormRow>
                            <FormElement
                                {...formProps}
                                label="名称"
                                name="name"
                            />
                            <FormElement
                                {...formProps}
                                type="select"
                                label="职位"
                                name="job"
                                options={[
                                    {value: 1, label: 1},
                                    {value: 2, label: 2},
                                ]}
                            />
                            <FormElement layout>
                                <Button type="primary" htmlType="submit">提交</Button>
                                <Button onClick={() => this.form.resetFields()}>重置</Button>
                                <Button type="primary" onClick={() => this.setState({visible: true, id: null})}>添加</Button>
                                {/* <Button danger onClick={this.handleBatchDelete}>删除</Button> */}
                            </FormElement>
                        </FormRow>
                    </Form>
                </QueryBar>
        </PageContent>
    )

}
