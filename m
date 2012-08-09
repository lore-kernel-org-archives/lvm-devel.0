From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  9 Aug 2012 14:26:43 +0000 (UTC)
Subject: master - thin: default discards for old mda is IGNORE
Message-ID: <20120809142643.107E52B36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f1c664b78d5f8464e0bbee5a00402cad93c7029
Commit:        1f1c664b78d5f8464e0bbee5a00402cad93c7029
Parent:        de3b1c4506ff502f00a360a83800f35a31e1b42e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 9 11:24:37 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 9 16:23:32 2012 +0200

thin: default discards for old mda is IGNORE

If the discard was not set in metadata, use IGNORE, as this
is the equivalent behavior for this case.
---
 WHATS_NEW       |    4 ++++
 lib/thin/thin.c |    2 +-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fd741bb..c7d3a2d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,7 @@
+Version 2.02.98
+=================================
+  Use 'ignore' discards for thin metadata created with older versions.
+
 Version 2.02.97 - 7th August 2012
 =================================
   Issue error message when arguments do not match specified RAID type.
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index cfd50ad..25c1947 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -119,7 +119,7 @@ static int _thin_pool_text_import(struct lv_segment *seg,
 		return SEG_LOG_ERROR("Could not read discards for");
 
 	if (!discards_str)
-		seg->discards = THIN_DISCARDS_PASSDOWN;
+		seg->discards = THIN_DISCARDS_IGNORE;
 	else if (!get_pool_discards(discards_str, &seg->discards))
 		return SEG_LOG_ERROR("Discards option unsupported for");
 


