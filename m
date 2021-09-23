From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Sep 2021 14:52:36 +0000 (GMT)
Subject: main - libdm: support DM_NAME_LIST_FLAG
Message-ID: <20210923145236.319AF3858D35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=566c2f1828d371d602eca0353905128d069a159b
Commit:        566c2f1828d371d602eca0353905128d069a159b
Parent:        ee15065a0f77bf01d1f4184462844f690cde64a8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 22 21:22:59 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 23 16:49:14 2021 +0200

libdm: support DM_NAME_LIST_FLAG

Kernel patch 8b638081bd4520f63db1defc660666ec5f65bc15
introduced support to return UUID in DM_LIST_DEVICES_CMD.

Useful when asking for UUID of each device where the list
could be now returned directly with NAME && UUID for each device.

Returning UUID is done in backward-compatible way. There's one unused
32-bit word value after the event number. This patch sets the bit
DM_NAME_LIST_FLAG_HAS_UUID if UUID is present and
DM_NAME_LIST_FLAG_DOESNT_HAVE_UUID if it isn't (if none of these bits is
set, then we have an old kernel that doesn't support returning UUIDs). The
UUID is stored after this word. The 'next' value is updated to point after
the UUID, so that old version of libdevmapper will skip the UUID without
attempting to interpret it.
---
 WHATS_NEW_DM          |  1 +
 libdm/misc/dm-ioctl.h | 14 ++++++++++++++
 2 files changed, 15 insertions(+)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c4a22441c..94d782c56 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.181 - 
 ===================================
+  Add defines DM_NAME_LIST_FLAG_HAS_UUID, DM_NAME_LIST_FLAG_DOESNT_HAVE_UUID.
   Enhance tracking of activated devices when preloading dm tree.
   Fix bug in construction of cache table line (regression from 1.02.159).
 
diff --git a/libdm/misc/dm-ioctl.h b/libdm/misc/dm-ioctl.h
index 52a7a93d1..cecfd5909 100644
--- a/libdm/misc/dm-ioctl.h
+++ b/libdm/misc/dm-ioctl.h
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


