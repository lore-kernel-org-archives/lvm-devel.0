From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 5 Mar 2019 08:53:37 -0500
Subject: stable-2.02 - libdm: add DM_DEVICE_ARM_POLL
Message-ID: <201903051353.x25DrbGG006764@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1bef4dfab39c9cef28df979a2b092a0dff79b2cc
Commit:        1bef4dfab39c9cef28df979a2b092a0dff79b2cc
Parent:        e974f6866af02f0d0727a434c3150ca408da2658
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 16 15:58:16 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 5 12:46:21 2019 +0100

libdm: add DM_DEVICE_ARM_POLL

Expose DM_DEVICE_ARM_POLL via standard API enum.

(cherry picked from commit 1ae5bf2b833a5d55cf97de1619cc820d4e8c394f)

Conflicts:
	WHATS_NEW_DM
	device_mapper/all.h
	device_mapper/ioctl/libdm-iface.c
---
 WHATS_NEW_DM              |    1 +
 libdm/ioctl/libdm-iface.c |    3 +++
 libdm/libdevmapper.h      |    4 +++-
 3 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 80b45be..ff92031 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.156 - 
 =====================================
+  Add DM_DEVICE_ARM_POLL for API completness matching kernel.
 
 Version 1.02.154 - 07th December 2018
 =====================================
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index cf7a279..863e812 100644
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


