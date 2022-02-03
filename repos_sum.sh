#!/bin/bash
# https://docs.github.com/en/rest/overview/resources-in-the-rest-api
# https://docs.github.com/cn/rest/reference/repos
# https://docs.github.com/cn/rest/reference/teams
# https://docs.github.com/en/rest/overview/other-authentication-methods

echo -e "\033[5;33m\n请输入目标/组织名称\033[0m" && read -r input
export name=$input

echo -e "\033[5;33m\n请输入 TOKEN\033[0m" && read -r input
export token=$input

echo -e "\n仓库列表如下"
curl -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $token" "https://api.github.com/users/$name/repos?page=1&per_page=100" --silent > /tmp/test.json
cat /tmp/test.json | jq .[].full_name > /tmp/repo_name.txt.bak
cat /tmp/test.json | jq .[].html_url # > /tmp/repo_url.txt.bak

cat /tmp/repo_name.txt.bak | sed 's/\"//g' > /tmp/repo_name.txt && rm -rf /tmp/repo_name.txt.bak

# rm -rf /tmp/star_sum.txt
star_sum=0
fork_sum=0
while IFS= read -r target
do
    curl -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $token" https://api.github.com/repos/$target --silent > /tmp/temp_repos.json
    sum_temp=$(cat /tmp/temp_repos.json | jq .stargazers_count)
    fork_temp=$(cat /tmp/temp_repos.json | jq .forks_count)

    if [ $sum_temp == null ]
    then
        sum_temp=0
    fi

    if [ $fork_temp == null ]
    then
        fork_temp=0
    fi

    star_sum=$(expr $star_sum + $sum_temp)
    fork_sum=$(expr $fork_sum + $fork_temp)
done < "/tmp/repo_name.txt"

echo -e "\n总 star : $star_sum"
echo -e "总 fork : $fork_sum"
