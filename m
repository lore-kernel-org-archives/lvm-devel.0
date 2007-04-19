From: bmr@sourceware.org <bmr@sourceware.org>
Date: 19 Apr 2007 23:06:05 -0000
Subject: LVM2/scripts lvm_dump.sh
Message-ID: <20070419230605.9153.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	bmr at sourceware.org	2007-04-20 00:06:05

Modified files:
	scripts        : lvm_dump.sh 

Log message:
	re-commit lvm_dump.sh change

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm_dump.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/scripts/lvm_dump.sh	2006/11/23 17:23:14	1.3
+++ LVM2/scripts/lvm_dump.sh	2007/04/19 23:06:05	1.4
@@ -147,7 +147,7 @@
 log "$CP -a /etc/lvm $dir/lvm 2>> $log"
 
 myecho "Gathering /dev listing..."
-log "$LS -la /dev > $dir/dev_listing 2>> $log"
+log "$LS -laR /dev > $dir/dev_listing 2>> $log"
 
 if (( $metadata )); then
 	myecho "Gathering LVM metadata from Physical Volumes..."


