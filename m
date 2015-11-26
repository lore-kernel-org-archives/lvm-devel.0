From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 26 Nov 2015 08:48:46 +0000 (UTC)
Subject: master - cleanup: avoid allocation for vg_name
Message-ID: <20151126084846.C7E4D60DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=528695ec2004dcadaacba99d51685ac4a0582ea7
Commit:        528695ec2004dcadaacba99d51685ac4a0582ea7
Parent:        d582be43d4cee8c74ee4e251d299a321ded474fa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 25 16:04:27 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 26 09:27:37 2015 +0100

cleanup: avoid allocation for vg_name

Since we do not use dev_manager in a way we would have destroyed VG
content while  in-use - we could safely keep just pointer.
So dropping strdup.

Also it seems we actually no longer use vg_name for anything
so it may possibly go away completely unless it would be useful
for debugging...
---
 lib/activate/dev_manager.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index eb47ed1..9110ecb 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -66,7 +66,7 @@ struct dev_manager {
 	unsigned track_pending_delete;
 	unsigned track_pvmove_deps;
 
-	char *vg_name;
+	const char *vg_name;
 };
 
 struct lv_layer {
@@ -1230,9 +1230,7 @@ struct dev_manager *dev_manager_create(struct cmd_context *cmd,
 
 	dm->cmd = cmd;
 	dm->mem = mem;
-
-	if (!(dm->vg_name = dm_pool_strdup(dm->mem, vg_name)))
-		goto_bad;
+	dm->vg_name = vg_name;
 
 	/*
 	 * When we manipulate (normally suspend/resume) the PVMOVE


