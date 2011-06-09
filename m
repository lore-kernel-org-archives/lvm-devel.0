From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Jun 2011 19:48:26 -0000
Subject: LVM2/test/lib utils.sh
Message-ID: <20110609194826.25066.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-06-09 19:48:26

Modified files:
	test/lib       : utils.sh 

Log message:
	Fix kernel version test (RHEL: 2.6.32-123).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/utils.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/test/lib/utils.sh	2011/06/09 18:58:01	1.5
+++ LVM2/test/lib/utils.sh	2011/06/09 19:48:26	1.6
@@ -162,8 +162,8 @@
     test $minor -lt $2 && return 1
     test -z "$3" && return 0
 
-    minor2=$(uname -r | cut -d. -f3)
-    test -z "$minor2" && return 0
+    minor2=$(uname -r | cut -d. -f3 | cut -d- -f1)
+    test -z "$minor2" -a $3 -ne 0 && return 1
     test $minor2 -ge $3 2>/dev/null && return 0
 
     return 1


