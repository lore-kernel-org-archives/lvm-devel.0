From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 16:53:15 +0000 (GMT)
Subject: main - vgimportdevices: LOCK_EX requires <sys/file.h> include
Message-ID: <20230210165315.73DFA3858C5F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a1a1439215f56335a06ae5ac6ca73b5e0d734760
Commit:        a1a1439215f56335a06ae5ac6ca73b5e0d734760
Parent:        be124ae81027e8736106e4958bd2dfab971d6764
Author:        Jory Pratt <anarchy@gentoo.org>
AuthorDate:    Tue Feb 7 14:27:12 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 17:50:27 2023 +0100

vgimportdevices: LOCK_EX requires <sys/file.h> include

https://linux.die.net/man/2/flock

Bug: https://bugs.gentoo.org/887259
---
 tools/vgimportdevices.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/tools/vgimportdevices.c b/tools/vgimportdevices.c
index ab359d31c..07d07402a 100644
--- a/tools/vgimportdevices.c
+++ b/tools/vgimportdevices.c
@@ -15,6 +15,8 @@
 #include "tools.h"
 #include "lib/cache/lvmcache.h"
 #include "lib/device/device_id.h"
+/* coverity[unnecessary_header] needed for MuslC */
+#include <sys/file.h>
 
 struct vgimportdevices_params {
 	uint32_t added_devices;

