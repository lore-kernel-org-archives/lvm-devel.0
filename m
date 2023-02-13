From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Feb 2023 13:31:28 +0000 (GMT)
Subject: main - libdm: improve parallel create of control node
Message-ID: <20230213133128.28A0D3881D1D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7e14835a46a6c9e66087d6502d23df53c2a9954f
Commit:        7e14835a46a6c9e66087d6502d23df53c2a9954f
Parent:        cf0dc9a13cf365859e7dad3bb1ad02040925ae11
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 12 23:44:43 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 13 13:41:59 2023 +0100

libdm: improve parallel create of control node

When two parallel commands would have tried to create our
/dev/mapper/control node at the same time, one of them could
actually fail even if the 2nd. command actually mknod()
this control node correctly.

So for EEXIST case add detection if the control node is ok.

This may possibly help with some race case in early boot.
---
 device_mapper/ioctl/libdm-iface.c | 9 +++++++--
 libdm/ioctl/libdm-iface.c         | 9 +++++++--
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index d25b07800..ffcbc8a48 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -312,8 +312,13 @@ static int _create_control(const char *control, uint32_t major, uint32_t minor)
 	old_umask = umask(DM_CONTROL_NODE_UMASK);
 	if (mknod(control, S_IFCHR | S_IRUSR | S_IWUSR,
 		  MKDEV(major, minor)) < 0)  {
-		log_sys_error("mknod", control);
-		ret = 0;
+		if (errno != EEXIST) {
+			log_sys_error("mknod", control);
+			ret = 0;
+		} else if (_control_exists(control, major, minor) != 1) {
+			stack; /* Invalid control node created by parallel command ? */
+			ret = 0;
+		}
 	}
 	umask(old_umask);
 	(void) dm_prepare_selinux_context(NULL, 0);
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index dfa91b866..2e2da8b99 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -311,8 +311,13 @@ static int _create_control(const char *control, uint32_t major, uint32_t minor)
 	old_umask = umask(DM_CONTROL_NODE_UMASK);
 	if (mknod(control, S_IFCHR | S_IRUSR | S_IWUSR,
 		  MKDEV(major, minor)) < 0)  {
-		log_sys_error("mknod", control);
-		ret = 0;
+		if (errno != EEXIST) {
+			log_sys_error("mknod", control);
+			ret = 0;
+		} else if (_control_exists(control, major, minor) != 1) {
+			stack; /* Invalid control node created by parallel command ? */
+			ret = 0;
+		}
 	}
 	umask(old_umask);
 	(void) dm_prepare_selinux_context(NULL, 0);

