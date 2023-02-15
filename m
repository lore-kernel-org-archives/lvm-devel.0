From: David Teigland <teigland@sourceware.org>
Date: Wed, 15 Feb 2023 22:02:39 +0000 (GMT)
Subject: main - pvscan: remove warning about excluded root dev
Message-ID: <20230215220239.004733858C31@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=08265641f3a8590f7bb41c92af65e572cdc8d099
Commit:        08265641f3a8590f7bb41c92af65e572cdc8d099
Parent:        bd05318ba2fc588be6339f5dc61f09195996b0e9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 15 10:21:13 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 15 10:21:13 2023 -0600

pvscan: remove warning about excluded root dev

This was trying to warn about a misconfig where the root PV
was excluded by the devices file, but it wasn't covering all
cases.  Also, it's not very useful because the root LV is
usually activated directly in the initrd.
---
 tools/pvscan.c | 29 -----------------------------
 1 file changed, 29 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index b834dfd4c..8f51a0b42 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1355,29 +1355,6 @@ static int _pvscan_cache_all(struct cmd_context *cmd, int argc, char **argv,
 	return 1;
 }
 
-/*
- * If /dev/sda* of /dev/vda* is excluded by the devices file
- * it's usually a misconfiguration that prevents proper booting,
- * so make it a special case to give extra info to help debugging.
- */
-static void _warn_excluded_root(struct cmd_context *cmd, struct device *dev)
-{
-	struct dev_use *du;
-	const char *cur_idname;
-
-	if (!(du = get_du_for_devname(cmd, dev_name(dev)))) {
-		log_warn("WARNING: no autoactivation for %s: not found in system.devices.", dev_name(dev));
-		return;
-	}
-
-	cur_idname = device_id_system_read(cmd, dev, du->idtype);
-
-	log_warn("WARNING: no autoactivation for %s: system.devices %s current %s.",
-		 dev_name(dev), du->idname, cur_idname ?: "missing device id");
-
-	free((void*) cur_idname);
-}
-
 static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 			      struct dm_list *complete_vgnames)
 {
@@ -1523,12 +1500,6 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 			log_print_pvscan(cmd, "%s excluded: %s.",
 					 dev_name(devl->dev), dev_filtered_reason(devl->dev));
 			dm_list_del(&devl->list);
-
-			/* Special case warning when probable root dev is missing from system.devices */
-			if ((devl->dev->filtered_flags & DEV_FILTERED_DEVICES_FILE) &&
-			    (!strncmp(dev_name(devl->dev), "/dev/sda", 8) ||
-			     !strncmp(dev_name(devl->dev), "/dev/vda", 8)))
-				_warn_excluded_root(cmd, devl->dev);
 		}
 	}
 

