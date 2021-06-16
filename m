From: David Teigland <teigland@sourceware.org>
Date: Wed, 16 Jun 2021 18:43:15 +0000 (GMT)
Subject: main - coverity cleanups
Message-ID: <20210616184315.449723855012@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=71cb54d92f96b8da318c8f8380e7ce0bdf0a11bf
Commit:        71cb54d92f96b8da318c8f8380e7ce0bdf0a11bf
Parent:        f70d97b91620bc7c2e5c5ccc39913c54379322c2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 16 13:22:54 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 16 13:42:51 2021 -0500

coverity cleanups

---
 lib/cache/lvmcache.c   | 5 +++++
 lib/device/device_id.c | 1 +
 tools/pvck.c           | 5 +++--
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 017134d7d..a798f5ab8 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -854,6 +854,11 @@ next:
 				dev_name(dev1), has_lv1 ? "is used for" : "is not used for",
 				dev_name(dev2), has_lv2 ? "is used for" : "is not used for");
 
+		free((void *)idname1);
+		free((void *)idname2);
+		idname1 = NULL;
+		idname2 = NULL;
+
 		change = 0;
 
 		if (prev_unchosen1 && !prev_unchosen2) {
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index f158e4f06..65912b9b6 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -1132,6 +1132,7 @@ id_done:
 
 			if (yes_no_prompt("Add device with duplicate PV to devices file?") == 'n') {
 				log_print("Device not added.");
+				free((void *)check_idname);
 				return 1;
 			}
 		}
diff --git a/tools/pvck.c b/tools/pvck.c
index aba6a9cc8..4e8814737 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -3053,7 +3053,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
-	if (arg_is_set(cmd, dump_ARG)) {
+	if ((dump = arg_str_value(cmd, dump_ARG, NULL))) {
 		struct stat sb;
 
 		pv_name = argv[0];
@@ -3121,7 +3121,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
-	if ((dump = arg_str_value(cmd, dump_ARG, NULL))) {
+	if (dump) {
 		cmd->use_hints = 0;
 
 		if (!strcmp(dump, "metadata"))
@@ -3145,6 +3145,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 		} else
 			log_error("Unknown dump value.");
 
+		free(def);
 		if (!ret)
 			return ECMD_FAILED;
 		return ECMD_PROCESSED;


