From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Sep 2008 17:50:57 -0000
Subject: LVM2/test t-lvcreate-usage.sh
Message-ID: <20080930175057.19214.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-09-30 17:50:56

Modified files:
	test           : t-lvcreate-usage.sh 

Log message:
	Fix a syntax error in one of the scripts, introduced by last commit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-usage.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/test/t-lvcreate-usage.sh	2008/09/30 17:47:34	1.7
+++ LVM2/test/t-lvcreate-usage.sh	2008/09/30 17:50:56	1.8
@@ -50,5 +50,5 @@
 # 'lvcreate rejects an invalid stripe size'
 not lvcreate -L 64M -n $lv -i2 --stripesize 3 $vg 2>err
 grep "^  Invalid stripe size 3\.00 KB\$" err
-case $(lvdisplay $vg) in "") true ;; *) false ;; esac'
+case $(lvdisplay $vg) in "") true ;; *) false ;; esac
 


