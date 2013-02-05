From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  5 Feb 2013 13:47:23 +0000 (UTC)
Subject: master - cleanup: add internal error check
Message-ID: <20130205134723.C5785A0C2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ddeb37f282caf053687d447cd7f52cb7d5a1f702
Commit:        ddeb37f282caf053687d447cd7f52cb7d5a1f702
Parent:        f5cd9c3563a77f65b039923833ee13f3e22a959f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 19:42:28 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 5 14:27:24 2013 +0100

cleanup: add internal error check

Check if 'is_removable' is defined and report internal error,
if it's missing.
---
 lib/metadata/mirror.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 4fee763..2a78508 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -864,8 +864,13 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	     s >= 0 && old_area_count - new_area_count < orig_removed;
 	     s--) {
 		sub_lv = seg_lv(mirrored_seg, s);
-		if (!(is_temporary_mirror_layer(sub_lv) && lv_mirror_count(sub_lv) != 1) &&
-		    is_removable(sub_lv, removable_baton)) {
+		if (!(is_temporary_mirror_layer(sub_lv) && lv_mirror_count(sub_lv) != 1)) {
+			if (!is_removable) {
+				log_error(INTERNAL_ERROR "Test is_removable undefined.");
+				return 0;
+			}
+			if (!is_removable(sub_lv, removable_baton))
+				continue;
 			/*
 			 * Check if the user is trying to pull the
 			 * primary mirror image when the mirror is


