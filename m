From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Nov 2018 18:32:56 -0500
Subject: master - libdm: add DM_DEVICE_ARM_POLL
Message-ID: <201811162332.wAGNWuVK015757@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1ae5bf2b833a5d55cf97de1619cc820d4e8c394f
Commit:        1ae5bf2b833a5d55cf97de1619cc820d4e8c394f
Parent:        10e191fd124e89d40518a7cba5d61c47be5a0969
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 16 15:58:16 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 17 00:30:50 2018 +0100

libdm: add DM_DEVICE_ARM_POLL

Expose DM_DEVICE_ARM_POLL via standard API enum.
---
 WHATS_NEW_DM                      |    1 +
 device_mapper/all.h               |    6 ++++--
 device_mapper/ioctl/libdm-iface.c |    3 +++
 libdm/ioctl/libdm-iface.c         |    3 +++
 libdm/libdevmapper.h              |    4 +++-
 5 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d0088c4..c19d9a8 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.155 - 
 ====================================
+  Add DM_DEVICE_ARM_POLL for API completness matching kernel.
   Do not add parameters for RESUME with DM_DEVICE_CREATE dm task.
 
 Version 1.02.153 - 31st October 2018
diff --git a/device_mapper/all.h b/device_mapper/all.h
index 6fe80f8..0c1dc29 100644
--- a/device_mapper/all.h
+++ b/device_mapper/all.h
@@ -116,10 +116,12 @@ enum {
 	DM_DEVICE_MKNODES,
 
 	DM_DEVICE_LIST_VERSIONS,
-	
+
 	DM_DEVICE_TARGET_MSG,
 
-	DM_DEVICE_SET_GEOMETRY
+	DM_DEVICE_SET_GEOMETRY,
+
+	DM_DEVICE_ARM_POLL
 };
 
 /*
diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index cc69317..31a4bc0 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -117,6 +117,9 @@ static struct cmd_data _cmd_data_v4[] = {
 #ifdef DM_DEV_SET_GEOMETRY
 	{"setgeometry",	DM_DEV_SET_GEOMETRY,	{4, 6, 0}},
 #endif
+#ifdef DM_DEV_ARM_POLL
+	{"armpoll",	DM_DEV_ARM_POLL,	{4, 36, 0}},
+#endif
 };
 /* *INDENT-ON* */
 
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 5c418a9..6e73b1d 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -115,6 +115,9 @@ static struct cmd_data _cmd_data_v4[] = {
 #ifdef DM_DEV_SET_GEOMETRY
 	{"setgeometry",	DM_DEV_SET_GEOMETRY,	{4, 6, 0}},
 #endif
+#ifdef DM_DEV_ARM_POLL
+	{"armpoll",	DM_DEV_ARM_POLL,	{4, 36, 0}},
+#endif
 };
 /* *INDENT-ON* */
 
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 2438f74..19032d7 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -119,7 +119,9 @@ enum {
 	
 	DM_DEVICE_TARGET_MSG,
 
-	DM_DEVICE_SET_GEOMETRY
+	DM_DEVICE_SET_GEOMETRY,
+
+	DM_DEVICE_ARM_POLL
 };
 
 /*


