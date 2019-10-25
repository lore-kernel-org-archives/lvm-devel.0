From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Oct 2019 18:55:41 -0400
Subject: stable-2.02 - snapshot: fix checking of merged thin volume
Message-ID: <201910252255.x9PMtf9o012014@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8be8b994c6819343a13c547354507f6f89d837ca
Commit:        8be8b994c6819343a13c547354507f6f89d837ca
Parent:        20d94e4072a93c199781e282d142ba7c80c9a437
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 25 23:30:26 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 26 00:41:40 2019 +0200

snapshot: fix checking of merged thin volume

When merging of thin snapshot is taking place, the origin target will
be of thin type.
---
 lib/activate/activate.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 561a965..f17be61 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -818,7 +818,8 @@ int lv_info_with_seg_status(struct cmd_context *cmd,
 				      with_open_count, with_read_ahead))
 				return_0;
 
-			if (status->seg_status.type == SEG_STATUS_SNAPSHOT) {
+			if (status->seg_status.type == SEG_STATUS_SNAPSHOT ||
+			    (lv_is_thin_volume(olv) && (status->seg_status.type == SEG_STATUS_THIN))) {
 				log_debug_activation("Snapshot merge is in progress, querying status of %s instead.",
 						     display_lvname(lv));
 				/*


