From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 30 Sep 2013 09:23:31 +0000 (UTC)
Subject: master - libdm: export DM_UDEV_SUBSYSTEM_FLAG names for subystem udev flags
Message-ID: <20130930092331.0D6A661132@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=23ce3352d7e6ad122b3b173ffb739848bec6a7bd
Commit:        23ce3352d7e6ad122b3b173ffb739848bec6a7bd
Parent:        ec9b3dcecc8fe153a8838419f3ad9f0f7b7d5ad3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 30 11:19:09 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 30 11:19:09 2013 +0200

libdm: export DM_UDEV_SUBSYSTEM_FLAG names for subystem udev flags

Just like we have symbolic names assigned to general DM udev flags
(DM_UDEV_* flags), we have the same for any subsystem flags now
(DM_SUBSYSTEM_UDEV_FLAG*), making it easier to use.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdevmapper.h |   12 ++++++++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 8456edd..dfc2d89 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.82 - 
 =====================================
+  Define symbolic names for subsystem udev flags in libdevmapper for easier use.
   Make subsystem udev rules responsible for importing DM_SUBSYSTEM_UDEV_FLAG*.
 
 Version 1.02.81 - 23rd September 2013
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index b287eef..aaf00b2 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1753,6 +1753,18 @@ struct dm_pool *dm_config_memory(struct dm_config_tree *cft);
  */
 #define DM_UDEV_PRIMARY_SOURCE_FLAG 0x0040
 
+/*
+ * Udev flags reserved for use by any device-mapper subsystem.
+ */
+#define DM_SUBSYSTEM_UDEV_FLAG0 0x0100
+#define DM_SUBSYSTEM_UDEV_FLAG1 0x0200
+#define DM_SUBSYSTEM_UDEV_FLAG2 0x0400
+#define DM_SUBSYSTEM_UDEV_FLAG3 0x0800
+#define DM_SUBSYSTEM_UDEV_FLAG4 0x1000
+#define DM_SUBSYSTEM_UDEV_FLAG5 0x2000
+#define DM_SUBSYSTEM_UDEV_FLAG6 0x4000
+#define DM_SUBSSYTEM_UDEV_FLAG7 0x8000
+
 int dm_cookie_supported(void);
 
 /*


