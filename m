From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Oct 2019 07:41:33 -0400
Subject: master - gcc: older version can't see udev is always set
Message-ID: <201910221141.x9MBfXSc025765@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a7563dc6a1f8b46e13c6cf1a7fbeeb611310b29a
Commit:        a7563dc6a1f8b46e13c6cf1a7fbeeb611310b29a
Parent:        967e2decd22cee4aa4426cfda5732860e1a085b3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 22 10:43:11 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 22 13:39:22 2019 +0200

gcc: older version can't see udev is always set

---
 lib/device/dev-cache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index a15e239..3dcfc10 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1087,7 +1087,7 @@ out:
 static void _insert_dirs(struct dm_list *dirs)
 {
 	struct dir_list *dl;
-	struct udev *udev;
+	struct udev *udev = NULL;
 	int with_udev;
 
 	with_udev = obtain_device_list_from_udev() &&


