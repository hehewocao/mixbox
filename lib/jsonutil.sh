# source base [needed]

json_add_var() {
	if echo "${1}" | grep -Eq 'bool|Bool|enable|disable|Status'; then
		json_add_boolean "${1}" "${2}"
	else
		json_add_string "${1}" "${2}"
	fi
}

# json property to shell var
# { "a": "1", "b": "2" } => a=1 b=2
json_to_var() {
	local json="${1}"
	[ -z "${json}" ] && logerror "json不能为空！"
	json_load "${json}"
	json_get_keys keys
	for k in $keys; do
		json_get_var v "$k"
		eval $k="$v"
	done
}

# a=1 b=2 => { "a": "1", "b": "2" }
var_to_json() {
	[ $# -eq 0 ] && logerror "参数不能为空！"
	local delimiter="${delimiter:-,}"
	json_init
	for key in $@; do
		value="$(parse_str "${key}")"
		if echo ${key} | grep -Eq 's$'; then
			json_add_array "${key}"
			for i in `echo "${value}" | tr "${delimiter}" '\n'`; do
				json_add_var "" "${i}"
			done
			json_close_array
		else
			json_add_var "${key}" "${value}"
		fi
	done
	json_dump
}

# { "a": "1" } b=2 => { "a": "1", "b": "2" }
var_add_to_json() {
	local json="${1}"
	[ -z "${json}" ] && logerror "json不能为空！"
	json_load "${json}"
	shift 1
	for i in $@; do
		json_add_var "${i}" "$(parse_str "${i}")"
	done
	json_dump
}

# transform a=1\nb=2\nc=3 to { "a": "1", "b": "2", "c": "3" }
config_to_json_obj() {
	local config="${1}"
	local out="${2}"
	local delimiter="${delimiter:-,}"
	local key value
	[ ! -f "${config}" ] && logerror "配置文件不存在！"
	json_init
	while read line; do
		[ -z "${line}" ] && continue
		key=`echo ${line} | cut -d'=' -f1`
		value=`echo ${line} | cut -d'=' -f2- | sed -E "s/(^\"|\"$)//g"`
		if echo ${key} | grep -Eq 's$'; then
			json_add_array "${key}"
			for i in `echo "${value}" | tr "${delimiter}" '\n'`; do
				json_add_var "" "${i}"
			done
			json_close_array
		else
			json_add_var "${key}" "${value}"
		fi
	done < ${config}
	[ -n "${out}" ] && json_dump &> ${out} || json_dump
}

# transform { "a": "1", "b": "2", "c": "3" } to a=1\nb=2\nc=3
json_obj_to_config() {
	local json="${1}"
	local out="${2}"
	local delimiter="${delimiter:-,}"
	[ -z "${json}" ] && logerror "json不能为空！"
	json_load "${json}"
	json_get_keys keys
	[ -n "${out}" ] && cat /dev/null > ${out}
	for k in $keys; do
		if json_get_type type "$k" && [ "${type}" = "array" ]; then
			json_select "$k"
			index="1"
			vs=""
			while json_get_type type ${index} && [ "${type}" = "string" ]; do
				json_get_var v $((index++))
				vs=${vs}${delimiter}${v}
			done
			vs=`echo ${vs} | sed -E "s/^${delimiter}//"`
			json_select ".."
		else
			json_get_var vs "$k"
		fi
		[ -n "${out}" ] && echo "$k=\"$vs\"" >> ${out} || echo "$k=\"$vs\""	
	done
}

# tranform a,b,c\n1,2,3 to { "data": [ { "a": "1", "b": "2", "c": "3" } ] }
config_to_json_array() {
	local config="${1}"
	local out="${2}"
	local delimiter="${delimiter:-|}"
	[ ! -f "${config}" ] && logerror "配置文件不存在！"
	local head=`cat ${config} | head -1`
	local count=`echo ${head} | tr "${delimiter}" '\n' | wc -l`
	json_init
	# 获取文件名称，根据配置文件名称构建数组
	json_add_array "$(basename ${config} | cut -d'.' -f1)"
	while read line; do
		[ "${line}" = "${head}" -o -z "${line}" ] && continue
		json_add_object
		for i in `seq 1 ${count}`; do
			json_add_var "`cutsh "${head}" ${i}`" "`cutsh "${line}" ${i}`"
		done
		json_close_object
	done < ${config}
	json_close_array
	[ -n "${out}" ] && json_dump &> ${out} || json_dump
}

# tranform { "data": [ { "a": "1", "b": "2", "c": "3" } ] } to a,b,c\n1,2,3
json_array_to_config() {
	local json="${1}"
	local out="${2}"
	local delimiter="${delimiter:-|}"
	[ -z "${json}" ] && logerror "json不能为空！"
	json_load "${json}"
	json_get_keys keys
	[ -n "${out}" ] && cat /dev/null > ${out}
	local head
	local headout=0
	for k in $keys; do
		if json_get_type type "$k" && [ "${type}" = "array" ]; then
			json_select "$k"
			index="1"
			while json_get_type type ${index} && [ "${type}" = "object" ]; do
				json_select $((index++))
				json_get_keys attrs
				vs=""
				for attr in $attrs; do
					json_get_var v $attr
					vs=${vs},${v}
					[ "${headout}" -eq 0 ] && head=${head}${delimiter}${attr}
				done
				vs=`echo ${vs} | sed -E "s/^${delimiter}//"`
				# 输出标题
				if [ "${headout}" -eq 0 ]; then
					head=`echo ${head} | sed -E "s/^${delimiter}//"`
					[ -n "${out}" ] && echo "${head}" >> ${out} || echo "${head}"
					headout=1
				fi
				[ -n "${out}" ] && echo "${vs}" >> ${out} || echo "${vs}"
				json_select ".."
			done
			json_select ".."
		fi
		# [ -n "${out}" ] && echo "$k=\"$vs\"" >> ${out} || echo "$k=\"$vs\""	
	done
}
