From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Sep 2011 18:40:52 -0000
Subject: LVM2/test/api percent.sh
Message-ID: <20110919184052.17903.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-19 18:40:52

Modified files:
	test/api       : percent.sh 

Log message:
	Another vgremove for speedup
	
	It seems like test-suite is significantly slowed down on removal phase.
	
	Maybe it should be part of generic teardown - though the reason of slowdown
	should be also discovered -  probably related to retry loop ?

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/percent.sh.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/test/api/percent.sh	2011/06/09 18:58:01	1.6
+++ LVM2/test/api/percent.sh	2011/09/19 18:40:51	1.7
@@ -24,3 +24,5 @@
 lvcreate -m 1 -n mirr $vg -l 1 --mirrorlog core
 lvs $vg
 aux apitest percent $vg
+
+vgremove -ff $vg


