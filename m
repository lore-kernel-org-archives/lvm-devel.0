From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Apr 2012 15:24:48 -0000
Subject: LVM2 ./WHATS_NEW man/lvm.8.in
Message-ID: <20120426152448.8914.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-04-26 15:24:47

Modified files:
	.              : WHATS_NEW 
	man            : lvm.8.in 

Log message:
	Remove statement that snapshots cannot be tagged from lvm man page.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2393&r2=1.2394
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.8.in.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2012/04/25 13:38:41	1.2393
+++ LVM2/WHATS_NEW	2012/04/26 15:24:46	1.2394
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Remove statement that snapshots cannot be tagged from lvm man page.
   Disallow changing cluster attribute of VG while RAID LVs are active.
   Fix lvconvert error message for non-mergeable volumes.
   Allow subset of failed devices to be replaced in RAID LVs.
--- LVM2/man/lvm.8.in	2012/04/11 12:42:10	1.10
+++ LVM2/man/lvm.8.in	2012/04/26 15:24:46	1.11
@@ -223,7 +223,6 @@
 Only the new LVM2 metadata format supports tagging: objects using the
 LVM1 metadata format cannot be tagged because the on-disk format does not
 support it.
-Snapshots cannot be tagged.
 Characters allowed in tags are:
 .B A-Z a-z 0-9 _ + . -
 and as of version 2.02.78 the following characters are also accepted:


