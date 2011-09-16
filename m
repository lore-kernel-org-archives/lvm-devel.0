From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 16 Sep 2011 14:32:48 -0000
Subject: LVM2/test t-lvcreate-large.sh
Message-ID: <20110916143248.25236.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-09-16 14:32:47

Modified files:
	test           : t-lvcreate-large.sh 

Log message:
	Disable t-lvcreate-large.sh for now with cluster.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-large.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/t-lvcreate-large.sh	2011/09/15 15:26:40	1.1
+++ LVM2/test/t-lvcreate-large.sh	2011/09/16 14:32:47	1.2
@@ -13,6 +13,9 @@
 
 . lib/test
 
+# FIXME: remove it later when locking in virtual origin is fixed
+test -e LOCAL_CLVMD && exit 200
+
 aux prepare_vg 4
 
 lvcreate -s -l 100%FREE -n $lv $vg --virtualsize 1024T


