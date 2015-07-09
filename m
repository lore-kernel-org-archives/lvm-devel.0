From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  9 Jul 2015 22:03:40 +0000 (UTC)
Subject: master - metadata: fix duplicated LV flag
Message-ID: <20150709220340.21EA061043@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d2c4dc034d685a8d1cf07131a2194ac925852ef
Commit:        3d2c4dc034d685a8d1cf07131a2194ac925852ef
Parent:        082fcc53cc82e77e42af014623f8d9df4f1be173
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 9 17:02:30 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 9 17:02:30 2015 -0500

metadata: fix duplicated LV flag

LOCKD_SANLOCK_LV was using the WRITEMOSTLY flag instead of a new one.
---
 lib/metadata/metadata-exported.h |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 63a57ca..03f959d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -101,8 +101,6 @@
 #define THIN_POOL_DATA		UINT64_C(0x0000004000000000)	/* LV - Internal use only */
 #define THIN_POOL_METADATA	UINT64_C(0x0000008000000000)	/* LV - Internal use only */
 #define POOL_METADATA_SPARE	UINT64_C(0x0000010000000000)	/* LV - Internal use only */
-#define LOCKD_SANLOCK_LV	UINT64_C(0x0000020000000000)	/* LV - Internal use only */
-
 #define LV_WRITEMOSTLY		UINT64_C(0x0000020000000000)	/* LV (RAID1) */
 
 #define LV_ACTIVATION_SKIP	UINT64_C(0x0000040000000000)	/* LV */
@@ -133,7 +131,8 @@
 #define PV_ALLOCATION_PROHIBITED	UINT64_C(0x0010000000000000)	/* PV - internal use only - allocation prohibited
 									e.g. to prohibit allocation of a RAID image
 									on a PV already holing an image of the RAID set */
-/* Next unused flag:		UINT64_C(0x0080000000000000)    */
+#define LOCKD_SANLOCK_LV	UINT64_C(0x0080000000000000)	/* LV - Internal use only */
+/* Next unused flag:		UINT64_C(0x0100000000000000)    */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */


