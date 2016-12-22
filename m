From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Dec 2016 22:38:23 +0000 (UTC)
Subject: master - lv: more exact check for merging origin
Message-ID: <20161222223823.C971B60E20@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=95e3dd5fb1297f6b1aa23cbedad1ab3dc14343a7
Commit:        95e3dd5fb1297f6b1aa23cbedad1ab3dc14343a7
Parent:        9491ab41cd61501039027fa5d7cfe89f78504132
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 22 21:15:31 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 22 23:37:07 2016 +0100

lv: more exact check for merging origin

Merging origin has 'MERGE_LV' and should also have its merging snapshot.
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6ab385d..8fefe6a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Checking LV for merging origin requires also it has merged snapshot.
   Extend validation of metadata processing.
   Enable usage of cached volumes as snapshot origin LV.
   Fix displayed lv name when splitting snapshot (2.02.146).
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index aa40c6c..4e05885 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -198,7 +198,7 @@
 #define lv_is_partial(lv)	(((lv)->status & PARTIAL_LV) ? 1 : 0)
 #define lv_is_virtual(lv)	(((lv)->status & VIRTUAL) ? 1 : 0)
 #define lv_is_merging(lv)	(((lv)->status & MERGING) ? 1 : 0)
-#define lv_is_merging_origin(lv) (lv_is_merging(lv))
+#define lv_is_merging_origin(lv) (lv_is_merging(lv) && (lv)->snapshot)
 #define lv_is_snapshot(lv)	(((lv)->status & SNAPSHOT) ? 1 : 0)
 #define lv_is_converting(lv)	(((lv)->status & CONVERTING) ? 1 : 0)
 #define lv_is_external_origin(lv)	(((lv)->external_count > 0) ? 1 : 0)


