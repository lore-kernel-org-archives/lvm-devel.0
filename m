From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Apr 2016 22:01:54 +0000 (UTC)
Subject: master - cleanup: use log_debug_activation
Message-ID: <20160426220154.4321460971@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a2efab0b11b7bfeef1a60b6cfd61c8bceb67164
Commit:        2a2efab0b11b7bfeef1a60b6cfd61c8bceb67164
Parent:        c81005dcc46bc55d0d4e5094f6ef99e36cecd486
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 27 00:01:08 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 27 00:01:08 2016 +0200

cleanup: use log_debug_activation

---
 lib/activate/activate.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index f554f19..5a7e99e 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2013 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -615,7 +615,7 @@ int module_present(struct cmd_context *cmd, const char *target_name)
 				path[i] = '_'; /* replace '-' with '_' */
 
 		if ((lstat(path, &st) == 0) && S_ISDIR(st.st_mode)) {
-			log_debug("Module directory %s exists.", path);
+			log_debug_activation("Module directory %s exists.", path);
 			return 1;
 		}
 	}


