From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jun 2011 09:17:49 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110630091749.20053.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-30 09:17:49

Modified files:
	test/lib       : aux.sh 

Log message:
	use remove -f

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.24&r2=1.25

--- LVM2/test/lib/aux.sh	2011/06/30 09:15:53	1.24
+++ LVM2/test/lib/aux.sh	2011/06/30 09:17:49	1.25
@@ -117,7 +117,7 @@
 			dmsetup info -c | grep ^$COMMON_PREFIX
 			for dm in $STRAY_DEVS ; do
 				echo dmsetup remove $dm
-				dmsetup remove $dm || true
+				dmsetup remove -f $dm || true
 			done
 			NUM_REMAINING_DEVS=$NUM_DEVS
 		done


