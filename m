From: David Teigland <teigland@sourceware.org>
Date: Thu, 22 Oct 2020 20:43:12 +0000 (GMT)
Subject: master - filters: nodata option
Message-ID: <20201022204312.2DF813851C09@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c74ccd5201d4566a77487d1aa89e72c254ea443d
Commit:        c74ccd5201d4566a77487d1aa89e72c254ea443d
Parent:        c601ec0d6ed0a1cf31cdf65b995e7b3f0b6f1d72
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 19 16:46:20 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 21 16:24:16 2020 -0500

filters: nodata option

When filter_nodata_only is set, a filter that uses
data is skipped.
---
 lib/commands/toolcontext.h       | 1 +
 lib/filters/filter-fwraid.c      | 4 ++++
 lib/filters/filter-md.c          | 3 +++
 lib/filters/filter-partitioned.c | 4 ++++
 lib/filters/filter-signature.c   | 4 ++++
 5 files changed, 16 insertions(+)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index c09558a42..d20768ad0 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -182,6 +182,7 @@ struct cmd_context {
 	unsigned pvscan_recreate_hints:1;	/* enable special case hint handling for pvscan --cache */
 	unsigned scan_lvs:1;
 	unsigned wipe_outdated_pvs:1;
+	unsigned filter_nodata_only:1;          /* only use filters that do not require data from the dev */
 
 	/*
 	 * Devices and filtering.
diff --git a/lib/filters/filter-fwraid.c b/lib/filters/filter-fwraid.c
index f82f87397..4ad1816e1 100644
--- a/lib/filters/filter-fwraid.c
+++ b/lib/filters/filter-fwraid.c
@@ -15,6 +15,7 @@
 #include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
+#include "lib/commands/toolcontext.h"
 
 #ifdef UDEV_SYNC_SUPPORT
 #include <libudev.h>
@@ -69,6 +70,9 @@ static int _ignore_fwraid(struct cmd_context *cmd, struct dev_filter *f __attrib
 {
 	int ret;
 
+	if (cmd->filter_nodata_only)
+		return 1;
+
 	dev->filtered_flags &= ~DEV_FILTERED_FWRAID;
 
 	if (!fwraid_filtering())
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index b530e407d..f72c52123 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -86,6 +86,9 @@ static int _passes_md_filter(struct cmd_context *cmd, struct dev_filter *f __att
 {
 	int ret;
 
+	if (cmd->filter_nodata_only)
+		return 1;
+
 	dev->filtered_flags &= ~DEV_FILTERED_MD_COMPONENT;
 
 	/*
diff --git a/lib/filters/filter-partitioned.c b/lib/filters/filter-partitioned.c
index 22194f81c..c0b5554c5 100644
--- a/lib/filters/filter-partitioned.c
+++ b/lib/filters/filter-partitioned.c
@@ -16,6 +16,7 @@
 #include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
+#include "lib/commands/toolcontext.h"
 
 #define MSG_SKIPPING "%s: Skipping: Partition table signature found"
 
@@ -24,6 +25,9 @@ static int _passes_partitioned_filter(struct cmd_context *cmd, struct dev_filter
 	struct dev_types *dt = (struct dev_types *) f->private;
 	int ret;
 
+	if (cmd->filter_nodata_only)
+		return 1;
+
 	dev->filtered_flags &= ~DEV_FILTERED_PARTITIONED;
 
 	ret = dev_is_partitioned(dt, dev);
diff --git a/lib/filters/filter-signature.c b/lib/filters/filter-signature.c
index f32bb2450..eeefa4f58 100644
--- a/lib/filters/filter-signature.c
+++ b/lib/filters/filter-signature.c
@@ -16,6 +16,7 @@
 #include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
+#include "lib/commands/toolcontext.h"
 
 #ifdef __linux__
 
@@ -27,6 +28,9 @@ static int _ignore_signature(struct cmd_context *cmd, struct dev_filter *f __att
 	char buf[BUFSIZE];
 	int ret = 0;
 
+	if (cmd->filter_nodata_only)
+		return 1;
+
 	dev->filtered_flags &= ~DEV_FILTERED_SIGNATURE;
 
 	if (!scan_bcache) {


