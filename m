From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 17 Jul 2008 04:03:04 -0000
Subject: LVM2/test t-vgsplit-usage.sh
Message-ID: <20080717040304.32437.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-07-17 04:03:04

Modified files:
	test           : t-vgsplit-usage.sh 

Log message:
	Only use lvm2 metadata for now.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-usage.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/t-vgsplit-usage.sh	2008/07/17 03:17:01	1.6
+++ LVM2/test/t-vgsplit-usage.sh	2008/07/17 04:03:04	1.7
@@ -38,7 +38,7 @@
    lv2=$(this_test_)-test-lv2-$$          &&
    lv3=$(this_test_)-test-lv3-$$'
 
-for mdatype in 1 2
+for mdatype in 2
 do
 test_expect_success \
   "(lvm$mdatype) setup PVs" \


