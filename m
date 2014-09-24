From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Sep 2014 08:56:50 +0000 (UTC)
Subject: master - snapshot: use lv_update_and_reload
Message-ID: <20140924085650.07A416109B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a84d0d0c7b843168516a940a8bc4debafc5f980c
Commit:        a84d0d0c7b843168516a940a8bc4debafc5f980c
Parent:        29970b0c177d14dd041f0564a9bdcd0c3429a885
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 21 01:10:53 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 24 10:51:15 2014 +0200

snapshot: use lv_update_and_reload

---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   18 ++----------------
 2 files changed, 3 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7f37f24..39282c2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Use lv_update_and_reload() for snapshot reload.
   Don't print message in adjusted_mirror_region_size() in activation.
   Improve lv_update_and_reload() to find out proper lock holding LV.
   Improve search of LV in lv_ondisk().
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 14000b8..81cc997 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7124,22 +7124,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		}
 
 		/* store vg on disk(s) */
-		if (!vg_write(vg))
-			return_NULL;
-
-		if (!suspend_lv(cmd, org)) {
-			log_error("Failed to suspend origin %s", org->name);
-			vg_revert(vg);
-			return NULL;
-		}
-
-		if (!vg_commit(vg))
-			return_NULL;
-
-		if (!resume_lv(cmd, org)) {
-			log_error("Problem reactivating origin %s", org->name);
-			return NULL;
-		}
+		if (!lv_update_and_reload(org))
+			return_0;
 	}
 	/* FIXME out of sequence */
 	backup(vg);


