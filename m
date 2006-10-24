From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Oct 2006 17:09:41 -0000
Subject: LVM2/man lvchange.8
Message-ID: <20061024170941.14671.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-10-24 17:09:41

Modified files:
	man            : lvchange.8 

Log message:
	reword --resync desc a bit

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvchange.8.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/man/lvchange.8	2006/10/23 23:03:55	1.9
+++ LVM2/man/lvchange.8	2006/10/24 17:09:40	1.10
@@ -42,12 +42,12 @@
 allocated physical extents are already contiguous.
 .TP
 .I \-\-forcesync
-This option only make sense if the logical volume being operated
-on is a mirrored logical volume.  This option is used to
-resynchronize the devices in a mirrored logical volume.  Since
-resynchronization can take considerable time and resources, you
-should consider using this option only if you have reason to
-believe that the devices in your mirror are no longer the same.
+Forces the complete resynchronization of a mirror.  In normal
+circumstances you should not need this option because synchronization
+happens automatically.  Data is read from the primary mirror device
+and copied to the others, so this can take a considerable amount of
+time - and during this time you are without a complete redundant copy
+of your data.
 .TP
 .I \-\-minor minor
 Set the minor number.


