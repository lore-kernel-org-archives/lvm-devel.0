From: David Teigland <teigland@sourceware.org>
Date: Tue, 27 Oct 2020 20:47:38 +0000 (GMT)
Subject: master - pvck: fix dev filtering
Message-ID: <20201027204738.DEF323857C4D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5a94126e7a2824387c36d87f5ede97702a82cdda
Commit:        5a94126e7a2824387c36d87f5ede97702a82cdda
Parent:        c96645781ceb88c625dfae73e5baa08f1ce0e07e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 27 15:42:08 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Oct 27 15:43:15 2020 -0500

pvck: fix dev filtering

filters needing io weren't being run because bcache
wasn't set up.  Read the first 4k of the device
before doing filtering or reading ondisk structs to
reduce reads.
---
 tools/pvck.c | 31 +++++++++++++++++++++----------
 1 file changed, 21 insertions(+), 10 deletions(-)

diff --git a/tools/pvck.c b/tools/pvck.c
index 39692e3de..06fd01733 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -1039,13 +1039,6 @@ static int _dump_label_and_pv_header(struct cmd_context *cmd, uint64_t labelsect
 		return 0;
 	}
 
-	/*
-	 * Not invalidating this range can cause an error reading
-	 * a larger range that overlaps this.
-	 */
-	if (dev && !dev_invalidate_bytes(dev, lh_offset, 512))
-		stack;
-
 	lh = (struct label_header *)buf;
 
 	if (print_fields) {
@@ -3040,7 +3033,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 
 		clear_hint_file(cmd);
 
-		if (!(dev = dev_cache_get(cmd, pv_name, cmd->filter))) {
+		if (!(dev = dev_cache_get(cmd, pv_name, NULL))) {
 			log_error("Cannot use %s: %s.", pv_name, devname_error_reason(pv_name));
 			return ECMD_FAILED;
 		}
@@ -3049,7 +3042,7 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_is_set(cmd, dump_ARG)) {
 		pv_name = argv[0];
 
-		dev = dev_cache_get(cmd, pv_name, cmd->filter);
+		dev = dev_cache_get(cmd, pv_name, NULL);
 
 		if (!dev)
 			def = get_devicefile(pv_name);
@@ -3071,7 +3064,25 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 			return ECMD_FAILED;
 	}
 
-	label_scan_setup_bcache();
+	if (dev) {
+		char buf[4096];
+
+		label_scan_setup_bcache();
+
+		/*
+		 * This buf is not used, but bcache data is used for subsequent
+		 * reads in the filters and by _read_bytes for other disk structs.
+		 */
+		if (!dev_read_bytes(dev, 0, 4096, buf)) {
+	        	log_error("Failed to read the first 4096 bytes of device %s.", dev_name(dev));
+			return ECMD_FAILED;
+		}
+
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, NULL)) {
+			log_error("Cannot use %s: %s.", pv_name, dev_filtered_reason(dev));
+			return ECMD_FAILED;
+		}
+	}
 
 	if ((dump = arg_str_value(cmd, dump_ARG, NULL))) {
 		cmd->use_hints = 0;


