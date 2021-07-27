From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jul 2021 22:50:39 +0000 (GMT)
Subject: main - debug: stack tracing on error path
Message-ID: <20210727225039.E4A6D385040A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d2a2dc2e41b38f1381746ec3aa946cc52d3d8f43
Commit:        d2a2dc2e41b38f1381746ec3aa946cc52d3d8f43
Parent:        3e2827f3b79b31fc8e7370f9064c0d206aa60897
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 27 22:52:23 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 28 00:49:28 2021 +0200

debug: stack tracing on error path

---
 tools/pvck.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index b15158746..4aab21cee 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -3074,14 +3074,14 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (!_get_settings(cmd, &set))
-		return ECMD_FAILED;
+		return_ECMD_FAILED;
 
 	if (arg_is_set(cmd, file_ARG) && (arg_is_set(cmd, repairtype_ARG) || arg_is_set(cmd, repair_ARG))) {
 		if (!(mf.filename = arg_str_value(cmd, file_ARG, NULL)))
-			return ECMD_FAILED;
+			return_ECMD_FAILED;
 
 		if (!_read_metadata_file(cmd, &mf))
-			return ECMD_FAILED;
+			return_ECMD_FAILED;
 	}
 
 	label_scan_setup_bcache();
@@ -3107,7 +3107,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 		 * reads in the filters and by _read_bytes for other disk structs.
 		 */
 		if (!dev_read_bytes(dev, 0, 4096, buf)) {
-	        	log_error("Failed to read the first 4096 bytes of device %s.", dev_name(dev));
+			log_error("Failed to read the first 4096 bytes of device %s.", dev_name(dev));
 			return ECMD_FAILED;
 		}
 
@@ -3142,7 +3142,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 			log_error("Unknown dump value.");
 
 		if (!ret)
-			return ECMD_FAILED;
+			return_ECMD_FAILED;
 		return ECMD_PROCESSED;
 	}
 
@@ -3161,7 +3161,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 			log_error("Unknown repair value.");
 
 		if (!ret)
-			return ECMD_FAILED;
+			return_ECMD_FAILED;
 		return ECMD_PROCESSED;
 	}
 
@@ -3171,10 +3171,10 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 		/* repair is a combination of repairtype pv_header+metadata */
 
 		if (!_repair_pv_header(cmd, "pv_header", &set, &mf, labelsector, dev))
-			return ECMD_FAILED;
+			return_ECMD_FAILED;
 
 		if (!_repair_metadata(cmd, "metadata", &set, &mf, labelsector, dev))
-			return ECMD_FAILED;
+			return_ECMD_FAILED;
 
 		return ECMD_PROCESSED;
 	}
@@ -3187,7 +3187,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	if (argc == 1)
 		setup_device(cmd, argv[0]);
 	else if (!setup_devices(cmd))
-		return ECMD_FAILED;
+		return_ECMD_FAILED;
 
 	for (i = 0; i < argc; i++) {
 		pv_name = argv[i];
@@ -3202,6 +3202,6 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (bad)
-		return ECMD_FAILED;
+		return_ECMD_FAILED;
 	return ECMD_PROCESSED;
 }


