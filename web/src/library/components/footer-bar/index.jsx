import React, { Component } from 'react';
import { Affix } from 'antd';
import {connect} from 'src/models';

@connect(state => ({
    sideWidth: state.side.width,
    collapsed: state.side.collapsed,
    collapsedWidth: state.side.collapsedWidth
}))
export default class FooterBar extends Component {

    render() {
        const { sideWidth, collapsed, collapsedWidth } = this.props;
        return (
            <Affix
                { ...this.props }
                offsetBottom={0}
                style={{
                    ...this.props.style,
                    position: 'fixed',
                    left: collapsed ? collapsedWidth : sideWidth,
                    bottom: 0,
                    width: '100%',
                    height: '50px',
                    boxShadow: '0px -5px 5px rgba(0, 0, 0, 0.067)',
                    lineHeight: '50px',
                    zIndex: 1,
                    textAlign: 'left',
                    paddingLeft: 10,
                    backgroundColor: 'white',
                }}
            >
                {this.props.children}
            </Affix>
        );
    }
}
