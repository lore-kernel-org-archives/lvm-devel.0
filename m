From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 2 Jun 2011 09:08:16 -0000
Subject: LVM2/scripts lvmdump.sh
Message-ID: <20110602090816.13092.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-06-02 09:08:16

Modified files:
	scripts        : lvmdump.sh 

Log message:
	Use append but except query for dlm locks:-)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvmdump.sh.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/scripts/lvmdump.sh	2011/06/02 09:02:03	1.17
+++ LVM2/scripts/lvmdump.sh	2011/06/02 09:08:16	1.18
@@ -146,7 +146,7 @@
 	echo "----------------------------------"
 	if [ -f /proc/cluster/dlm_locks ]
 	then
-		echo clvmd >> /proc/cluster/dlm_locks
+		echo clvmd > /proc/cluster/dlm_locks
 		cat /proc/cluster/dlm_locks
 		echo
 		echo "RESOURCE DIR:"


