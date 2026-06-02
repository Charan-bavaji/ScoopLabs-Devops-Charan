# Linux File Permissions Assignment

Problem Statement
Managing security and access to files in Linux using numeric (octal) permissions.

Explain what numeric permission 755 means for Owner, Group, and Others.
Create script.sh and set permissions so only the owner can execute it, but everyone can read it.


# Part 1: Understanding 755 Permissions

Each digit in 755 represents permissions for Owner, Group, and Others respectively.
Category  Digit  Permissions
Owner      7     Read + Write + Execute (rwx)
Group      5     Read + Execute (r-x)
Others     5     Read + Execute (r-x)

Full symbolic representation: -rwxr-xr-x
How the math works:

Read    (r) = 4
Write   (w) = 2
Execute (x) = 1

So:

7 = 4+2+1 → rwx (Owner can read, write, execute)
5 = 4+0+1 → r-x (Group can read and execute, NOT write)
5 = 4+0+1 → r-x (Others can read and execute, NOT write)


Part 2: Hands-on Task
Goal
Create script.sh and set permissions so that:

Owner: can read AND execute
Group: can only read
Others: can only read

This maps to permission 544:

5 = 4+1 → r-x (Owner: read + execute)
4 = 4   → r-- (Group: read only)
4 = 4   → r-- (Others: read only)


Steps Followed
Step 1: Create the file
touch script.sh
Step 2: Verify initial permissions
ls -l script.sh
Output: -rw-r--r-- 1 user user 0 Jun 2 2026 script.sh
Step 3: Apply new permissions using chmod
chmod 544 script.sh
Step 4: Verify the change
ls -l script.sh
Output: -r-xr--r-- 1 user user 0 Jun 2 2026 script.sh

chmod Commands Used
touch script.sh        # Create the file
chmod 544 script.sh    # Set permissions: owner=r+x, group=r, others=r
ls -l script.sh        # Verify the permissions

Output / Verification
-r-xr--r-- 1 user user 0 Jun  2 2026 script.sh
Breaking down -r-xr--r--:
Field     Meaning
-         Regular file
-x        Owner:read + execute (no write)
r--       Group: read only
r--       Others: read only
