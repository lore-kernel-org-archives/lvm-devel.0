From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 23 Sep 2011 19:21:53 -0000
Subject: LVM2/man lvs.8.in
Message-ID: <20110923192153.18763.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-23 19:21:53

Modified files:
	man            : lvs.8.in 

Log message:
	update man page for new RAID lv_attr characters.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.16&r2=1.17

--- LVM2/man/lvs.8.in	2011/09/09 01:15:18	1.16
+++ LVM2/man/lvs.8.in	2011/09/23 19:21:53	1.17
@@ -69,10 +69,11 @@
 .RS
 .IP 1 3
 Volume type: (m)irrored, (M)irrored without initial sync, (o)rigin,
-(O)rigin with merging snapshot, (s)napshot, merging (S)napshot, (p)vmove,
-(v)irtual, mirror (i)mage, mirror (I)mage out-of-sync, mirror (l)og device,
-under (c)onversion, thin (V)olume, (t)hin pool, (T)hin pool data, thin pool 
-m(e)tadata
+(O)rigin with merging snapshot, (r)aid, (R)aid without initial sync,
+(s)napshot, merging (S)napshot, (p)vmove, (v)irtual,
+mirror or raid (i)mage, mirror or raid (I)mage out-of-sync, mirror (l)og device,
+under (c)onversion, thin (V)olume, (t)hin pool, (T)hin pool data, raid or
+thin pool m(e)tadata
 .IP 2 3
 Permissions: (w)riteable, (r)ead-only
 .IP 3 3


