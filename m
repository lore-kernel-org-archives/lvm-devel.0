From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 22 May 2007 02:51:35 -0000
Subject: LVM2 ./WHATS_NEW man/vgrename.8
Message-ID: <20070522025135.5826.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-05-22 02:51:34

Modified files:
	.              : WHATS_NEW 
	man            : vgrename.8 

Log message:
	Fix vgrename man page to include UUID and be more consistent with lvrename.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.619&r2=1.620
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgrename.8.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2007/05/21 10:52:01	1.619
+++ LVM2/WHATS_NEW	2007/05/22 02:51:33	1.620
@@ -1,5 +1,6 @@
 Version 2.02.26 -
 =================================
+  Fix vgrename man page to include UUID and be consistent with lvrename.
   Add (experimental) OpenAIS support to clvmd.
   Remove symlinks if parent volume is deactivated.
   Fix and clarify vgsplit error messages.
--- LVM2/man/vgrename.8	2002/11/18 14:02:24	1.2
+++ LVM2/man/vgrename.8	2007/05/22 02:51:33	1.3
@@ -8,11 +8,15 @@
 [\-h/\-?/\-\-help]
 [\-t/\-\-test]
 [\-v/\-\-verbose]
-OldVolumeGroupPath/\-Name NewVolumeGroupPath/\-Name
+.IR OldVolumeGroup { Path | Name | UUID }
+.IR NewVolumeGroup { Path | Name }
 .SH DESCRIPTION
 vgrename renames an existing (see
 .B vgcreate(8)
-) volume group.
+) volume group from
+.IR OldVolumeGroup { Name | Path | UUID }
+to
+.IR NewVolumeGroup { Name | Path }.
 .SH OPTIONS
 See \fBlvm\fP for common options.
 .SH Examples
@@ -20,6 +24,9 @@
 volume group "vg02" to "my_volume_group".
 .TP
 "vgrename vg02 my_volume_group" does the same.
+.TP
+"vgrename Zvlifi-Ep3t-e0Ng-U42h-o0ye-KHu1-nl7Ns4 VolGroup00_tmp" renames a volume group with UUID Zvlifi-Ep3t-e0Ng-U42h-o0ye-KHu1-nl7Ns4 to the volume group named "VolGroup00_tmp".  Using the UUID option to name a volume group may be useful in cases where one machine has two physical volumes, each with the same volume group name, but a separate volume group UUID (this situation will cause error messages with lvm commands).  One way duplicate volume group names occur is if an old disk with a root volume is moved to a new machine with its own root volume.  In this case, both volume groups may have the same name (for example, "VolGroup00"), but different UUIDs.
+.TP
 .SH SEE ALSO
 .BR lvm (8), 
 .BR vgchange (8), 


