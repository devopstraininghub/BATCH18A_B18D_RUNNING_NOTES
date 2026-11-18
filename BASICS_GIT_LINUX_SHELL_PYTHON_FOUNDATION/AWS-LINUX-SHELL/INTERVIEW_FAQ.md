#### 1. How to find files in Linux?


find /path -name "filename"
Examples:

By name: find . -name "*.log"

By size: find / -size +100M

Recently modified: find /var/log -mtime -7

#### 2. Which Linux distro did you use in your project?

In my projects, I primarily used RHEL for production environments and Ubuntu for cloud-native and DevOps workloads....I’ve also used Amazon Linux 2, especially for AWS-native workloads.

#### 3.: How can you set up password-less authentication in Linux using SSH?

1.Generate SSH key
    ssh-keygen
    
2.Copy public key to remote server:
    ssh-copy-id user@remote-server
    
3. Now you can SSH without a password:
    ssh user@remote-server

#### 4. What is the command to check memory in Linux?
free -h

#### 5. What is the command to check file size in Linux?
du -sh filename

#### 6. How can you search for a word in Linux?
grep 'word' filename
To search recursively in all files: 

grep -r 'word' /path/to/directory

#### 7. How do you troubleshoot if an application is running slow on Linux?


TROUBLESHOOTING A SLOW APPLICATION ON LINUX
(INTERVIEW-READY ANSWER)

    I troubleshoot a slow application on Linux by
    systematically checking system resources first,
    then application behavior, and finally OS or
    dependency limits.


    CPU & LOAD

        - Check CPU usage and system load
        - Commands:
            top
            htop
            uptime
        - Look for:
            • High CPU usage
            • Load average higher than number of CPU cores


    MEMORY

        - Check RAM and swap usage
        - Commands:
            free -m
            vmstat 1
        - Look for:
            • Low available memory
            • Heavy swap usage


    DISK & I/O

        - Check disk space and I/O performance
        - Commands:
            df -h
            iostat -x
        - Look for:
            • Full disks
            • High I/O wait time


    PROCESSES

        - Identify resource-heavy processes
        - Command:
            ps -eo pid,cmd,%cpu,%mem --sort=-%cpu
        - Look for:
            • Processes consuming high CPU or memory


    NETWORK

        - Check network connectivity and latency
        - Commands:
            ss
            netstat
            ping
            traceroute
        - Look for:
            • High latency
            • Packet drops
            • Connectivity issues


    APPLICATION LOGS

        - Review application and service logs
        - Look for:
            • Errors
            • Slow queries
            • Timeouts
            • Repeated warnings


    OS LIMITS

        - Check system limits
        - Command:
            ulimit -a
        - Look for:
            • File descriptor limits
            • Process limits


    RECENT CHANGES

        - Review recent system or app changes
        - Check:
            • New deployments
            • Configuration changes
            • Cron jobs
            • OS patches or updates

    in simple words , I isolate performance issues by correlating CPU,
    memory, disk, and network metrics with application
    logs to quickly identify the bottleneck.




#### 8: Which command is used in Linux to check disk usage?

df -h           Shows disk usage in human-readable format

du -sh *        Shows folder sizes in the current directory

#### 9: How can you delete the contents of a file in Linux without deleting the file itself?

CLEAR FILE CONTENTS WITHOUT DELETING FILE (LINUX)


    You can delete the contents of a file in Linux
    without deleting the file itself by truncating
    the file to zero length.


    Using redirection (most common):

        > filename


    Using truncate command:

        truncate -s 0 filename


    Using /dev/null:

        cat /dev/null > filename


    Using true command:

        true > filename


    - The file remains in the same location
    - File permissions stay unchanged
    - Ownership remains the same
    - Inode number remains the same
    - Only the file content is removed


    Usage in Realworld:

    - Clearing large log files
    - Avoiding service restart
    - Preventing disk from filling up
    - Maintaining log file references used by applications



    ONE-LINER TO CLOSE (INTERVIEW)

    By redirecting empty output or truncating a file,
    we can clear its contents while keeping the file
    intact and avoiding service disruption.


