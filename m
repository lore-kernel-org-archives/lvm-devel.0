From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  1 Apr 2016 13:37:46 +0000 (UTC)
Subject: master - fix: make udev_get_library_context available also for non-udev compilations
Message-ID: <20160401133746.08C4660D55@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f28eb4c20ecb772f1b8a912c43f243d63a7e5f3
Commit:        9f28eb4c20ecb772f1b8a912c43f243d63a7e5f3
Parent:        15d1824facce1ac38c2669b17c8c0965b8c18f3e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Apr 1 15:35:13 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Apr 1 15:35:22 2016 +0200

fix: make udev_get_library_context available also for non-udev compilations

If compiling without udev_sync support, udev_get_library_context simply
returns NULL so we don't need to remember putting ifdef UDEV_SYNC_SUPPORT
in the code all the time we just need to check whether there's any udev
context initialized or not.
---
 lib/misc/lvm-wrappers.c |    7 ++++++-
 lib/misc/lvm-wrappers.h |    6 +-----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/lib/misc/lvm-wrappers.c b/lib/misc/lvm-wrappers.c
index e8e2e92..e2b14aa 100644
--- a/lib/misc/lvm-wrappers.c
+++ b/lib/misc/lvm-wrappers.c
@@ -66,7 +66,7 @@ bad:
 	return 0;
 }
 
-struct udev* udev_get_library_context(void)
+void *udev_get_library_context(void)
 {
 	return _udev;
 }
@@ -78,6 +78,11 @@ int udev_init_library_context(void)
 	return 1;
 }
 
+void *udev_get_library_context(void)
+{
+	return NULL;
+}
+
 void udev_fin_library_context(void)
 {
 }
diff --git a/lib/misc/lvm-wrappers.h b/lib/misc/lvm-wrappers.h
index c2d5123..3c45aff 100644
--- a/lib/misc/lvm-wrappers.h
+++ b/lib/misc/lvm-wrappers.h
@@ -16,12 +16,8 @@
 #ifndef _LVM_WRAPPERS_H
 #define _LVM_WRAPPERS_H
 
-#ifdef UDEV_SYNC_SUPPORT
-struct udev;
-struct udev *udev_get_library_context(void);
-#endif
-
 int udev_init_library_context(void);
+void *udev_get_library_context(void);
 void udev_fin_library_context(void);
 int udev_is_running(void);
 


