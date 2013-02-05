From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  5 Feb 2013 13:47:41 +0000 (UTC)
Subject: master - lvconvert: update error path
Message-ID: <20130205134741.6E35FA0C2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=15115b61c0893a4abc660b1625b96fb14d073993
Commit:        15115b61c0893a4abc660b1625b96fb14d073993
Parent:        be5ad90703ca789becc10d56c19f6dc24f4c7eae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 5 11:21:21 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 5 14:31:34 2013 +0100

lvconvert: update error path

Update the error path after problems with suspend_lv or vg_commit.
It's not exactly well defined what should happen, and this
code seems to appear in many different instancies<F2> in the
whole source code tree - we should probably pick the best version.
---
 tools/lvconvert.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 94767b6..0e15888 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2005-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2005-2013 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -503,10 +503,13 @@ static int _reload_lv(struct cmd_context *cmd,
 	if (!suspend_lv(cmd, lv)) {
 		log_error("Failed to lock %s", lv->name);
 		vg_revert(vg);
+		if (!resume_lv(cmd, lv))
+			stack;
 		goto out;
 	}
 
 	if (!vg_commit(vg)) {
+		vg_revert(vg);
 		if (!resume_lv(cmd, lv))
 			stack;
 		goto_out;
@@ -520,8 +523,8 @@ static int _reload_lv(struct cmd_context *cmd,
 	}
 
 	r = 1;
-out:
 	backup(vg);
+out:
 	return r;
 }
 


