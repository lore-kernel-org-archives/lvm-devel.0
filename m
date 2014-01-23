From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 23 Jan 2014 15:53:36 +0000 (UTC)
Subject: master - Typo: s/Unale/Unable/
Message-ID: <20140123155336.8182D61662@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5e4647ec99b1de0923a311004e86649b50f81c1f
Commit:        5e4647ec99b1de0923a311004e86649b50f81c1f
Parent:        c1df1f3a81a0ff24ba2e25ed6680fcb653655dee
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Jan 22 23:04:27 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Jan 22 23:04:27 2014 -0600

Typo: s/Unale/Unable/

---
 lib/metadata/pool_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index a36c0c7..148b30c 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -46,7 +46,7 @@ int attach_pool_data_lv(struct lv_segment *pool_seg,
 {
 	if (!seg_is_thin_pool(pool_seg)) {
 		log_error(INTERNAL_ERROR
-			  "Unale to attach pool data LV to %s segtype.",
+			  "Unable to attach pool data LV to %s segtype.",
 			  pool_seg->segtype->ops->name(pool_seg));
 		return 0;
 	}


