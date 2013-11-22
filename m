From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:09:23 +0000 (UTC)
Subject: master - cleanup: use string directly
Message-ID: <20131122200923.DC64C61097@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=07d766d270f764e3a8300fee79ac559d18f21e66
Commit:        07d766d270f764e3a8300fee79ac559d18f21e66
Parent:        3e0fb102dece1a4d476496c3b6291e319b6305be
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 13:24:53 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 21:00:55 2013 +0100

cleanup: use string directly

---
 lib/misc/lvm-wrappers.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/misc/lvm-wrappers.c b/lib/misc/lvm-wrappers.c
index a96cd98..46590b9 100644
--- a/lib/misc/lvm-wrappers.c
+++ b/lib/misc/lvm-wrappers.c
@@ -18,7 +18,6 @@
 #include <fcntl.h>
 
 #ifdef UDEV_SYNC_SUPPORT
-static const char _no_context_msg[] = "Udev library context not set.";
 struct udev *_udev;
 
 int udev_init_library_context(void)
@@ -46,7 +45,7 @@ int udev_is_running(void)
 	int r;
 
 	if (!_udev) {
-		log_debug_activation(_no_context_msg);
+		log_debug_activation("Udev library context not set.");
 		goto bad;
 	}
 


