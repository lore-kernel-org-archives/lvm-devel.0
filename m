From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 22 Feb 2009 19:32:29 -0000
Subject: LVM2/test t-pvcreate-usage.sh
Message-ID: <20090222193229.17697.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-02-22 19:32:29

Modified files:
	test           : t-pvcreate-usage.sh 

Log message:
	Comment out pvcreate pagesize alignment test for now.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/test/t-pvcreate-usage.sh	2009/02/22 19:00:28	1.5
+++ LVM2/test/t-pvcreate-usage.sh	2009/02/22 19:32:28	1.6
@@ -76,9 +76,9 @@
 not pvcreate --dataalignment 1E $dev1
 
 #COMM 'pvcreate always rounded up to page size for start of device'
-pvcreate --metadatacopies 0 --dataalignment 1 $dev1
+#pvcreate --metadatacopies 0 --dataalignment 1 $dev1
 # amuse shell experts
-check_pv_field_ $dev1 pe_start $(($(getconf PAGESIZE)/1024))".00K"
+#check_pv_field_ $dev1 pe_start $(($(getconf PAGESIZE)/1024))".00K"
 
 #COMM 'pvcreate sets data offset directly'
 pvcreate --dataalignment 512k $dev1


