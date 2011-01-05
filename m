From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 5 Jan 2011 00:38:43 -0000
Subject: LVM2/test t-pvcreate-operation-md.sh
Message-ID: <20110105003843.10092.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-01-05 00:38:41

Modified files:
	test           : t-pvcreate-operation-md.sh 

Log message:
	Fix typo in t-pvcreate-operation-md.sh.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation-md.sh.diff?cvsroot=lvm2&r1=1.11&r2=1.12

--- LVM2/test/t-pvcreate-operation-md.sh	2011/01/05 00:16:20	1.11
+++ LVM2/test/t-pvcreate-operation-md.sh	2011/01/05 00:38:41	1.12
@@ -20,7 +20,7 @@
 
 . lib/test
 
-prepare_lvmconf 'devices/filter = [ "a|/dev/md.*|", "a/dev\/mapper\/.*$/", "r/.*/" ]'
+aux lvmconf 'devices/filter = [ "a|/dev/md.*|", "a/dev\/mapper\/.*$/", "r/.*/" ]'
 aux prepare_devs 2
 
 # Have MD use a non-standard name to avoid colliding with an existing MD device


