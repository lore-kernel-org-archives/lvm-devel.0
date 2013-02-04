From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 04 Feb 2013 17:04:21 -0600
Subject: [PATCH] Fix circular dependency when attempting vgimport on VG with missing PVs
Message-ID: <1360019061.27780.3.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Is there any reason why 'vgimport' should not be allowed to alter the
metadata in order to import a VG with missing PVs?  I can't think of
any.

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
@@ -68,6 +68,15 @@ int vgimport(struct cmd_context *cmd, in
 		return ECMD_FAILED;
 	}
 
+	/*
+	 * Allow a VG to be imported even when there are missing PVs.  If
+	 * we don't, a circular dependency is created.  The vgimport will
+	 * complain that the VG is not consistent and 'vgreduce --removemissing'
+	 * should be used.  However, 'vgreduce' cannot be used because the
+	 * VG hasn't been imported.
+	 */
+	cmd->handles_missing_pvs = 1;
+
 	return process_each_vg(cmd, argc, argv,
 			       READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
 			       NULL,



