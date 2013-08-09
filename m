From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  9 Aug 2013 21:18:37 +0000 (UTC)
Subject: master - thin: thin pool can't be external origin
Message-ID: <20130809211837.D1ABC60FCC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e583ff3d2c9996f1a7e684fe9da18745114dedfe
Commit:        e583ff3d2c9996f1a7e684fe9da18745114dedfe
Parent:        2f61478436a7ebe058ffad3f92e1c4dada0805d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 9 23:04:30 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 9 23:04:30 2013 +0200

thin: thin pool can't be external origin

Avoid trying to convert thin-pool to external origin.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    7 +++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7758500..d2830ee 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.100 -
 ================================
+  Prohibit convertion of thin pool to external origin.
   Workaround gcc v4.8 -O2 bug causing failures if config/checks=1 (32bit arch).
   Verify clvmd message validity before processing and log error if incorrect.
   Fix issue preventing PV creation on mirror LVs
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 6a243c3..94ba8c8 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2276,6 +2276,13 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 				  external_lv->vg->name, lp->pool_data_lv_name);
 			return 0;
 		}
+
+		if (lv_is_thin_pool(external_lv)) {
+			log_error("Can't convert pool \"%s/%s\" to external origin.",
+				  external_lv->vg->name, lp->pool_data_lv_name);
+			return 0;
+		}
+
 		if (lv_is_thin_pool(pool_lv)) {
 			r = 1; /* Already existing thin pool */
 			goto out;


