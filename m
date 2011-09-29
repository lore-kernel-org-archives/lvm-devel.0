From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Sep 2011 08:58:28 -0000
Subject: LVM2/test t-clvmd-restart.sh
Message-ID: <20110929085828.17291.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-29 08:58:27

Modified files:
	test           : t-clvmd-restart.sh 

Log message:
	Let the utils to prepare PVs

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-clvmd-restart.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/t-clvmd-restart.sh	2011/09/26 07:51:24	1.2
+++ LVM2/test/t-clvmd-restart.sh	2011/09/29 08:58:27	1.3
@@ -19,7 +19,7 @@
 test -e LOCAL_CLVMD || skip
 read LOCAL_CLVMD < LOCAL_CLVMD
 
-aux prepare_devs 1
+aux prepare_pvs 1
 
 vgcreate --clustered y $vg $(cat DEVICES)
 


