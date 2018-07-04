From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 4 Jul 2018 07:41:56 -0400
Subject: 2018-06-01-stable - vcfgrestore: add prompt with active volumes
Message-ID: <201807041141.w64Bfu4V019129@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=99cddd67a9dfcd6400640ac8ebf8d6d568ce19d6
Commit:        99cddd67a9dfcd6400640ac8ebf8d6d568ce19d6
Parent:        814dd84e0769da568232a19f798baf24b8a26127
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 22 18:45:48 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 4 13:40:50 2018 +0200

vcfgrestore: add prompt with active volumes

Add check for active device with names matching restored VG.
When such devices are present in dm table, prompt user, if he
wish to continue.
---
 WHATS_NEW            |    1 +
 tools/vgcfgrestore.c |   75 +++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 75 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d2142fc..ff0746e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.180 - 
 =================================
+  Enhance vgcfgrestore to check for active LVs in restored VG.
   lvconvert: provide possible layouts between linear and striped/raid
   Fix unmonitoring of merging snapshots.
   Add missing -l description in fsadm man page.
diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index e9f1a4c..48a2fa4 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -15,11 +15,69 @@
 
 #include "tools.h"
 #include "lvmetad-client.h"
+#include "dm-ioctl.h"
+
+/*
+ * Check if there are any active volumes from restored vg_name.
+ * We can prompt user, as such operation may make some serious
+ * troubles later, when user will try to continue such devices.
+ */
+static int _check_all_dm_devices(const char *vg_name, unsigned *found)
+{
+	struct dm_task *dmt;
+	struct dm_names *names;
+	char vgname_buf[DM_NAME_LEN * 2];
+	char *vgname, *lvname, *lvlayer;
+	unsigned next = 0;
+	int r = 1;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_LIST)))
+		return_0;
+
+	if (!dm_task_run(dmt)) {
+		r = 0;
+		goto_out;
+	}
+
+	if (!(names = dm_task_get_names(dmt))) {
+		r = 0;
+		goto_out;
+	}
+
+	if (!names->dev) {
+		log_verbose("No devices found.");
+		goto out;
+	}
+
+	do {
+		/* TODO: Do we want to validate UUID LVM- prefix as well ? */
+		names = (struct dm_names *)((char *) names + next);
+		if (!dm_strncpy(vgname_buf, names->name, sizeof(vgname_buf))) {
+			r = 0;
+			goto_out;
+		}
+		vgname = vgname_buf;
+		if (!dm_split_lvm_name(NULL, NULL, &vgname, &lvname, &lvlayer)) {
+			r = 0;
+			goto_out;
+		}
+		if (strcmp(vgname, vg_name) == 0) {
+			log_print("Volume group %s has active volume: %s.", vgname, lvname);
+			(*found)++;
+		}
+		next = names->next;
+	} while (next);
+
+out:
+	dm_task_destroy(dmt);
+	return r;
+}
 
 int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 {
 	const char *vg_name = NULL;
 	int lvmetad_rescan = 0;
+	unsigned found = 0;
 	int ret;
 
 	if (argc == 1) {
@@ -47,6 +105,21 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_PROCESSED;
 	}
 
+	if (!_check_all_dm_devices(vg_name, &found)) {
+		log_warn("WARNING: Failed to check for active volumes in volume group \"%s\".", vg_name);
+	} else if (found) {
+		log_warn("WARNING: Found %u active volume(s) in volume group \"%s\".",
+			 found, vg_name);
+		log_print("Restoring VG with active LVs, may cause mismatch with its metadata.");
+		if (!arg_is_set(cmd, yes_ARG) &&
+		    yes_no_prompt("Do you really want to proceed with restore of volume group \"%s\", "
+				  "while %u volume(s) are active? [y/n]: ",
+				  vg_name, found) == 'n') {
+			log_error("Restore aborted.");
+			return ECMD_FAILED;
+		}
+	}
+
 	/*
 	 * lvmetad does not handle a VG being restored, which would require
 	 * vg_remove of the existing VG, then vg_update of the restored VG.  A


