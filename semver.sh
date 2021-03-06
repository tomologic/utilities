#!/bin/bash
# Author: Carl Loa Odin <carl.loa.odin@gmail.com>
# https://gist.github.com/loa/435da12af9494a112daf

test_res=0

function get_git_version() {
    version=$(git describe --tags --match 'v[0-9]*\.[0-9]*\.[0-9]*')
    if [ $? -eq 128 ]; then
        # Return initial version incase no tags is found
        echo "0.0.0"
    fi
    echo $version
}

function clean_version() {
    echo $(echo $1 | grep -o '[0-9]*\.[0-9]*\.[0-9]*')
}

function col_index() {
    if [ "$1" == "major" ]; then
        echo 0
    elif [ "$1" == "minor" ]; then
        echo 1
    elif [ "$1" == "patch" ]; then
        echo 2
    else
        echo 3
    fi
}

function bump() {
    IFS='.' read -a array <<< "$1"
    col=$2
    # increase requested column
    let array[$col]+=1
    # reset all columns below
    until [ $col -eq 2 ]; do
        let col+=1
        let array[$col]=0
    done
    echo "${array[0]}.${array[1]}.${array[2]}"
}

function assert() {
    echo -en "'$1' == '$2'"
    [ "$1" == "$2" ] && {
        echo -e $'..\e[32m ok\e[0m'
    } || {
        echo -e $'..\e[31m fail\e[0m'
        let test_res+=1
    }
}

function print_help() {
    echo "Usage:"
    echo -e "\t$0 current"
    echo -e "\t$0 bump [major|minor|patch]"
    echo -e "\t$0 test"
}

if [ "$1" == "test" ]; then
    echo $'\e[34mbump\e[0m'
    assert $(bump "1.1.0" 0) "2.0.0"
    assert $(bump "0.1.0" 1) "0.2.0"
    assert $(bump "0.0.1" 2) "0.0.2"
    assert $(bump "10.1.1" 0) "11.0.0"
    assert $(bump "10.1.1" 1) "10.2.0"
    assert $(bump "10.1.1" 2) "10.1.2"
    assert $(bump "9.0.1" 0) "10.0.0"

    echo
    echo $'\e[34mclean_version\e[0m'
    assert $(clean_version "v1.0.1") "1.0.1"
    assert $(clean_version "v1.0.1-aoeu") "1.0.1"
    assert $(clean_version "v1.0.1.aoeu") "1.0.1"
    assert $(clean_version "v10.10.21") "10.10.21"
    assert $(clean_version "v10.10.21-aoeu") "10.10.21"
    assert $(clean_version "v100.10.21.aoeu") "100.10.21"

    echo
    echo $'\e[34mcol_index\e[0m'
    assert $(col_index "major") "0"
    assert $(col_index "minor") "1"
    assert $(col_index "patch") "2"

    exit $test_res
elif [ "$1" == "current" ]; then
    tag=$(get_git_version)
    echo $(clean_version $tag)
elif [ "$1" == "bump" ]; then
    tag=$(get_git_version)
    version=$(clean_version $tag)
    col=$(col_index $2)
    if [ $col == 3 ]; then
        print_help
        exit 1
    fi
    echo $(bump $version $col)
else
    print_help
fi
