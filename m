From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:43:12 +0000 (UTC)
Subject: master - thin: discard
Message-ID: <20120823124312.C2D39A0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=109b3bb49b31d5fa7f6d0dd23345d703ab866ad6
Commit:        109b3bb49b31d5fa7f6d0dd23345d703ab866ad6
Parent:        0de57b98bf0778684e8fac6d2d66ecf3fbc035ab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 21 15:51:54 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:38:48 2012 +0200

thin: discard

---
 tools/lvchange.c |    2 +-
 tools/lvcreate.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index a0c4a01..73a37fd 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -103,7 +103,7 @@ static int lvchange_pool_update(struct cmd_context *cmd,
 	}
 
 	if (arg_count(cmd, discards_ARG)) {
-		discards = arg_uint_value(cmd, discards_ARG, 0);
+		discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_IGNORE);
 		if (discards != first_seg(lv)->discards) {
 			if (((discards == THIN_DISCARDS_IGNORE) ||
 			     (first_seg(lv)->discards == THIN_DISCARDS_IGNORE)) &&
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 769ac8c..2cb6ac0 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -797,7 +797,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		return_0;
 
 	if (lp->create_thin_pool) {
-		lp->discards = arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
+		lp->discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_PASSDOWN);
 	} else if (arg_count(cmd, discards_ARG)) {
 		log_error("--discards is only available for thin pool creation.");
 		return 0;


