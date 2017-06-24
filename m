From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 24 Jun 2017 11:59:38 -0400
Subject: master - display: add display_percent function
Message-ID: <201706241559.v5OFxcFE026758@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=07eec06f5d7f7a9589b8555df7e67d211dcd3257
Commit:        07eec06f5d7f7a9589b8555df7e67d211dcd3257
Parent:        feed61f3fa17a94140ba91ae5df844ee4ad34248
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 24 16:03:21 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Jun 24 17:44:42 2017 +0200

display: add display_percent function

Add universal function to print dm_percent_t values via single
code path.

TODO: extend with configurale precision of printed values.
---
 WHATS_NEW             |    1 +
 lib/display/display.c |   26 +++++++++++++++++++++++++-
 lib/display/display.h |    4 +++-
 3 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fa51f67..6a60f0b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Add display_percent helper function for printing percent values.
   Lvconvert --repair handles failing raid legs (present but marked 'D'ead).
   Do not lvdisplay --maps unset settings of cache pool.
   Fix lvdisplay --maps for cache pool without policy settings.
diff --git a/lib/display/display.c b/lib/display/display.c
index a8bb5cc..5940cf0 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -152,6 +152,30 @@ const char *display_lvname(const struct logical_volume *lv)
 	return name;
 }
 
+/* Display percentage with (TODO) configurable precision */
+const char *display_percent(struct cmd_context *cmd, dm_percent_t percent)
+{
+	char *buf;
+	int r;
+
+        /* Reusing same  ring buffer we use for displaying LV names */
+	if ((cmd->display_lvname_idx + NAME_LEN) >= sizeof((cmd->display_buffer)))
+		cmd->display_lvname_idx = 0;
+
+	buf = cmd->display_buffer + cmd->display_lvname_idx;
+	/* TODO: Make configurable hardcoded 2 digits */
+	r = dm_snprintf(buf, NAME_LEN, "%.2f", dm_percent_to_round_float(percent, 2));
+
+	if (r < 0) {
+		log_error("Percentage %d does not fit.", percent);
+		return NULL;
+	}
+
+	cmd->display_lvname_idx += r + 1;
+
+	return buf;
+}
+
 /* Size supplied in sectors */
 static const char *_display_size(const struct cmd_context *cmd,
 				 uint64_t size, dm_size_suffix_t suffix_type)
diff --git a/lib/display/display.h b/lib/display/display.h
index 1fc9079..9f9afe9 100644
--- a/lib/display/display.h
+++ b/lib/display/display.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -24,6 +24,8 @@
 
 const char *display_lvname(const struct logical_volume *lv);
 
+const char *display_percent(struct cmd_context *cmd, dm_percent_t percent);
+
 /* Specify size in KB */
 const char *display_size(const struct cmd_context *cmd, uint64_t size);
 const char *display_size_long(const struct cmd_context *cmd, uint64_t size);


