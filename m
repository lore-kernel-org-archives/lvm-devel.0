From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Nov 2014 09:18:53 +0000 (UTC)
Subject: master - coverity: fix possible dereference of NULL pointer
Message-ID: <20141112091853.EE41160E02@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c03d8473ea9ad585f27207404a242b7b11caf74f
Commit:        c03d8473ea9ad585f27207404a242b7b11caf74f
Parent:        ce8730b5080b85192af1aadea3d9e9b5333a2405
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 12 10:17:17 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 12 10:17:17 2014 +0100

coverity: fix possible dereference of NULL pointer

This would be in case the pool segment was not found.

LVM2.2.02.112/lib/metadata/pool_manip.c:238:36: warning: Access to field 'segtype' results in a dereference of a null pointer (loaded from variable 'pool_seg')
---
 lib/metadata/pool_manip.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index 70b5a23..ee32a3b 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -235,6 +235,11 @@ struct lv_segment *find_pool_seg(const struct lv_segment *seg)
 		pool_seg = sl->seg;
 	}
 
+	if (!pool_seg) {
+		log_error("Pool segment not found for %s.", display_lvname(seg->lv));
+		return NULL;
+	}
+
 	if ((lv_is_thin_type(seg->lv) && !seg_is_pool(pool_seg))) {
 		log_error("%s on %s is not a %s pool segment",
 			  pool_seg->lv->name, seg->lv->name,


