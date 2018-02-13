From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 13 Feb 2018 13:12:20 -0500
Subject: master - segtype: no libmem pool usage for name allocation
Message-ID: <201802131812.w1DICKD9028553@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0eb9daf602281d233c83e5823b3c6297fb541deb
Commit:        0eb9daf602281d233c83e5823b3c6297fb541deb
Parent:        32febed8d55d0761fdbe86015c02da90e026b359
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 13 19:06:35 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 13 19:11:28 2018 +0100

segtype: no libmem pool usage for name allocation

Allocate name with plain malloc & free.
---
 lib/unknown/unknown.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/lib/unknown/unknown.c b/lib/unknown/unknown.c
index 68d11c3..8f6083a 100644
--- a/lib/unknown/unknown.c
+++ b/lib/unknown/unknown.c
@@ -49,6 +49,7 @@ static int _unknown_text_export(const struct lv_segment *seg, struct formatter *
 
 static void _unknown_destroy(struct segment_type *segtype)
 {
+	dm_free(segtype->name);
 	dm_free(segtype);
 }
 
@@ -68,7 +69,12 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd, const char *n
 	}
 
 	segtype->ops = &_unknown_ops;
-	segtype->name = dm_pool_strdup(cmd->libmem, name);
+	if (!(segtype->name = dm_strdup(name))) {
+		log_error("Failed to allocate name.");
+		dm_free(segtype);
+		return NULL;
+	}
+
 	segtype->flags = SEG_UNKNOWN | SEG_VIRTUAL | SEG_CANNOT_BE_ZEROED;
 
 	log_very_verbose("Initialised segtype: %s", segtype->name);