truncate -s 0 filename  # Explicitly sets file size to 0

#### 10. How can you modify permissions in Linux?

Use chmod:

chmod 755 file.sh

Use chown to change ownership:

 chown user:group file
 

#### 11. What is crontab, and what are allow/deny files?

•	crontab schedules jobs.

•	/etc/cron.allow – only users in this file can use crontab.

•	/etc/cron.deny – users listed here cannot use crontab.

#### 12. How can you kill a process in Linux?

kill <PID>

kill -9 <PID>       #### force kill

#### 13. How can you check CPU utilization?

top

htop


#### 14. How can you check if a port is open and listening?

    Using ss (recommended, modern):

        ss -tuln

        -t  TCP ports
        -u  UDP ports
        -l  Listening ports
        -n  Numeric output (no DNS)


    Using netstat (older systems):

        netstat -tuln

#### 15. How can you check if the network is working using traceroute?

    - Network is slow but not fully down
    - Ping works but application is slow
    - Identify where latency increases
    - Find where packets are getting dropped
    - Debug routing issues between networks

    traceroute to example.com (93.184.216.34), 30 hops max
 
       1  10.0.0.1          1.1 ms   1.0 ms   1.2 ms
       2  192.168.1.1       2.3 ms   2.5 ms   2.4 ms
       3  52.93.10.45      15.6 ms  14.9 ms  15.2 ms
       4  52.93.10.78     120.3 ms 118.7 ms 121.1 ms
       5  203.0.113.14    130.5 ms 132.0 ms 131.8 ms
       6  93.184.216.34   129.9 ms 130.2 ms 130.0 ms


It shows the path and delays to the destination.

#### 16. How can you capture last 20 lines of a file?

tail -n 20 filename.log

#### 17: Have you ever come across a situation where a process in Linux is automatically killed?

Yes, this typically happens when the system runs out of memory. The OOM Killer (Out Of Memory Killer) in Linux terminates processes to free up RAM. You can check this using:


       dmesg | grep -i "killed process"

	   dmesg shows kernel messages.

       These are logs generated by the Linux kernel, such as:
       
       Hardware events
       
       Driver issues
       
       Memory problems
       
       OOM (Out Of Memory) kills
       
       Process crashes handled by the kernel

#### 18: How can you create user groups in Linux?

#### Create a group

sudo groupadd devteam

#### Add user to group

sudo usermod -aG devteam username

#### Verify
groups username

#### 19 List top 10 most commonly used linux commands?

ls -l           # Long listing of files

cd /var/log     # Navigate to /var/log directory

pwd             # Show current path

cp file1 file2  # Copy file1 to file2

mv file1 dir/   # Move file1 to directory

rm file1        # Delete file1

cat file1       # Show contents of file1

grep "text" file1  # Search for 'text' in file1

find . -name "*.log"  # Find .log files in current directory

chmod +x script.sh    # Make script executable

#### 20:Slowness is observed due to high CPU utilization. What would you do?

If I see high CPU usage causing slowness, I would:

Check which process is using the most CPU using top or htop.

Restart or fix the process if it's stuck or misbehaving.

Check logs to find errors or unusual activity.

Use monitoring tools like CloudWatch to check CPU trends.

Scale the instance (increase size) or add more instances if needed.

Optimize the application to reduce CPU usage (e.g., caching, better queries).
  


#### 21:You were able to SSH into an EC2 instance earlier, but now it’s failing. What steps will you take to troubleshoot?

If SSH was working before and now it’s failing, I would:

1. Check Security Group:

   * Ensure port `22` is open and my IP is allowed.

2. Check Network ACLs:

   * Make sure NACLs allow inbound and outbound traffic on port `22`.

3. Verify Instance State:

   * Confirm the instance is running and not stopped or terminated.

