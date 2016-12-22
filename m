From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Dec 2016 22:38:25 +0000 (UTC)
Subject: master - snapshot: validate merge has started
Message-ID: <20161222223825.E0D3860296@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2aee4769b43a08eed549bd324664af5f406a25b2
Commit:        2aee4769b43a08eed549bd324664af5f406a25b2
Parent:        95e3dd5fb1297f6b1aa23cbedad1ab3dc14343a7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 22 19:46:02 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 22 23:37:07 2016 +0100

snapshot: validate merge has started

Before starting polling process, validate the merge has actually started
so there is not pointless invoke of lvmpolld.

This also fixes reported message from command, so user has
correct info whether merging has already started or
if it's delayed for next activation.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    9 +++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8fefe6a..dcfd85a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Detect if snapshot merge really started before polling for progress.
   Checking LV for merging origin requires also it has merged snapshot.
   Extend validation of metadata processing.
   Enable usage of cached volumes as snapshot origin LV.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0f0f0ad..ba8396f 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2497,8 +2497,13 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 		if (!lv_update_and_reload(origin))
 			return_0;
 
-		lp->need_polling = 1;
-		lp->lv_to_poll = origin;
+		if (lv_has_target_type(origin->vg->vgmem, origin, NULL,
+				       TARGET_NAME_SNAPSHOT_MERGE)) {
+			lp->need_polling = 1;
+			lp->lv_to_poll = origin;
+		} else
+			/* Race during table reload prevented merging */
+			merge_on_activate = 1;
 	}
 
 	if (merge_on_activate)


