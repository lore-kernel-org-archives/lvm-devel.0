From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 24 Nov 2017 10:10:51 -0500
Subject: master - locking: pvmove is locking holding LV
Message-ID: <201711241510.vAOFApEO000341@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b5be7420d947b9bfe52da73078955ed241765875
Commit:        b5be7420d947b9bfe52da73078955ed241765875
Parent:        8cf10948bd3acce7ae03f16982f0acbc4cde4fee
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 24 13:55:57 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 24 16:05:21 2017 +0100

locking: pvmove is locking holding LV

As we do get lock for pvmove LV - it's lockholder ATM.
---
 WHATS_NEW         |    1 +
 lib/metadata/lv.c |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6ff4ccd..f29a498 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Make a pvmove LV locking holder.
   Do not change critical section counter on resume path without real resume.
   Enhance activation code to automatically suspend pvmove participants.
   Remove unnecessary single read from lvmdiskscan.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 4d35efe..630880f 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1604,6 +1604,9 @@ const struct logical_volume *lv_lock_holder(const struct logical_volume *lv)
 	if ((lv_is_raid_image(lv) || lv_is_raid_metadata(lv)) && lv_is_visible(lv))
 		return lv;
 
+	if (lv_is_pvmove(lv))
+		return lv;
+
 	/* For other types, by default look for the first user */
 	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
 		/* FIXME: complete this exception list */