4. Check Public IP or DNS:

   * Ensure the instance still has a public IP (especially if it's in a public subnet).

5. Validate Key Pair:

   * Make sure I'm using the correct `.pem` file with proper permissions (`chmod 400`).

6. Use EC2 Instance Connect or SSM:

   * Try EC2 Instance Connect or Session Manager (if configured) for deeper inspection.

7. Check CPU/Memory:

   * If CPU is 100%, SSH might hang — check CloudWatch metrics.

8. Review Logs:

   * Check system logs (`/var/log/auth.log`, `/var/log/secure`) using EC2 Connect or attaching the volume to another instance.

#### 22 Find and list log files older than seven days in /var/log directory?

   

LINUX FILE TIMESTAMPS AND FIND COMMAND (COMPLETE NOTES)

--------------------------------------------------
LINUX FILE TIMESTAMPS
--------------------------------------------------

    Linux tracks three main timestamps for files:

        mtime  : Last content modification time
        ctime  : Last metadata change time (NOT creation)
        atime  : Last access (read) time

    NOTE:
        Creation time (also called birth time) exists only on
        some modern filesystems (ext4 newer versions, XFS)
        and is not always available.


--------------------------------------------------
FIND FILES OLDER THAN 7 DAYS
--------------------------------------------------

    Most common and correct method:

        find /path -type f -mtime +7

    Meaning:
        +7  → more than 7 days old
        Based on last modification time (mtime)

    Example:

        find /var/log -type f -mtime +7


--------------------------------------------------
FIND FILES MODIFIED WITHIN LAST 7 DAYS
--------------------------------------------------

    Command:

        find /path -type f -mtime -7

    Meaning:
        -7  → less than 7 days old
        Recently modified files

    Example:

        find /var/log -type f -mtime -7


--------------------------------------------------
FIND FILES EXACTLY 7 DAYS OLD
--------------------------------------------------

    Command:

        find /path -type f -mtime 7

    Meaning:
        Files modified between 7 and 8 days ago
        (Exact-day match)


--------------------------------------------------
CREATION TIME REALITY CHECK
--------------------------------------------------

    This does NOT reliably find creation time:

        find /path -ctime +7    (NOT creation time)

    What ctime actually means:

        ctime = Change time (metadata)

    ctime updates when:
        - Permissions change
        - Owner or group changes
        - File is moved
        - Metadata is modified

    IMPORTANT:
        ctime ≠ creation time


        --------------------------------------------------
        CHECK FILE CREATION TIME (IF SUPPORTED)
        --------------------------------------------------
        
            Use stat command:
        
                stat filename
        
            Example output:
        
                Birth: 2026-01-01 10:22:30.000000000
        
            If you see "Birth", your filesystem supports
            file creation time.
        
        
        --------------------------------------------------
        FIND FILES BASED ON DATE (BEST METHOD)
        --------------------------------------------------
        
            Files created or modified after a specific date:
        
                find /path -type f -newermt "2026-01-01"
        
            Files created or modified before a date:
        
                find /path -type f ! -newermt "2026-01-01"
        
        
        --------------------------------------------------
        FIND FILES CREATED WITHIN LAST 7 DAYS
        (BEST PRACTICE)
        --------------------------------------------------
        
            Command:
        
                find /path -type f -newermt "7 days ago"
        
            Why this is best:
                - Works even when creation time is unavailable
                - Uses date-based comparison
                - More portable and reliable
        
        
        --------------------------------------------------
        COMPARISON SUMMARY 
        --------------------------------------------------
        
            Requirement                     Option
            ------------------------------------------------
            Older than 7 days               -mtime +7
            Newer than 7 days               -mtime -7
            Exactly 7 days old              -mtime 7
            Based on modification time      -mtime
            Based on metadata change        -ctime
            Based on access time            -atime
            Based on date/time              -newermt
            True creation time              stat (Birth)
        
        
        --------------------------------------------------
        INTERVIEW-READY ANSWERS
        --------------------------------------------------
        
            Find files older than 7 days:
        
                find /var/log -type f -mtime +7
        
            Find files created within last 7 days:
        
                find /var/log -type f -newermt "7 days ago"
        
            What is ctime?
        
                ctime is change time.
                It tracks metadata changes, not file creation time.
        




#### 25 How would you write a Bash script to monitor service health?

Use a loop and tools like `systemctl` or `pgrep` to check if a service is running. If it's stopped, restart it and send an alert (e.g., email or Slack).

example:

```bash
#!/bin/bash
SERVICE="apache2"
if ! systemctl is-active --quiet "$SERVICE"; then
  systemctl restart "$SERVICE"
  echo "$(date): $SERVICE was down, restarted" | mail -s "$SERVICE restarted" mindcircuit@gmail.com 
fi
```



#### 26 How can you find files b size and delete files larger than 100 MB?



                FIND FILES BY SIZE (LINUX)
                
                --------------------------------------------------
                OVERVIEW
                --------------------------------------------------
                
                    The find command can be used to locate files
                    based on their size using the -size option.
                
                
                --------------------------------------------------
                FIND FILES LARGER THAN 100 MB
                --------------------------------------------------
                
                    Command:
                
                        find /path -type f -size +100M
                
                    Meaning:
                        +100M  → files larger than 100 MB
                        -type f → only regular files
                
                    Example:
                
                        find /var/log -type f -size +100M
                
                
                --------------------------------------------------
                FIND FILES SMALLER THAN 50 MB
                --------------------------------------------------
                
                    Command:
                
                        find /path -type f -size -50M
                
                    Meaning:
                        -50M  → files smaller than 50 MB
                
                
                --------------------------------------------------
                SIZE UNITS 
                --------------------------------------------------
                
                    - c  → bytes
                    - k  → KB
                    - M  → MB
                    - G  → GB
                
                
                --------------------------------------------------
                REAL-WORLD USE CASE
                --------------------------------------------------
                
                    - Identify large files causing disk usage issues
                    - Find small files for cleanup or archival
                    - Troubleshoot sudden disk space growth
                    - Prepare files for backup or migration
                
                
                --------------------------------------------------
                INTERVIEW ONE-LINER
                --------------------------------------------------
                
                    I use the find command with the -size option,
                    such as +100M for large files and -50M for
                    smaller files, to quickly locate files based
                    on their size.
                

#### 27 How do you list users who logged in today ?

    LIST USERS WHO LOGGED IN TODAY (LINUX)

    --------------------------------------------------
    OVERVIEW
    --------------------------------------------------

        To list users who logged in today, we check
        system login records stored in log files
        like wtmp and auth logs.


    --------------------------------------------------
    MOST COMMON METHOD
    --------------------------------------------------

        Using the last command:

            last

        - Shows login history of users
        - Includes date and time of login
        - Data comes from /var/log/wtmp

        To filter today’s logins manually:
            last | grep "$(date +"%b %e")"


    --------------------------------------------------
    LIST CURRENTLY LOGGED-IN USERS
    --------------------------------------------------

        Using who command:

            who

        - Shows users currently logged in
        - Displays login time and terminal



    ---------



#### 28 A website isn't loading—how do you troubleshoot?

    TROUBLESHOOTING A WEBSITE THAT IS NOT LOADING

    --------------------------------------------------
    OVERVIEW
    --------------------------------------------------

        When a website is not loading, I troubleshoot
        step by step to identify whether the issue is
        related to DNS, network, server, application,
        or service availability.


    --------------------------------------------------
    CHECK DNS RESOLUTION
    --------------------------------------------------

        Verify domain name resolution:

            nslookup example.com
            dig example.com
            ping example.com

        - If domain does not resolve:
            DNS issue
        - If IP resolves:
            DNS is working


    --------------------------------------------------
    CHECK NETWORK CONNECTIVITY
    --------------------------------------------------

        Test basic connectivity:

            ping <server_ip>

        Trace network path:

            traceroute example.com

        - Helps identify network latency or routing issues


    --------------------------------------------------
    CHECK SERVER AVAILABILITY
    --------------------------------------------------

        Verify server is reachable:

            ssh user@server_ip

        - If SSH fails:
            Server or network issue


    --------------------------------------------------
    CHECK SERVICE / PORT STATUS
    --------------------------------------------------

        Check if web service port is listening:

            ss -tuln | grep 80
            ss -tuln | grep 443

        Or test directly:

            curl http://localhost
            curl http://server_ip


    --------------------------------------------------
    CHECK WEB SERVER STATUS
    --------------------------------------------------

        For Apache:

            systemctl status httpd

        For Nginx:

            systemctl status nginx

        - Restart if required
        - Check for failed state


    --------------------------------------------------
    CHECK APPLICATION LOGS
    --------------------------------------------------

        Review logs for errors or crashes:

            /var/log/httpd/
            /var/log/nginx/
            application-specific logs

        - Look for:
            • Errors
            • Timeouts
            • Permission issues


    --------------------------------------------------
    CHECK DISK AND MEMORY
    --------------------------------------------------

        Verify disk space:

            df -h

        Check memory usage:

            free -m

        - Full disk or low memory can stop services


    --------------------------------------------------
    CHECK FIREWALL / SECURITY
    --------------------------------------------------

        Check firewall rules:

            iptables -L
            firewall-cmd --list-all

        - Ensure ports 80 / 443 are allowed


    --------------------------------------------------
    RECENT CHANGES
    --------------------------------------------------

        Review recent:
            - Deployments
            - Configuration changes
            - Patches or updates
            - SSL certificate changes


    --------------------------------------------------
    INTERVIEW ONE-LINER
    --------------------------------------------------

        I troubleshoot a website issue by checking DNS,
        network connectivity, server access, service and
        port status, application logs, and recent changes
        to quickly isolate the root cause.


#### 29 Using `sed`, how do you delete the first and last line of a file?


    --------------------------------------------------
    DELETE THE FIRST LINE
    --------------------------------------------------

        Command:

            sed '1d' filename

        Explanation:
            1  → first line
            d  → delete


    --------------------------------------------------
    DELETE THE LAST LINE
    --------------------------------------------------

        Command:

            sed '$d' filename

        Explanation:
            $  → last line
            d  → delete


    --------------------------------------------------
    DELETE BOTH FIRST AND LAST LINE
    --------------------------------------------------

        Command:

            sed '1d;$d' filename removes last line


30.  ls && df -h, ls || df -h, ls & df -h, ls & df -h

    COMMAND OPERATORS IN LINUX (&& , || , &)

    --------------------------------------------------
    ls && df -h
    --------------------------------------------------

        Meaning:
            - Run the second command ONLY if the first
              command succeeds.

        Explanation:
            - ls must succeed
            - If ls is successful → df -h runs
            - If ls fails → df -h does NOT run

        Use case:
            - Run next command only on success

        Example:
            ls && df -h


    --------------------------------------------------
    ls || df -h
    --------------------------------------------------

        Meaning:
            - Run the second command ONLY if the first
              command fails.

        Explanation:
            - If ls fails → df -h runs
            - If ls succeeds → df -h does NOT run

        Use case:
            - Error handling
            - Fallback command

        Example:
            ls || df -h


    --------------------------------------------------
    ls & df -h
    --------------------------------------------------

        Meaning:
            - Run BOTH commands in parallel (background).

        Explanation:
            - ls runs in background
            - df -h runs immediately
            - Shell does not wait for ls to finish

        Use case:
            - Run commands simultaneously
            - Speed up independent tasks

        Example:
            ls & df -h


    --------------------------------------------------
    ls ; df -h
    --------------------------------------------------

        Meaning:
            - Run both commands sequentially,
              regardless of success or failure.

        Explanation:
            - ls runs first
            - df -h runs next
            - No dependency between commands

        Use case:
            - Simple sequential execution

        Example:
            ls ; df -h


    --------------------------------------------------
    QUICK SUMMARY (INTERVIEW)
    --------------------------------------------------

        &&  → Run next command if previous succeeds
        ||  → Run next command if previous fails
        &   → Run command in background
        ;   → Run commands one after another

================================================================================

ADDITIONAL NOTES:

WHAT IS STICKY BIT IN LINUX?? WHEN TO USE ?

    STICKY BIT IN LINUX

        Sticky bit is a special permission in Linux
        used on directories.

        It ensures that only:
            - The file owner
            - The directory owner
            - Root user
        can delete or rename files inside that directory.

        Even if other users have write permission,
        they cannot delete files owned by others.


    --------------------------------------------------
    WHY STICKY BIT IS NEEDED
    --------------------------------------------------

        Without sticky bit:
            - Any user with write permission on a directory
              can delete other users' files.

        With sticky bit:
            - Users can create files
            - But cannot delete files created by others


    --------------------------------------------------
    REAL-WORLD EXAMPLE (/tmp DIRECTORY)
    --------------------------------------------------

        /tmp directory permissions:

            drwxrwxrwt 10 root root /tmp

        Explanation:
            d    → directory
            rwx  → owner permissions
            rwx  → group permissions
            rwt  → others permissions
                   (t indicates sticky bit)


    --------------------------------------------------
    PRACTICAL EXAMPLE
    --------------------------------------------------

        Create a shared directory:

            mkdir /shared
            chmod 777 /shared

        Set sticky bit:

            chmod +t /shared

        Check permissions:

            ls -ld /shared

        Output:

            drwxrwxrwt /shared

        Behavior:
            - All users can create files
            - Users cannot delete files created by others


    --------------------------------------------------
    HOW TO SET STICKY BIT
    --------------------------------------------------

        Using symbolic method:

            chmod +t directory_name

        Using numeric method:

            chmod 1777 directory_name

        Note:
            1 → sticky bit
            7 → rwx permissions


    --------------------------------------------------
    INTERVIEW ONE-LINER
    --------------------------------------------------

        Sticky bit is a special directory permission
        that allows users to create files but prevents
        them from deleting or modifying files owned
        by other users, commonly used on /tmp.


WHAT ARE REGULAR EXPRESSIONS AND HOW IT IS USED ?


    REGULAR EXPRESSIONS (REGEX)

        Regular expressions (regex) are patterns used
        to search, match, and manipulate text.

        They are commonly used in:
            - Linux commands (grep, sed, awk)
            - Programming languages
            - Log analysis
            - Input validation


    --------------------------------------------------
    SIMPLE MEANING
    --------------------------------------------------

        Regex is a way to describe:
            "What kind of text I am looking for"

        Instead of matching exact words,
        regex matches patterns.


    --------------------------------------------------
    BASIC REGEX EXAMPLES
    --------------------------------------------------

        Match a word:

            linux

        - Matches the word "linux" anywhere in text


        Match digits:

            [0-9]

        - Matches any single digit (0 to 9)


        Match lowercase letters:

            [a-z]

        - Matches any lowercase letter


        Match uppercase letters:

            [A-Z]

        - Matches any uppercase letter


    --------------------------------------------------
    COMMON REGEX SYMBOLS (VERY IMPORTANT)
    --------------------------------------------------

        .   → Matches any single character
        *   → Matches zero or more occurrences
        +   → Matches one or more occurrences
        ?   → Matches zero or one occurrence
        ^   → Start of line
        $   → End of line


    --------------------------------------------------
    PRACTICAL EXAMPLES WITH GREP
    --------------------------------------------------

        Find lines containing "error":

            grep "error" logfile.txt


        Find lines starting with "root":

            grep "^root" /etc/passwd


        Find lines ending with ".log":

            grep "\.log$" file.txt


        Find lines containing numbers:

            grep "[0-9]" file.txt


    --------------------------------------------------
    REAL-WORLD USE CASES
    --------------------------------------------------

        - Search errors in logs
        - Validate email or phone number format
        - Extract IP addresses
        - Filter configuration files
        - Find specific patterns in large files


    --------------------------------------------------
    INTERVIEW ONE-LINER
    --------------------------------------------------

        Regular expressions are patterns used to
        search and match text, commonly used with
        tools like grep, sed, and awk for text
        processing and log analysis.




