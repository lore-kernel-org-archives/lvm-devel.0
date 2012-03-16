From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 16 Mar 2012 11:36:51 -0000
Subject: LVM2/test/shell activate-minor.sh
Message-ID: <20120316113651.24427.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-03-16 11:36:51

Modified files:
	test/shell     : activate-minor.sh 

Log message:
	Relax the active-minor test a bit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/activate-minor.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/test/shell/activate-minor.sh	2012/03/16 10:43:52	1.1
+++ LVM2/test/shell/activate-minor.sh	2012/03/16 11:36:51	1.2
@@ -16,4 +16,4 @@
 lvchange $vg/foo -My --major=255 --minor=123
 lvchange $vg/foo -a y
 dmsetup info $vg-foo | tee info
-grep "254, 123" info
+egrep "^Major, minor: *[0-9]+, 123" info


