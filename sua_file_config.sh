#!/bin/bash
#shell chuan ISO
#Create By NamNT - Meditech
check_session()
{
	local file_check=$1
	local session=$2
	local stat=1
	check_gre=$(cat $file_check | grep -n "\[*\]" | grep -w "$session")
	if [ "$check_gre" != "" ]
	then
		stat=0
	fi
	return $stat
}
check_parameter()
{
	local file_check=$1
	local string="$2"
	local number_s=$3
	local number_e=$4
	local stat=1
	for (( i = $number_s ; i < $number_e ; i++ ))
	do
		get_str=$(sed -n "$i"p $file_check | grep -w "$string")
		if [ "$get_str" != "" ]
		then
			stat=0
		fi
	done
	return $stat
}
add_after_line()
{
	local file_check=$1
	local session=$2
	local string=$3
	sed -i "/\[$session\]/a $string" $file_check
}
check_string()
{
	local check_tu="$1"
	local stat=1
	num_ofstring=$(echo $check_tu | awk -F'=' '{print NF}')
	if [ $num_ofstring -eq 2 ]
	then
		stat=0
	fi
	return $stat
}
sua_line()
{
	local file_check=$1
	local number_line=$2
	local old_str=$3
	local new_str=$4
	sed -i "$number_line s/$old_str/$new_str/g" $file_check
}
sua_section()
{
	local file_check=$1
	local t_session=$2
	local str_key="$3"
	local str_value="$4"
	if [ -f $file_check ]
	then
		check_session $file_check $t_session
		if [ $? -eq 0 ]
		then
			local i=0
			get_session=($(cat $file_check | grep -n "\[*\]"))
			number_session=${#get_session[@]}
			number_ss=$(($number_session - 1))
			for (( i = 0 ; i < $number_session ; i++ ))
			do
				if [ "$(echo ${get_session[$i]} | grep -w "$t_session")" != "" ]
				then
					narray_session=$i
				fi
			done
			
			get_number_line_s=$(echo ${get_session[$narray_session]} | \
									awk -F':' '{print $1}')
			if [ $narray_session -lt $number_ss ]
			then
				n_next=$(( $narray_session + 1 ))
				
				get_number_line_e=$(echo ${get_session[$n_next]} | \
									awk -F':' '{print $1}')
			else
				get_number_line_e=$(cat $file_check | wc -l)
			fi
			check_parameter $file_check "$str_key" $get_number_line_s $get_number_line_e
			if [ $? -ne 0 ]
			then
				add_after_line $file_check $t_session "$str_key = $str_value"
			else
				for (( i = $get_number_line_s ; i < get_number_line_e ; i++))
				do
					check_number_str=$(sed -n "$i"p $file_check | grep -w "$str_key" | grep "=" )
					if [ "$check_number_str" != "" ]
					then
						number_line_string=$i
					fi
				done
					get_old_value=$(sed -n "$number_line_string"p $file_check | awk -F'=' '{print $NF}')
					sua_line $file_check $number_line_string "$get_old_value" " $str_value"
			fi
		else
			echo "[$t_session]" >> $file_check
			add_after_line $file_check $t_session "$str_key = $str_value"
		fi
	else
		echo "[$t_session]" >> $file_check
		add_after_line $file_check $t_session "$str_key = $str_value"
	fi
}
delete_session()
{
	local file_check=$1
	local t_session=$2
	if [ -f $file_check ]
	then
		check_session $file_check $t_session
		if [ $? -eq 0 ]
		then
			local i=0
			get_session=($(cat $file_check | grep -n "\[*\]"))
			number_session=${#get_session[@]}
			number_ss=$(($number_session - 1))
			for (( i = 0 ; i < $number_session ; i++ ))
			do
				if [ "$(echo ${get_session[$i]} | grep -w $t_session)" != "" ]
				then
					narray_session=$i
				fi
			done
			
			get_number_line_s=$(echo ${get_session[$narray_session]} | \
									awk -F':' '{print $1}')
			if [ $narray_session -lt $number_ss ]
			then
				n_next=$(( $narray_session + 1 ))
				
				get_number_line_e=$(echo ${get_session[$n_next]} | \
									awk -F':' '{print $1}')
			else
				get_number_line_e=$(cat $file_check | wc -l)
			fi
			
			for (( i = $get_number_line_s; i < $get_number_line_e ; i++))
			do
				sed -i "$get_number_line_s d" $file_check
			done
		fi
	fi
}
delete_line_ofsession()
{
	local file_check="$1"
	local t_session="$2"
	local str_del="$3"
	if [ -f $file_check ]
	then
		check_session $file_check $t_session
		if [ $? -eq 0 ]
		then
			local i=0
			get_session=($(cat $file_check | grep -n "\[*\]"))
			number_session=${#get_session[@]}
			number_ss=$(($number_session - 1))
			for (( i = 0 ; i < $number_session ; i++ ))
			do
				if [ "$(echo ${get_session[$i]} | grep -w "$t_session")" != "" ]
				then
					narray_session=$i
				fi
			done
			
			get_number_line_s=$(echo ${get_session[$narray_session]} | \
									awk -F':' '{print $1}')
			
			
			if [ $narray_session -lt $number_ss ]
			then
				n_next=$(( $narray_session + 1 ))
				
				get_number_line_e=$(echo ${get_session[$n_next]} | \
									awk -F':' '{print $1}')
			else
				get_number_line_e=$(cat $file_check | wc -l)
				get_number_line_e=$(($get_number_line_e + 1))
			fi
				for (( i = $get_number_line_s ; i < get_number_line_e ; i++))
				do
					check_number_str=$(sed -n "$i"p $file_check | grep -w "$str_del" )
					if [ "$check_number_str" != "" ]
					then
						number_line_string=$i
					fi 
				done
				sed -i "$number_line_string d" $file_check
		fi
	fi
	
}
get_leng_string()
{
	local file_check=$1
	get_line=$(cat $file_check | wc -l)
	local current_count=1
	for ((i=1; i<=$get_line; i++))
	do
		str=$(sed -n "$i"p $file_check)
		count_str=${#str}
		if [ $current_count -lt $count_str ]
		then
			current_count=$count_str
		fi
	done
	echo $current_count
}
view_config()
{
	local divider='===================='
	local dividern='===================='
	local divideen1='--------------------'
	local divideen2='--------------------'
	local file_session="$1"
	local file_key="$2"
	local file_value="$3"
	dividern="$dividern$dividern$dividern$dividern"
	divideen2="$divideen2$divideen2$divideen2$divideen2"
	get_number_line=$(cat $file_session | wc -l)
	
	count_line_session=$(get_leng_string $file_session)
	count_line_key=$(get_leng_string $file_key)
	count_line_value=$(get_leng_string $file_value)
	
	
	width=$(($count_line_session + $count_line_key + $count_line_value + 10))
		count_for_divider=$(($width / 20))
	
	for ((i = 1; i <= $count_for_divider; i++))
	do
		dividern+=$divider
		divideen2+=divideen1
	done
	
	format="| %$(echo $count_line_session)s | %$(echo $count_line_key)s | %$(echo $count_line_value)s |\n"
	clear
	printf "%$width.${width}s\n" "$dividern"
	printf "$format" "SECTION" "KEY" "VALUE"
	printf "%$width.${width}s\n" "$dividern"
	for ((i=1; i <=$get_number_line; i++))
	do
		str_session=$(sed -n "$i"p $file_session)
		str_key=$(sed -n "$i"p $file_key)
		str_value=$(sed -n "$i"p $file_value)
		printf "$format" "$str_session" "$str_key" "$str_value"
		printf "%$width.${width}s\n" "$divideen2"
	done
	rm -rf $file_session
	rm -rf $file_key
	rm -rf $file_value
}
show_conf_file()
{
	local file_show="$1"
	if [ -f $file_show ]
	then
		local getfile='/tmp/getfile'
		local session_file='/tmp/session_file'
		local key_file='/tmp/key_file'
		local value_file='/tmp/value_file'
		rm -rf  $session_file
		rm -rf  $key_file
		rm -rf  $value_file
		grep -v '^$\|^\s*\#' $file_show > $getfile
		get_session=($(cat $getfile | grep -n "\[*\]"))
		number_line_file=$(cat $getfile | wc -l)
		
		get_number_session=${#get_session[@]}
		get_number_session_ss=$(($get_number_session - 1))
		for ((i = 0; i < $get_number_session; i++))
		do
			OIFS=$IFS
			IFS=':'
			session_n=(${get_session[$i]})
			IFS=$OIFS
			if [ $i -lt $get_number_session_ss ]
			then
				ss_end=${get_session[$(($i + 1))]}
				OIFS=$IFS
				IFS=':'
				ss_end=($ss_end)
				IFS=$OIFS
				number_session_end=${ss_end[0]}
			else
				number_session_end=$(($number_line_file + 1))
			fi
			start_j=$(( ${session_n[0]} + 1 ))
			if [ $start_j -lt $number_session_end ]
			then
			for (( j = $start_j; j < $number_session_end ; j++ ))
			do
				get_str=$(sed -n "$j"p $getfile)
				echo ${session_n[1]} >> $session_file
				
				echo $(echo $get_str | awk -F'=' '{print $1}') >> $key_file
				
				echo $(echo $get_str | awk -F'=' '{print $2}') >> $value_file
			done
			fi
		done
		rm -rf $getfile
		view_config $session_file $key_file $value_file
	else
		exit 1
	fi
	
}
	get_op="$1"
	file_check="$2"
	str_section="$3"
	str_key="$4"
	str_value="$5"
	
	case $get_op in
	s|S|-s|-S|sua|SUA|Sua|e|E|"")
		if [ "$str_key" == "" ] || [ "$str_section" == "" ]
		then
			exit 1
		fi
			sua_section "$file_check" "$str_section" "$str_key" "$str_value"
	;;
	d|D|-d|-D|r|R|-r|-R|delete|del|remove|REMOVE|DEL|DELETE)
		if [ "$str_section" == "" ]
		then
			exit 1
		fi
		delete_session "$file_check" "$str_section"
	;;
	-dl|-DL|dl|DL)
		if [ "$str_key" == "" ] || [ "$str_section" == "" ]
		then
			exit 1
		fi
		delete_line_ofsession "$file_check" "$str_section" "$str_key"
	;;
	-v|v|-V|V)
		show_conf_file $file_check
	;;
	-m|m|-M|M|multi|--multi)
		get_bien=${#@}
		get_array=("${@}")
		if [ $get_bien -gt 4 ]
		then
			for ((i=3; i<$get_bien; i+=2))
			do
				j=$(($i + 1))
				sua_section "$file_check" "$str_section" "${get_array[$i]}" "${get_array[$j]}"
			done
		fi
	;;
	*)
		clear
		echo 'Options error.'
		echo 'Options:'
		echo '------------------------------------------------------'
		echo '-s: Sua lile'
		echo 'Vi du: file_shell -s file_config ten_section key value'
		echo '------------------------------------------------------'
		echo '-d: xoa section'
		echo 'Vi du: file_shell -d file_config ten_section'
		echo '------------------------------------------------------'
		echo '-dl: xoa key cua session'
		echo 'Vi du: file_shell -dl file_config ten_section ten_key'
		echo '------------------------------------------------------'
		echo '-m: add multiline'
		echo 'Vi du: file_shell -m file_config ten_section ten_key1 value1 ten_key2 value2 ...'
		echo '------------------------------------------------------'
		echo '-v: view configure file'
		echo '------------------------------------------------------'
		echo 'Thank you Using Script'
		echo 'NamNT - Meditech ^_*'
		
		exit 1
	;;
	esac
	
