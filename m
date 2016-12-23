From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 23 Dec 2016 12:16:53 +0000 (UTC)
Subject: master - validation: temporarily let pass linear with chunk_size
Message-ID: <20161223121653.0FB29607A9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=14902d173917e814061a80f16ea54435abba1f91
Commit:        14902d173917e814061a80f16ea54435abba1f91
Parent:        95d68f1d0e16f553f4f12046ceb7b6ff8d251336
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 23 12:40:40 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 23 13:16:06 2016 +0100

validation: temporarily let pass linear with chunk_size

Old pool format seems to be setting chunk_size.
For now let validation pass with this.
---
 lib/metadata/merge.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index a1c9455..59c0885 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -440,6 +440,8 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 	}
 
 	if (!seg_is_pool(seg) &&
+	    /* FIXME: format_pool/import_export.c  _add_linear_seg() sets chunk_size */
+	    !seg_is_linear(seg) &&
 	    !seg_is_snapshot(seg)) {
 		if (seg->chunk_size)
 			seg_error("sets chunk_size");


