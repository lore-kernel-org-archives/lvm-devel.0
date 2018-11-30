From: David Teigland <teigland@sourceware.org>
Date: Fri, 30 Nov 2018 16:05:37 -0500
Subject: 2018-06-01-stable - pvscan lvmetad: use full md filter when md 1.0 devices are present
Message-ID: <201811302105.wAUL5brr002564@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a01e1fec0fe7c2fa61577c0e636e907cde7279ea
Commit:        a01e1fec0fe7c2fa61577c0e636e907cde7279ea
Parent:        0e42ebd6d4012d210084a9ccf8d76f853726de3c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 29 14:06:20 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 29 14:08:46 2018 -0600

pvscan lvmetad: use full md filter when md 1.0 devices are present

Apply the same logic to pvscan/lvmetad that was added to
the non-lvmetad label_scan in commit 3fd75d1b:
  scan: use full md filter when md 1.0 devices are present

Before scanning, check if any of the devs on the system are
md 0.90/1.0, and if so make the scan read both the start and
the end of the device so that the components of those md
versions can be ignored.
---
 tools/pvscan.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 2915db5..3755684 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -18,6 +18,8 @@
 #include "lvmetad.h"
 #include "lvmcache.h"
 
+extern int use_full_md_check;
+
 struct pvscan_params {
 	int new_pvs_found;
 	int pvs_found;
@@ -302,6 +304,7 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	struct dm_list found_vgnames;
 	struct device *dev;
 	struct device_list *devl;
+	struct dev_iter *iter;
 	const char *pv_name;
 	const char *reason = NULL;
 	int32_t major = -1;
@@ -443,6 +446,22 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	/* Creates a list of dev names from /dev, sysfs, etc; does not read any. */
 	dev_cache_scan();
 
+	/* See the same check in label_scan() to handle md 0.9/1.0 components. */
+	if (!(iter = dev_iter_create(cmd->full_filter, 0))) {
+		log_error("Scanning failed to get devices.");
+		return 0;
+	}
+	while ((dev = dev_iter_get(iter))) {
+		if (dev_is_md_with_end_superblock(cmd->dev_types, dev)) {
+			cmd->use_full_md_check = 1;
+			use_full_md_check = 1;
+			log_debug("Found md with end superblock %s", dev_name(dev));
+		}
+	}
+	dev_iter_destroy(iter);
+	if (!use_full_md_check)
+		log_debug("No md devs with end superblock");
+
 	dm_list_init(&single_devs);
 
 	while (argc--) {


