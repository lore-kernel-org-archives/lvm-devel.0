From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 21 Apr 2016 23:18:32 +0000 (UTC)
Subject: master - cleanup: use kdev_t header in lvm tree
Message-ID: <20160421231832.679BC616D8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=556eba183520821e6fb709253e3e12ba48a5fcdf
Commit:        556eba183520821e6fb709253e3e12ba48a5fcdf
Parent:        9d4f9defc31f0459f91979909a0c94bbb87af9c0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 21 20:52:12 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 22 00:23:28 2016 +0200

cleanup: use kdev_t header in lvm tree

Reuse libdm header in lvm so we have single definition
of MAJOR/MINOR/MKDEV macros in use.
---
 lib/device/dev-type.h |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 5494511..6438b44 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -21,9 +21,7 @@
 #define NUMBER_OF_MAJORS 4096
 
 #ifdef __linux__
-#  define MAJOR(dev)	(((dev) & 0xfff00) >> 8)
-#  define MINOR(dev)	(((dev) & 0xff) | (((dev) >> 12) & 0xfff00))
-#  define MKDEV(ma,mi)	(((mi) & 0xff) | ((ma) << 8) | (((mi) & ~0xff) << 12))
+#  include "kdev_t.h"
 #else
 #  define MAJOR(x) major((x))
 #  define MINOR(x) minor((x))


