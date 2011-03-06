From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 6 Mar 2011 18:28:09 -0000
Subject: LVM2/test t-pvcreate-usage.sh
Message-ID: <20110306182809.27045.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-03-06 18:28:09

Modified files:
	test           : t-pvcreate-usage.sh 

Log message:
	Fix test for 8k page (fails on Sparc architecture).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/test/t-pvcreate-usage.sh	2011/02/25 14:12:14	1.19
+++ LVM2/test/t-pvcreate-usage.sh	2011/03/06 18:28:09	1.20
@@ -106,9 +106,10 @@
 check pv_field $dev1 pe_start 200.00k
 
 # metadata area start is aligned according to pagesize
-# pagesize should be 64k or 4k ...
 if [ $PAGESIZE -eq 65536 ] ; then
 	pv_align="192.50k"
+elif [ $PAGESIZE -eq 8192 ] ; then
+	pv_align="136.50k"
 else
 	pv_align="133.00k"
 fi


