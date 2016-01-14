From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 Jan 2016 10:35:24 +0000 (UTC)
Subject: master - cleanup: explicit prohibition for virtual segs
Message-ID: <20160114103524.F400C60DBC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2567d03e95bb4e46cd845c2ae8b518ec4989b939
Commit:        2567d03e95bb4e46cd845c2ae8b518ec4989b939
Parent:        4310dfd4e141bb83320148d245f3ab2cae778f6e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 6 13:54:15 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 14 11:34:05 2016 +0100

cleanup: explicit prohibition for virtual segs

Internal _alloc_init() is only called from allocate_extents(),
which already does prevent usage of virtual segments.

So mark as internal error early and do not process it any further.
---
 lib/metadata/lv_manip.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1396b86..6897801 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3128,19 +3128,20 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	uint32_t s, area_count, alloc_count, parity_count, total_extents;
 	size_t size = 0;
 
+	if (segtype_is_virtual(segtype)) {
+		log_error(INTERNAL_ERROR "_alloc_init called for virtual segment.");
+		return NULL;
+	}
+
 	/* FIXME Caller should ensure this */
 	if (mirrors && !stripes)
 		stripes = 1;
-
-	if (segtype_is_virtual(segtype))
-		area_count = 0;
 	else if (mirrors > 1)
 		area_count = mirrors * stripes;
 	else
 		area_count = stripes;
 
-	if (!segtype_is_virtual(segtype) &&
-	    !(area_count + metadata_area_count)) {
+	if (!(area_count + metadata_area_count)) {
 		log_error(INTERNAL_ERROR "_alloc_init called for non-virtual segment with no disk space.");
 		return NULL;
 	}
@@ -3186,10 +3187,6 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 
 	ah->cmd = cmd;
 	ah->mem = mem;
-
-	if (segtype_is_virtual(segtype))
-		return ah;
-
 	ah->area_count = area_count;
 	ah->parity_count = parity_count;
 	ah->region_size = region_size;


