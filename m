From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Feb 2016 09:22:50 +0000 (UTC)
Subject: master - gcc: better code for older compiler
Message-ID: <20160212092250.84EA160E28@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=befe0078ad15563967d8b8321638c75a4f25f438
Commit:        befe0078ad15563967d8b8321638c75a4f25f438
Parent:        ba111e7f4a9481b2b419bd0f402dd0926ac1b0e9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 12 10:17:39 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 12 10:17:39 2016 +0100

gcc: better code for older compiler

Address this gcc warning:

metadata/lv.c:243: warning: initialized field overwritten
metadata/lv.c:243: warning: (near initialization for 'status.seg_status')

Present with e.g.: gcc version 4.3.2 (Debian 4.3.2-1.1)
---
 lib/metadata/lv.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index c4e3437..526284e 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -238,8 +238,10 @@ char *lvseg_kernel_discards_dup(struct dm_pool *mem, const struct lv_segment *se
 {
 	char *ret = NULL;
 	struct lv_with_info_and_seg_status status = {
-		.seg_status.type = SEG_STATUS_NONE,
-		.seg_status.seg = seg
+		.seg_status = {
+			.type = SEG_STATUS_NONE,
+			.seg = seg
+		},
 	};
 
 	if (!lv_is_thin_pool(seg->lv))


