import React from 'react';
import {Form, Button, Col} from 'antd';
import {FormElement, FooterBar} from 'src/library/components';
import PageContent from 'src/layouts/page-content';
import {useGet} from 'src/commons/ajax';

export default function (props) {

    const { loading, submit, data, formProps, form, formData } = props;

    return (
        <PageContent loading={loading}>
            <Form
                name="form"
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
                    {
                        (formData || []).map(fd => {
                            if (fd.type === 'select') {
                                return (
                                    <FormElement
                                        {...formProps}
                                        type={fd.type}
                                        label={fd.label}
                                        name={fd.name}
                                        options={fd.options}
                                    />
                                )
                            } else if (fd.type === 'hyperlink') {
                                return (
                                    <FormElement
                                        {...formProps}
                                        label={fd.label}
                                        name={fd.name}
                                    >
                                        <Button href={fd.url} target="_blank">
                                            {fd.button || fd.label}
                                        </Button>
                                    </FormElement>
                                )
                            } else if (fd.type === 'get') {
                                return (
                                    <FormElement
                                        {...formProps}
                                        label={fd.label}
                                        name={fd.name}
                                    >
                                        <Button onClick={() => {
                                            const [, getData] = useGet(fd.url);
                                            getData()
                                        }}>
                                            {fd.button || fd.label}
                                        </Button>
                                    </FormElement>
                                )
                            } else if (fd.type === 'switch') {
                                return (
                                    <FormElement
                                        {...formProps}
                                        type={fd.type}
                                        label={fd.label}
                                        name={fd.name}
                                    />
                                )
                            } else if (fd.type === 'text') {
                                return (
                                    <FormElement
                                        {...formProps}
                                        label={fd.label}
                                        name={fd.name}
                                    >
                                        <div><span style={fd.style}>{fd.value}</span></div>
                                    </FormElement>
                                )
                            } else {
                                return (
                                    <FormElement
                                        {...formProps}
                                        type={fd.type}
                                        label={fd.label}
                                        name={fd.name}
                                    />
                                )
                            }
                        })
                    }
                </Col>

                <FooterBar>
                    <Button type="primary" htmlType="submit" style={{ marginRight: 10 }}>保存</Button>
                    <Button onClick={() => form.resetFields()}>重置</Button>
                </FooterBar>
            </Form>
        </PageContent>
    );}
