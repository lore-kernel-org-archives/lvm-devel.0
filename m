From: David Teigland <teigland@sourceware.org>
Date: Thu, 21 Jun 2018 10:01:44 -0400
Subject: 2018-06-01-stable - lvmlockd: fix another missing lock_type null check
Message-ID: <201806211401.w5LE1ifd009006@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d4fd39f64c64fb180606b8b9202119fa9c11b35d
Commit:        d4fd39f64c64fb180606b8b9202119fa9c11b35d
Parent:        acb784e2a87f1a5b57e75c5b92b833306feca9af
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 21 09:00:23 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 21 09:00:23 2018 -0500

lvmlockd: fix another missing lock_type null check

Same as 347c807f8.
---
 lib/metadata/mirror.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 25948ad..7f38d4f 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -710,7 +710,7 @@ static int _split_mirror_images(struct logical_volume *lv,
 		return 0;
 	}
 
-	if (!strcmp(lv->vg->lock_type, "dlm"))
+	if (lv->vg->lock_type && !strcmp(lv->vg->lock_type, "dlm"))
 		new_lv->lock_args = lv->lock_args;
 
 	if (!dm_list_empty(&split_images)) {


