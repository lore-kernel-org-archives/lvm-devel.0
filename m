From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Sep 2021 14:52:37 +0000 (GMT)
Subject: main - devicemapper: add DM_NAME_LIST_FLAG
Message-ID: <20210923145237.515B93858D34@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=707e7d762e2668af308457fd6d8b8375e18b0207
Commit:        707e7d762e2668af308457fd6d8b8375e18b0207
Parent:        566c2f1828d371d602eca0353905128d069a159b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 22 21:24:39 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 23 16:49:16 2021 +0200

devicemapper: add DM_NAME_LIST_FLAG

Match libdm part
---
 device_mapper/misc/dm-ioctl.h | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/device_mapper/misc/dm-ioctl.h b/device_mapper/misc/dm-ioctl.h
index cc2374c36..c00fa5b4f 100644
--- a/device_mapper/misc/dm-ioctl.h
+++ b/device_mapper/misc/dm-ioctl.h
@@ -194,8 +194,22 @@ struct dm_name_list {
 	uint32_t next;		/* offset to the next record from
 				   the _start_ of this */
 	char name[0];
+
+	/*
+	 * The following members can be accessed by taking a pointer that
+	 * points immediately after the terminating zero character in "name"
+	 * and aligning this pointer to next 8-byte boundary.
+	 * Uuid is present if the flag DM_NAME_LIST_FLAG_HAS_UUID is set.
+	 *
+	 * uint32_t event_nr;
+	 * uint32_t flags;
+	 * char uuid[0];
+	 */
 };
 
+#define DM_NAME_LIST_FLAG_HAS_UUID		1
+#define DM_NAME_LIST_FLAG_DOESNT_HAVE_UUID	2
+
 /*
  * Used to retrieve the target versions
  */


