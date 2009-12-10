From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 10 Dec 2009 22:06:15 -0000
Subject: LVM2/test t-mirror-lvconvert.sh
Message-ID: <20091210220615.13274.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2009-12-10 22:06:15

Modified files:
	test           : t-mirror-lvconvert.sh 

Log message:
	s/=/==/  Typo was causing sub test to always return success.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/test/t-mirror-lvconvert.sh	2009/08/02 21:59:21	1.11
+++ LVM2/test/t-mirror-lvconvert.sh	2009/12/10 22:06:15	1.12
@@ -87,7 +87,7 @@
 {
   local lv=$1
   local mlog=$(lvs --noheadings -omirror_log $lv | sed -e 's/ //g')
-  [ "$(basename $lv)_mlog" = "$mlog" ]
+  [ "$(basename $lv)_mlog" == "$mlog" ]
 }
 
 wait_conversion_()


