From: David Teigland <teigland@sourceware.org>
Date: Thu, 18 Oct 2018 13:37:33 -0400
Subject: 2018-06-01-stable - scan: enable full md filter when md 1.0 devices are present
Message-ID: <201810181737.w9IHbXM3008938@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e7bb50880901a4462e350ce0d272a63aa8440781
Commit:        e7bb50880901a4462e350ce0d272a63aa8440781
Parent:        de2863739f2ea17d89d0e442379109f967b5919d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 18 11:32:32 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 18 12:35:57 2018 -0500

scan: enable full md filter when md 1.0 devices are present

The previous commit de2863739f2ea17d89d0e442379109f967b5919d
    scan: use full md filter when md 1.0 devices are present

needs the use_full_md_check flag in the md filter, but
the cmd struct is not available when the filter is run,
so that commit wasn't working.  Fix this by setting the
flag in a global variable.

(This was fixed in the master branch with commit 8eab37593
in which the cmd struct was passed to the filters, but it
was an intrusive change, so this commit is using the less
intrusive global variable.)
---
 lib/filters/filter-md.c |   33 +++++++--------------------------
 lib/label/label.c       |   13 ++++++++++++-
 2 files changed, 19 insertions(+), 27 deletions(-)

diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index ad5b8e4..e03ff50 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -16,6 +16,9 @@
 #include "lib.h"
 #include "filter.h"
 
+/* See label.c comment about this hack. */
+extern int use_full_md_check;
+
 #ifdef __linux__
 
 #define MSG_SKIPPING "%s: Skipping md component device"
@@ -80,7 +83,7 @@
  * that will not pass.
  */
 
-static int _passes_md_filter(struct device *dev, int full)
+static int _passes_md_filter(struct dev_filter *f, struct device *dev)
 {
 	int ret;
 
@@ -91,7 +94,7 @@ static int _passes_md_filter(struct device *dev, int full)
 	if (!md_filtering())
 		return 1;
 
-	ret = dev_is_md(dev, NULL, full);
+	ret = dev_is_md(dev, NULL, use_full_md_check);
 
 	if (ret == -EAGAIN) {
 		/* let pass, call again after scan */
@@ -104,6 +107,7 @@ static int _passes_md_filter(struct device *dev, int full)
 		return 1;
 
 	if (ret == 1) {
+		log_debug_devs("md filter full %d excluding md component %s", use_full_md_check, dev_name(dev));
 		if (dev->ext.src == DEV_EXT_NONE)
 			log_debug_devs(MSG_SKIPPING, dev_name(dev));
 		else
@@ -121,18 +125,6 @@ static int _passes_md_filter(struct device *dev, int full)
 	return 1;
 }
 
-static int _passes_md_filter_lite(struct dev_filter *f __attribute__((unused)),
-				  struct device *dev)
-{
-	return _passes_md_filter(dev, 0);
-}
-
-static int _passes_md_filter_full(struct dev_filter *f __attribute__((unused)),
-				  struct device *dev)
-{
-	return _passes_md_filter(dev, 1);
-}
-
 static void _destroy(struct dev_filter *f)
 {
 	if (f->use_count)
@@ -150,18 +142,7 @@ struct dev_filter *md_filter_create(struct cmd_context *cmd, struct dev_types *d
 		return NULL;
 	}
 
-	/*
-	 * FIXME: for commands that want a full md check (pvcreate, vgcreate,
-	 * vgextend), we do an extra read at the end of every device that the
-	 * filter looks at.  This isn't necessary; we only need to do the full
-	 * md check on the PVs that these commands are trying to use.
-	 */
-
-	if (cmd->use_full_md_check)
-		f->passes_filter = _passes_md_filter_full;
-	else
-		f->passes_filter = _passes_md_filter_lite;
-
+	f->passes_filter = _passes_md_filter;
 	f->destroy = _destroy;
 	f->use_count = 0;
 	f->private = dt;
diff --git a/lib/label/label.c b/lib/label/label.c
index e76ddd4..e5aa2c1 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -27,6 +27,7 @@
 #include <unistd.h>
 #include <sys/time.h>
 
+int use_full_md_check;
 
 /* FIXME Allow for larger labels?  Restricted to single sector currently */
 
@@ -868,8 +869,18 @@ int label_scan(struct cmd_context *cmd)
 		 * devs in 'pvs', which is a pretty harmless effect from a
 		 * pretty uncommon situation.
 		 */
-		if (dev_is_md_with_end_superblock(cmd->dev_types, dev))
+		if (dev_is_md_with_end_superblock(cmd->dev_types, dev)) {
 			cmd->use_full_md_check = 1;
+
+			/* This is a hack because 'cmd' is not passed
+			   into the filters so we can't check the flag
+			   in the cmd struct.  The master branch has
+			   changed the filters in commit 8eab37593eccb
+			   to accept cmd, but it's a complex change
+			   that I'm trying to avoid in the stable branch. */
+
+			use_full_md_check = 1;
+		}
 	};
 	dev_iter_destroy(iter);
 


