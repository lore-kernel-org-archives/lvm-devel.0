From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  8 Jul 2013 12:04:05 +0000 (UTC)
Subject: master - pvremove: stack trace
Message-ID: <20130708120405.7145B6034E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=edf5cae6799549827d4031f472451bd96d2f0f47
Commit:        edf5cae6799549827d4031f472451bd96d2f0f47
Parent:        ccf3dd60f2a486f8ac1b9788ca6378b1dc88827d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 6 14:15:42 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 8 14:01:41 2013 +0200

pvremove: stack trace

Stack trace error.
Remove unused var.
---
 tools/pvremove.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/tools/pvremove.c b/tools/pvremove.c
index 45c675e..7048b97 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -18,7 +18,7 @@
 
 int pvremove(struct cmd_context *cmd, int argc, char **argv)
 {
-	int i, r;
+	int i;
 	int ret = ECMD_PROCESSED;
 	unsigned force_count;
 	unsigned prompt;
@@ -33,8 +33,10 @@ int pvremove(struct cmd_context *cmd, int argc, char **argv)
 
 	for (i = 0; i < argc; i++) {
 		dm_unescape_colons_and_at_signs(argv[i], NULL, NULL);
-		if (!pvremove_single(cmd, argv[i], NULL, force_count, prompt))
+		if (!pvremove_single(cmd, argv[i], NULL, force_count, prompt)) {
+			stack;
 			ret = ECMD_FAILED;
+		}
 	}
 
 	return ret;


