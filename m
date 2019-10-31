From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 31 Oct 2019 10:44:14 -0400
Subject: master - mirror: directly activate updated mirror
Message-ID: <201910311444.x9VEiEDl018523@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ab315e7a814c8ccddc866966d88df38803240c61
Commit:        ab315e7a814c8ccddc866966d88df38803240c61
Parent:        80b2de9e6a947b17d1cd2eda70ed0f9d73624534
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 31 10:05:40 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 31 15:31:30 2019 +0100

mirror: directly activate updated mirror

---
 lib/metadata/mirror.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 75dc18c..a4ecb96 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -739,7 +739,7 @@ static int _split_mirror_images(struct logical_volume *lv,
 
 	act = lv_is_active(lv_lock_holder(lv));
 
-	if (act && (!deactivate_lv(cmd, new_lv) || !_activate_lv_like_model(lv, new_lv))) {
+	if (act && !_activate_lv_like_model(lv, new_lv)) {
 		log_error("Failed to rename newly split LV in the kernel");
 		return 0;
 	}


