From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 20:41:36 +0000 (UTC)
Subject: master - cleanup: use braces around macro params
Message-ID: <20160223204136.9F2EB603B0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9267e0c5e73b74177fc54dda200f012765b33673
Commit:        9267e0c5e73b74177fc54dda200f012765b33673
Parent:        63c052b9e2a69b94fea33490130e76aac9a8c735
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 19:51:45 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 21:40:17 2016 +0100

cleanup: use braces around macro params

---
 lib/device/dev-type.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 75ef36f..5494511 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -21,9 +21,9 @@
 #define NUMBER_OF_MAJORS 4096
 
 #ifdef __linux__
-#  define MAJOR(dev)	((dev & 0xfff00) >> 8)
-#  define MINOR(dev)	((dev & 0xff) | ((dev >> 12) & 0xfff00))
-#  define MKDEV(ma,mi)	((mi & 0xff) | (ma << 8) | ((mi & ~0xff) << 12))
+#  define MAJOR(dev)	(((dev) & 0xfff00) >> 8)
+#  define MINOR(dev)	(((dev) & 0xff) | (((dev) >> 12) & 0xfff00))
+#  define MKDEV(ma,mi)	(((mi) & 0xff) | ((ma) << 8) | (((mi) & ~0xff) << 12))
 #else
 #  define MAJOR(x) major((x))
 #  define MINOR(x) minor((x))


