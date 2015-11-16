From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Nov 2015 00:17:16 +0000 (UTC)
Subject: master - debug: lvconvert add missing display_lvname
Message-ID: <20151116001716.B51D76029C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8ebf2b061174daec744f9e361fa7ca28eb19ea2e
Commit:        8ebf2b061174daec744f9e361fa7ca28eb19ea2e
Parent:        0f4d96f1bd7c30e29cd9d10b555d4ce0b553f5b3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 13 23:38:34 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 16 01:16:11 2015 +0100

debug: lvconvert add missing display_lvname

Add missing display_lvname in _lvconvert_merge_thin_snapshot().

Also when we detect missing origin, report Internal error,
which would likely be the primary fault here
(and avoid dereft of NULL origin as noticed by Coverity).
---
 tools/lvconvert.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 335f6a4..3cfd915 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2238,8 +2238,8 @@ static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
 	struct logical_volume *origin = snap_seg->origin;
 
 	if (!origin) {
-		log_error("\"%s\" is not a mergeable logical volume.",
-			  lv->name);
+		log_error("%s is not a mergeable logical volume.",
+			  display_lvname(lv));
 		return 0;
 	}
 
@@ -2251,9 +2251,12 @@ static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
 	}
 
 	if (lv_is_external_origin(origin)) {
-		origin = origin_from_cow(lv);
-		log_error("%s is read-only external origin %s.",
-			  display_lvname(lv), display_lvname(origin));
+		if (!(origin = origin_from_cow(lv)))
+			log_error(INTERNAL_ERROR "%s is missing origin.",
+				  display_lvname(lv));
+		else
+			log_error("%s is read-only external origin %s.",
+				  display_lvname(lv), display_lvname(origin));
 		return 0;
 	}
 


