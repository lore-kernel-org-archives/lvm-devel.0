From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 23 Sep 2013 10:16:23 +0000 (UTC)
Subject: master - raid: add lv_is_raid()
Message-ID: <20130923101623.B92B8606F6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b29adbbc4da6f016735929ce6a944639254a6c49
Commit:        b29adbbc4da6f016735929ce6a944639254a6c49
Parent:        a94e28ae019b94aa48dbaf1db83cc30bfdee0f4f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 18 17:22:14 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 23 11:35:15 2013 +0200

raid: add lv_is_raid()

More readable then status bit flag masking...
---
 lib/metadata/metadata-exported.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f20dfd0..3920385 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -158,6 +158,7 @@
 
 #define lv_is_thin_type(lv)	((lv)->status & (THIN_POOL | THIN_VOLUME | THIN_POOL_DATA | THIN_POOL_METADATA) ? 1 : 0)
 #define lv_is_mirror_type(lv)	((lv)->status & (MIRROR_LOG | MIRROR_IMAGE | MIRRORED | PVMOVE) ? 1 : 0)
+#define lv_is_raid(lv)		(((lv)->status & (RAID)) ? 1 : 0)
 #define lv_is_raid_type(lv)	(((lv)->status & (RAID | RAID_IMAGE | RAID_META)) ? 1 : 0)
 
 #define lv_is_virtual(lv)	(((lv)->status & VIRTUAL) ? 1 : 0)


