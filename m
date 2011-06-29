From: agk@sourceware.org <agk@sourceware.org>
Date: 29 Jun 2011 17:33:40 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110629173340.13063.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-29 17:33:40

Modified files:
	test/lib       : aux.sh 

Log message:
	remove any stray semaphores after tearing down devs

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/test/lib/aux.sh	2011/06/29 12:37:51	1.15
+++ LVM2/test/lib/aux.sh	2011/06/29 17:33:39	1.16
@@ -86,6 +86,9 @@
 	fi
 	rm -f DEVICES # devs is set in prepare_devs()
 	rm -f LOOP
+
+	# Delete any remaining dm/udev semaphores
+	dmsetup udevcomplete_all -y
 }
 
 teardown() {


