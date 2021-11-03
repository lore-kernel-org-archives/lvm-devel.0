From: David Teigland <teigland@sourceware.org>
Date: Wed,  3 Nov 2021 13:51:22 +0000 (GMT)
Subject: main - lvmdevices: increase open file limit
Message-ID: <20211103135122.6165F385842B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6ea8d975b23758e6e099bf51cf7334f27f9fd096
Commit:        6ea8d975b23758e6e099bf51cf7334f27f9fd096
Parent:        b5b0369e4decbd7e2b4a160ba8ebad4e8f8a4094
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 29 14:49:36 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 3 08:50:57 2021 -0500

lvmdevices: increase open file limit

---
 lib/label/label.c  | 4 ++--
 lib/label/label.h  | 2 ++
 tools/lvmdevices.c | 3 +++
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/lib/label/label.c b/lib/label/label.c
index 479a5037a..9fac3e464 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -891,7 +891,7 @@ static int _setup_bcache(void)
 
 #define BASE_FD_COUNT 32 /* Number of open files we want apart from devs */
 
-static void _prepare_open_file_limit(struct cmd_context *cmd, unsigned int num_devs)
+void prepare_open_file_limit(struct cmd_context *cmd, unsigned int num_devs)
 {
 #ifdef HAVE_PRLIMIT
 	struct rlimit old = { 0 }, new;
@@ -1165,7 +1165,7 @@ int label_scan(struct cmd_context *cmd)
 	 * which we want to keep open) is higher than the current
 	 * soft limit.
 	 */
-	_prepare_open_file_limit(cmd, dm_list_size(&scan_devs));
+	prepare_open_file_limit(cmd, dm_list_size(&scan_devs));
 
 	/*
 	 * Do the main scan.
diff --git a/lib/label/label.h b/lib/label/label.h
index 8b510eb79..34563efd0 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -134,4 +134,6 @@ void dev_invalidate(struct device *dev);
 void dev_set_last_byte(struct device *dev, uint64_t offset);
 void dev_unset_last_byte(struct device *dev);
 
+void prepare_open_file_limit(struct cmd_context *cmd, unsigned int num_devs);
+
 #endif
diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
index 8d9634848..3f104f7de 100644
--- a/tools/lvmdevices.c
+++ b/tools/lvmdevices.c
@@ -176,6 +176,9 @@ int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
 		log_error("Failed to read the devices file.");
 		return ECMD_FAILED;
 	}
+
+	prepare_open_file_limit(cmd, dm_list_size(&cmd->use_devices));
+
 	dev_cache_scan(cmd);
 	device_ids_match(cmd);
 


