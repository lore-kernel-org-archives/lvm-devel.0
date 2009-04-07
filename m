From: Milan Broz <mbroz@redhat.com>
Date: Tue, 07 Apr 2009 13:04:50 +0200
Subject: [PATCH v2] Enable use of cached metadata for pvs & pvdisplay
In-Reply-To: <49D9E6F4.90205@redhat.com>
References: <49D9E6F4.90205@redhat.com>
Message-ID: <49DB3352.1060909@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

(reposted with fixed nested locking and use it for all pv reports)

Enable use of cached metadata for pvs & pvdisplay.

Currently PV commands, which performs full device scan, repeatly
re-reads PVs and scans for all devices.

Without vg private mempool this behaviour leads to OOM for large VG.

This patch allows using internal metadata cache for pvs & pvdisplay,
so the commands scan the PVs only once.
(We have to use VG_GLOBAL otherwise cache is invalidated on every
VG unlock in process_single PV call.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/commands.h |    4 ++--
 tools/toollib.c  |   30 ++++++++++++++++++++++--------
 2 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index da202c0..cd83d5e 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -497,7 +497,7 @@ xx(pvdata,
 
 xx(pvdisplay,
    "Display various attributes of physical volume(s)",
-   0,
+   CACHE_VGMETADATA,
    "pvdisplay\n"
    "\t[-c|--colon]\n"
    "\t[-d|--debug]\n"
@@ -571,7 +571,7 @@ xx(pvremove,
 
 xx(pvs,
    "Display information about physical volumes",
-   0,
+   CACHE_VGMETADATA,
    "pvs" "\n"
    "\t[--aligned]\n"
    "\t[-a|--all]\n"
diff --git a/tools/toollib.c b/tools/toollib.c
index 1a2fd01..8f6b0e1 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -631,6 +631,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 	int opt = 0;
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
+	int lock_global = lock_type != LCK_NONE;
 
 	struct pv_list *pvl;
 	struct physical_volume *pv;
@@ -643,6 +644,11 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 
 	dm_list_init(&tags);
 
+	if (lock_global && !lock_vol(cmd, VG_GLOBAL, lock_type)) {
+		log_error("Unable to obtain global lock.");
+		return ECMD_FAILED;
+	}
+
 	if (argc) {
 		log_verbose("Using physical volume(s) on command line");
 		for (; opt < argc; opt++) {
@@ -660,7 +666,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 						  dm_pool_strdup(cmd->mem,
 							      tagname))) {
 					log_error("strlist allocation failed");
-					return ECMD_FAILED;
+					goto bad;
 				}
 				continue;
 			}
@@ -714,7 +720,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 			if (ret > ret_max)
 				ret_max = ret;
 			if (sigint_caught())
-				return ret_max;
+				goto out;
 		}
 		if (!dm_list_empty(&tags) && (vgnames = get_vgnames(cmd, 0)) &&
 			   !dm_list_empty(vgnames)) {
@@ -748,7 +754,7 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 				if (ret > ret_max)
 					ret_max = ret;
 				if (sigint_caught())
-					return ret_max;
+					goto out;
 			}
 		}
 	} else {
@@ -760,17 +766,18 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 			if (ret > ret_max)
 				ret_max = ret;
 			if (sigint_caught())
-				return ret_max;
+				goto out;
 		} else if (arg_count(cmd, all_ARG)) {
 			ret = _process_all_devs(cmd, handle, process_single);
 			if (ret > ret_max)
 				ret_max = ret;
 			if (sigint_caught())
-				return ret_max;
+				goto out;
 		} else {
 			log_verbose("Scanning for physical volume names");
+
 			if (!(pvslist = get_pvs(cmd)))
-				return ECMD_FAILED;
+				goto bad;
 
 			dm_list_iterate_items(pvl, pvslist) {
 				ret = process_single(cmd, NULL, pvl->pv,
@@ -778,12 +785,19 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
 				if (ret > ret_max)
 					ret_max = ret;
 				if (sigint_caught())
-					return ret_max;
+					goto bad;
 			}
 		}
 	}
-
+out:
+	if (lock_global)
+		unlock_vg(cmd, VG_GLOBAL);
 	return ret_max;
+bad:
+	if (lock_global)
+		unlock_vg(cmd, VG_GLOBAL);
+
+	return ECMD_FAILED;
 }
 
 /*



