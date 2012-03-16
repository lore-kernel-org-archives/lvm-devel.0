From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 16 Mar 2012 19:09:50 -0000
Subject: LVM2/test/lib utils.sh
Message-ID: <20120316190950.21492.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-16 19:09:49

Modified files:
	test/lib       : utils.sh 

Log message:
	Regression fix kernel version check
	
	got changed improperly with large update patch.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/utils.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/test/lib/utils.sh	2012/03/16 12:59:43	1.9
+++ LVM2/test/lib/utils.sh	2012/03/16 19:09:49	1.10
@@ -173,7 +173,7 @@
 
 	local minor2=$(uname -r | cut -d. -f3 | cut -d- -f1)
 	test -z "$minor2" -a $3 -ne 0 && return 1
-	test $minor2 -lt $3 2>/dev/null || return 1
+	test $minor2 -ge $3 2>/dev/null || return 1
 }
 
 prepare_test_vars() {


