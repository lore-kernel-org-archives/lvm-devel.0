From: David Teigland <teigland@sourceware.org>
Date: Thu, 21 Jun 2018 10:26:11 -0400
Subject: master - lvmlockd: fix another missing lock_type null check
Message-ID: <201806211426.w5LEQBIe010628@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e166d2b14ca22ead559a5898cc229ecbcc261007
Commit:        e166d2b14ca22ead559a5898cc229ecbcc261007
Parent:        40c1f7889fd88ce4a2f2b42c594db3deb8f84593
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 21 09:00:23 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 21 09:24:51 2018 -0500

lvmlockd: fix another missing lock_type null check

Same as 347c807f8.
---
 lib/metadata/mirror.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 11f2a8f..58615d8 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -698,7 +698,7 @@ static int _split_mirror_images(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!strcmp(lv->vg->lock_type, "dlm"))
+	if (lv->vg->lock_type && !strcmp(lv->vg->lock_type, "dlm"))
 		new_lv->lock_args = lv->lock_args;
 
 	if (!dm_list_empty(&split_images)) {


