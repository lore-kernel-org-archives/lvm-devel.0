From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Jan 2011 11:05:28 -0000
Subject: LVM2/test t-lock-blocking.sh
Message-ID: <20110113110528.15519.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-13 11:05:27

Modified files:
	test           : t-lock-blocking.sh 

Log message:
	Check for file with clvmd pid
	
	Instead of checking  $LOCAL_CLVMD set during some 'aux' execution which
	doesn't seem to be propagated to this shell - check for existance of pid
	file of clvmd process - so this test is skipped in singlenode cluster test.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lock-blocking.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/t-lock-blocking.sh	2011/01/05 00:16:20	1.3
+++ LVM2/test/t-lock-blocking.sh	2011/01/13 11:05:27	1.4
@@ -14,7 +14,7 @@
 . lib/test
 
 aux prepare_devs 3
-test -n "$LOCAL_CLVMD" && exit 200
+test -e LOCAL_CLVMD && exit 200
 pvcreate $dev1 $dev2
 vgcreate $vg $dev1 $dev2
 


