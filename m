From: okozina <okozina@fedoraproject.org>
Date: Wed,  1 Apr 2015 18:42:55 +0000 (UTC)
Subject: master - polldaemon: prepare wrapper poll_daemon function
Message-ID: <20150401184255.4E98260CDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3929b00466c3c415a8e82e8346d79ec6c5c0eb76
Commit:        3929b00466c3c415a8e82e8346d79ec6c5c0eb76
Parent:        65623b63a20a221b48dfd87455dc77f5ac0c6bf4
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Mar 17 18:31:41 2015 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Wed Apr 1 20:41:30 2015 +0200

polldaemon: prepare wrapper poll_daemon function

with lvmpolld we'll have two polldaemon implementations
---
 tools/polldaemon.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 6b06506..dd53055 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -275,10 +275,10 @@ static void _poll_for_all_vgs(struct cmd_context *cmd,
  * - 'background' is advisory so a child polldaemon may not be used even
  *   if it was requested.
  */
-int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
-		unsigned background,
-		uint64_t lv_type, struct poll_functions *poll_fns,
-		const char *progress_title)
+static int _poll_daemon(struct cmd_context *cmd, const char *name,
+			const char *uuid, unsigned background, uint64_t lv_type,
+			struct poll_functions *poll_fns,
+			const char *progress_title)
 {
 	struct processing_handle *handle = NULL;
 	struct daemon_parms parms;
@@ -357,3 +357,11 @@ int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
 	destroy_processing_handle(cmd, handle);
 	return ret;
 }
+
+int poll_daemon(struct cmd_context *cmd, const char *name, const char *uuid,
+		unsigned background,
+		uint64_t lv_type, struct poll_functions *poll_fns,
+		const char *progress_title)
+{
+	return _poll_daemon(cmd, name, uuid, background, lv_type, poll_fns, progress_title);
+}


