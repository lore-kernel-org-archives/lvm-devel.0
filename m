From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  1 Jul 2013 21:13:25 +0000 (UTC)
Subject: master - cleanup: move bit flags in order
Message-ID: <20130701211325.AA4BF610D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=afea2bf5982f9a060766c1b67cbbc97ea4ecba2d
Commit:        afea2bf5982f9a060766c1b67cbbc97ea4ecba2d
Parent:        2ab7699ec65e3e01ec87ecd27e03b462b3ad69f3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jun 30 17:06:09 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 1 23:06:41 2013 +0200

cleanup: move bit flags in order

Preseve the sequence of bits.
---
 lib/metadata/metadata-exported.h |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 10aea9e..6fa0c5b 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -53,6 +53,13 @@
 //#define BADBLOCK_ON		UINT64_C(0x00000020)	/* LV */
 #define VISIBLE_LV		UINT64_C(0x00000040)	/* LV */
 #define FIXED_MINOR		UINT64_C(0x00000080)	/* LV */
+
+#define LVM_READ		UINT64_C(0x00000100)	/* LV, VG */
+#define LVM_WRITE		UINT64_C(0x00000200)	/* LV, VG */
+
+#define CLUSTERED		UINT64_C(0x00000400)	/* VG */
+//#define SHARED		UINT64_C(0x00000800)	/* VG */
+
 /* FIXME Remove when metadata restructuring is completed */
 #define SNAPSHOT		UINT64_C(0x00001000)	/* LV - internal use only */
 #define PVMOVE			UINT64_C(0x00002000)	/* VG LV SEG */
@@ -92,12 +99,6 @@
 
 #define LV_WRITEMOSTLY		UINT64_C(0x0000010000000000)	/* LV (RAID1) */
 
-#define LVM_READ		UINT64_C(0x00000100)	/* LV, VG */
-#define LVM_WRITE		UINT64_C(0x00000200)	/* LV, VG */
-
-#define CLUSTERED		UINT64_C(0x00000400)	/* VG */
-//#define SHARED		UINT64_C(0x00000800)	/* VG */
-
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
 #define FMT_MDAS		0x00000002U	/* Proper metadata areas? */


