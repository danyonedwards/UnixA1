#!/bin/bash

# This is the script to read username:password_hash formats from a file. Once these are
# loaded, the script attempts to brute force the SHA-256 password_hash to retrieve
# a cleartext password.


# This function is used to double check that all files required are present,
# if this is not true, stop the program
checkFiles()
{
    printf '\n-------Checking resources exist-------\n'
    for file in "${files[@]}" # Loop through all files
    do
        if [ -f $dict_path$file ] || [ -f $r_path$file ]; then # Check if file exists and is valid file
            echo "$file exists"
        else
            echo "$file could not be found"
            exit 1
        fi
    done
}


# This function attempts to load the content of the userDB and store the appropriate
# information in it's respective variables
loadDB()
{
    printf "\n----Loading user from the database-----\n"

    while IFS= read line
    do
        IFS=":" tokens=($line) # seperate input line by colon
        is_uname=1 # if token is username

        # The bulk of the loop that seperates username and password from file
        for token in "${tokens[@]}" # cycle all tokens for line
        do
            if [ $is_uname -eq 1 ]; then # if token is username
                is_uname=0
                users[$num_entries]=$token
            else
                is_uname=1
                hashes[$num_entries]=$token
            fi
        done
        printf "user: ${users[num_entries]}\t\t\thash: ${hashes[num_entries]}\n"
        ((num_entries++))
    done < "$r_path$db_data"
}

# This function loads a list of common passwords to find a match between user
# password hashes
commonHashSearch()
{
    printf "\n--------Common password search--------\n"
    while IFS= read line
    do
        hash=$(echo -n "$line" | sha256sum | awk '{print $1}') # convert pass to hash

        for ((i=0; i<$num_entries; i++)) # Cycle all user passwords
        do
            if [ "$hash" == "${hashes[$i]}" ]; then
                ((pass_found++)) # Increment number of found password
                per=$(echo "scale=2; 100*$pass_found/$num_entries" | bc -l) # get percentage
                echo "user [${users[i]}] has password: $line. ($per% of DB complete) "
                unset per
            fi
            #sleep 0.1 # Sleep to avoid
        done
    done < "$r_path$common_pass"
}

# This function performs a dictionary search on the hashes to find a match to user
# password hashes
dictionaryHashSearch()
{
    printf "\n-------Dictionary password search------\n"
    while IFS= read line
    do
        hash=$(echo -n "$line" | sha256sum | awk '{print $1}') # convert pass to hash

        for ((i=0; i<$num_entries; i++)) # Cycle all user passwords
        do
            if [ "$hash" == "${hashes[$i]}" ]; then
                ((pass_found++)) # Increment number of found password
                per=$(echo "scale=2; 100*$pass_found/$num_entries" | bc -l) # get percentage
                echo "user [${users[i]}] has password: $line. ($per% of DB complete) "
                unset per
            fi
            #sleep 0.1 # Sleep to avoid
        done
    done < "$dict_path$dict"
}

#This function performs a brute force attempt at finding the hashed password
bruteForceSearch()
{
    printf "\n-------Bruteforce password search------\n"
}


# Files
r_path="resources/" # Resource path
dict_path="/home/el5/E20925/"
db_data="db_data.txt"
dict="linux.words"
common_pass="common_pass.txt"
declare -a files=($db_data $common_pass $dict);

# Usernames and passwords
num_entries=0 # the number of entries in file
pass_found=0 # number of found password
declare -a users
declare -a hashes
declare -a found



#------MAIN------#

# Check files
checkFiles

# Load files
loadDB

# 1st attempt to find passwords using common password list
commonHashSearch

# 2nd attempt perform a dictionary search
dictionaryHashSearch

bruteForceSearch
