From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Jun 2013 20:14:09 +0000 (UTC)
Subject: master - cleanup: return lv_is_ as 1 or 0
Message-ID: <20130618201409.B391360ECB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f990b7298d46280d50e2813ea92212a7e595e567
Commit:        f990b7298d46280d50e2813ea92212a7e595e567
Parent:        c5957ee2ffc2cfce1f1304349e2304bd489c5903
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 17 19:46:22 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 18 22:13:42 2013 +0200

cleanup: return lv_is_ as 1 or 0

Do not return 64bit values - return just plain int 0 or 1
---
 lib/metadata/metadata-exported.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 5fb5b6c..10aea9e 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -150,9 +150,9 @@
 
 #define lv_is_thin_type(lv)	((lv)->status & (THIN_POOL | THIN_VOLUME | THIN_POOL_DATA | THIN_POOL_METADATA) ? 1 : 0)
 #define lv_is_mirror_type(lv)	((lv)->status & (MIRROR_LOG | MIRROR_IMAGE | MIRRORED | PVMOVE) ? 1 : 0)
-#define lv_is_raid_type(lv)	((lv)->status & (RAID | RAID_IMAGE | RAID_META))
+#define lv_is_raid_type(lv)	(((lv)->status & (RAID | RAID_IMAGE | RAID_META)) ? 1 : 0)
 
-#define lv_is_virtual(lv)	((lv)->status & VIRTUAL)
+#define lv_is_virtual(lv)	(((lv)->status & VIRTUAL) ? 1 : 0)
 
 /* Ordered list - see lv_manip.c */
 typedef enum {


