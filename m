From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 28 Mar 2012 07:46:38 -0000
Subject: LVM2/test/shell inconsistent-metadata.sh unlos ...
Message-ID: <20120328074638.20351.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-03-28 07:46:36

Modified files:
	test/shell     : inconsistent-metadata.sh unlost-pv.sh 

Log message:
	Fix tests to work with vgscan --cache fixing inconsistent metadata.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/inconsistent-metadata.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/unlost-pv.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/shell/inconsistent-metadata.sh	2012/03/16 13:00:06	1.3
+++ LVM2/test/shell/inconsistent-metadata.sh	2012/03/28 07:46:35	1.4
@@ -32,11 +32,12 @@
 	grep resized lvs.out | grep 8192
 }
 
-# vgscan fixes up metadata
+# vgscan fixes up metadata (needs --cache option for direct scan if lvmetad is used)
+test -e LOCAL_LVMETAD && cache="--cache"
 init
-vgscan 2>&1 | tee cmd.out
+vgscan $cache 2>&1 | tee cmd.out
 grep "Inconsistent metadata found for VG $vg" cmd.out
-vgscan 2>&1 | tee cmd.out
+vgscan $cache 2>&1 | tee cmd.out
 not grep "Inconsistent metadata found for VG $vg" cmd.out
 check
 
--- LVM2/test/shell/unlost-pv.sh	2012/03/16 13:00:06	1.2
+++ LVM2/test/shell/unlost-pv.sh	2012/03/28 07:46:35	1.3
@@ -12,9 +12,11 @@
 . lib/test
 
 check_() {
-	vgscan 2>&1 | tee vgscan.out
+	# vgscan needs --cache option for direct scan if lvmetad is used
+	test -e LOCAL_LVMETAD && cache="--cache"
+	vgscan $cache 2>&1 | tee vgscan.out
 	grep "Inconsistent metadata found for VG $vg" vgscan.out
-	vgscan 2>&1 | tee vgscan.out
+	vgscan $cache 2>&1 | tee vgscan.out
 	not grep "Inconsistent metadata found for VG $vg" vgscan.out
 }
 


