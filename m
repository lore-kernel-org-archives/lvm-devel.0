From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 21 May 2007 16:23:17 -0400
Subject: [PATCH] Fix vgrename man page to include UUID and be more consistent with lvrename.
Message-ID: <1179778997.3452.8.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix vgrename man page to include UUID and be more consistent with lvrename.
Index: LVM2/WHATS_NEW
===================================================================
--- LVM2.orig/WHATS_NEW	2007-05-21 06:52:01.000000000 -0400
+++ LVM2/WHATS_NEW	2007-05-21 16:10:25.000000000 -0400
@@ -1,5 +1,6 @@
 Version 2.02.26 -
 =================================
+  Fix vgrename man page to include UUID and be consistent with lvrename.
   Add (experimental) OpenAIS support to clvmd.
   Remove symlinks if parent volume is deactivated.
   Fix and clarify vgsplit error messages.
Index: LVM2/man/vgrename.8
===================================================================
--- LVM2.orig/man/vgrename.8	2002-11-18 09:02:24.000000000 -0500
+++ LVM2/man/vgrename.8	2007-05-21 15:03:41.000000000 -0400
@@ -8,11 +8,15 @@ vgrename \- rename a volume group
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



