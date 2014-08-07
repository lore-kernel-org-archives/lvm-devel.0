From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  7 Aug 2014 14:48:29 +0000 (UTC)
Subject: master - activation: if LV inactive and non-clustered, do not issue "Cannot deactivate" on -aln
Message-ID: <20140807144829.A6B24610A7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c52c9a1e316b6a92a2475dfe3ad2aac92edc80c0
Commit:        c52c9a1e316b6a92a2475dfe3ad2aac92edc80c0
Parent:        ea662ca06065d1e3d44814b54cf8501c9bb9594f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 7 16:44:09 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 7 16:44:09 2014 +0200

activation: if LV inactive and non-clustered, do not issue "Cannot deactivate" on -aln

The message "Cannot deactivate remotely exclusive device locally." makes
sense only for clustered LV. If the LV is non-clustered, then it's
always exclusive by definition and if it's already deactivated, this
message pops up inappropriately as those two conditions are met.

So issue the message only if the conditions are met AND we have clustered VG.
---
 WHATS_NEW         |    1 +
 lib/metadata/lv.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 028758e..96ce8cb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.110 -
 ==================================
+  If LV inactive and non-clustered, do not issue "Cannot deactivate" on -aln.
   Remove spurious "Skipping mirror LV" message on pvmove of clustered mirror.
 
 Version 2.02.109 - 5th August 2014
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index f2c9b12..9539369 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -859,7 +859,7 @@ deactivate:
 			return_0;
 		break;
 	case CHANGE_ALN:
-		if (_lv_is_exclusive(lv)) {
+		if (vg_is_clustered(lv->vg) && _lv_is_exclusive(lv)) {
 			if (!lv_is_active_locally(lv)) {
 				log_error("Cannot deactivate remotely exclusive device locally.");
 				return 0;


