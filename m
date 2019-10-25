From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Oct 2019 18:54:43 -0400
Subject: master - snapshot: fix checking of merged thin volume
Message-ID: <201910252254.x9PMshMN011767@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=855b16ce14f09523132ea624a7b4d1edaccc2450
Commit:        855b16ce14f09523132ea624a7b4d1edaccc2450
Parent:        9968be55edcf6e9c56c0767aeecfaa65f8eb3785
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 25 23:30:26 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 26 00:49:16 2019 +0200

snapshot: fix checking of merged thin volume

When merging of thin snapshot is taking place, the origin target will
be of thin type.
---
 lib/activate/activate.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 6f5fa1a..232d581 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -763,7 +763,8 @@ int lv_info_with_seg_status(struct cmd_context *cmd,
 				      with_open_count, with_read_ahead))
 				return_0;
 
-			if (status->seg_status.type == SEG_STATUS_SNAPSHOT) {
+			if (status->seg_status.type == SEG_STATUS_SNAPSHOT ||
+			    (lv_is_thin_volume(olv) && (status->seg_status.type == SEG_STATUS_THIN))) {
 				log_debug_activation("Snapshot merge is in progress, querying status of %s instead.",
 						     display_lvname(lv));
 				/*


