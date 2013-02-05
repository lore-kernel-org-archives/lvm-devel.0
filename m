From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 05 Feb 2013 12:44:17 -0600
Subject: [PATCH - v2] Fix circular dependency when attempting vgimport on VG with missing PVs
In-Reply-To: <1360019061.27780.3.camel@f16>
References: <1360019061.27780.3.camel@f16>
Message-ID: <1360089857.2284.1.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch makes the user supply '--force' in order to import volume
groups with missing PVs.

 brassow

TOOLS: Fix inablility to vgimport VGs with missing PVs

When there are missing PVs in a volume group, most operations that alter
the LVM metadata are disallowed.  It turns out that 'vgimport' is one of
those disallowed operations.  This is bad because it creates a circular
dependency.  'vgimport' will complain that the VG is inconsistent and that
'vgreduce --removemissing' must be run.  However, 'vgreduce' cannot be run
because it has not been imported.  Therefore, 'vgimport' must be one of
the operations allowed to change the metadata when PVs are missing.

Index: lvm2/tools/vgimport.c
===================================================================
--- lvm2.orig/tools/vgimport.c
+++ lvm2/tools/vgimport.c
@@ -68,6 +68,23 @@ int vgimport(struct cmd_context *cmd, in
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
Index: lvm2/man/vgimport.8.in
===================================================================
--- lvm2.orig/man/vgimport.8.in
+++ lvm2/man/vgimport.8.in
@@ -20,6 +20,9 @@ See \fBlvm\fP(8) for common options.
 .TP
 .BR \-a ", " \-\-all
 Import all exported Volume Groups.
+.TP
+.BR \-\-force
+Import exported Volume Groups even if there are missing Physical Volumes.
 .SH SEE ALSO
 .BR lvm (8),
 .BR pvscan (8),



