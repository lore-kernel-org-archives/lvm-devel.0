From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 21 Feb 2013 14:55:37 +0000 (UTC)
Subject: master - vgimport: Allow '--force' to import VGs with missing PVs.
Message-ID: <20130221145537.C090DA1045@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3ab46449f4dbcc45fe878149838a8439f5ac8b34
Commit:        3ab46449f4dbcc45fe878149838a8439f5ac8b34
Parent:        303e86adc8dbbab2fe78412f1b90021e5bdb5bc3
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Feb 20 16:28:26 2013 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Feb 20 16:37:41 2013 -0600

vgimport:  Allow '--force' to import VGs with missing PVs.

When there are missing PVs in a volume group, most operations that alter
the LVM metadata are disallowed.  It turns out that 'vgimport' is one of
those disallowed operations.  This is bad because it creates a circular
dependency.  'vgimport' will complain that the VG is inconsistent and that
'vgreduce --removemissing' must be run.  However, 'vgreduce' cannot be run
because it has not been imported.  Therefore, 'vgimport' must be one of
the operations allowed to change the metadata when PVs are missing.  The
'--force' option is the way to make 'vgimport' happen in spite of the
missing PVs.
---
 WHATS_NEW         |    1 +
 man/vgimport.8.in |    5 +++++
 tools/vgimport.c  |   17 +++++++++++++++++
 3 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 82cbfc9..613ec3d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  vgimport '--force' now allows users to import VGs with missing PVs.
   Fix PV alignment to incorporate alignment offset if the PV has zero MDAs.
   Allow remove/replace of RAID sub-LVs that are composed of error targets.
   Make 'vgreduce --removemissing' able to handle RAID LVs with missing PVs.
diff --git a/man/vgimport.8.in b/man/vgimport.8.in
index dd781de..9496d40 100644
--- a/man/vgimport.8.in
+++ b/man/vgimport.8.in
@@ -20,6 +20,11 @@ See \fBlvm\fP(8) for common options.
 .TP
 .BR \-a ", " \-\-all
 Import all exported Volume Groups.
+.TP
+.BR \-\-force
+Import exported Volume Groups even if there are missing Physical Volumes.
+This option should only be used if the missing devices are known to have
+failed and they cannot be restored.
 .SH SEE ALSO
 .BR lvm (8),
 .BR pvscan (8),
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 5badcb5..20cae6c 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -68,6 +68,23 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
+	if (arg_count(cmd, force_ARG)) {
+		/*
+		 * The volume group cannot be repaired unless it is first
+		 * imported.  If we don't allow the user a way to import the
+		 * VG while it is 'partial', then we will have created a
+		 * circular dependency.
+		 *
+		 * The reason we don't just simply set 'handles_missing_pvs'
+		 * by default is that we want to guard against the case
+		 * where the user simply forgot to move one or more disks in
+		 * the VG before running 'vgimport'.
+		 */
+		log_print("'--force' supplied.  Volume groups with missing PVs"
+			  " will be imported.");
+		cmd->handles_missing_pvs = 1;
+	}
+
 	return process_each_vg(cmd, argc, argv,
 			       READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
 			       NULL,


