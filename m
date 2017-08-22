From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Aug 2017 04:33:57 -0400
Subject: master - libdm: fix errpath for control node creation
Message-ID: <201708220833.v7M8XvqZ031025@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0e42b31dc3be45c29abd90369c02c077d1763ff0
Commit:        0e42b31dc3be45c29abd90369c02c077d1763ff0
Parent:        df5c2964269895b6f5ce16dbdb70edd57c5aa67d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 22 10:19:40 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 22 10:23:29 2017 +0200

libdm: fix errpath for control node creation

When control node failure happens, umask was not restored.
Fix it by using common exit path.
---
 WHATS_NEW_DM              |    1 +
 libdm/ioctl/libdm-iface.c |    5 ++---
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d3cc78c..766eb20 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.143 - 
 =================================
+  Restore umask when creation of node fails.
   Add --concise to dmsetup create for many devices with tables in one command.
   Accept minor number without major in library when it knows dm major number.
   Introduce single-line concise table output format: dmsetup table --concise
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index e32af80..63d305b 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -293,13 +293,12 @@ static int _create_control(const char *control, uint32_t major, uint32_t minor)
 	if (mknod(control, S_IFCHR | S_IRUSR | S_IWUSR,
 		  MKDEV((dev_t)major, (dev_t)minor)) < 0)  {
 		log_sys_error("mknod", control);
-		(void) dm_prepare_selinux_context(NULL, 0);
-		return 0;
+		ret = 0;
 	}
 	umask(old_umask);
 	(void) dm_prepare_selinux_context(NULL, 0);
 
-	return 1;
+	return ret;
 }
 #endif
 


