From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 31 Oct 2019 08:17:56 -0400
Subject: stable-2.02 - mirror: directly activate updated mirror
Message-ID: <201910311217.x9VCHuri010821@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cf426744aef84d993b95926b23489f55f9a25838
Commit:        cf426744aef84d993b95926b23489f55f9a25838
Parent:        f1be01c7ef21e80d3543b7c54a15ec2b49776c4c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 31 10:05:40 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 31 13:00:01 2019 +0100

mirror: directly activate updated mirror

---
 lib/metadata/mirror.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index cd8ce1e..6cd88cb 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -790,7 +790,7 @@ static int _split_mirror_images(struct logical_volume *lv,
 
 	act = lv_is_active(lv_lock_holder(lv));
 
-	if (act && (!deactivate_lv(cmd, new_lv) || !_activate_lv_like_model(lv, new_lv))) {
+	if (act && !_activate_lv_like_model(lv, new_lv)) {
 		log_error("Failed to rename newly split LV in the kernel");
 		return 0;
 	}


