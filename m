From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  6 Apr 2021 20:07:17 +0000 (GMT)
Subject: main - libdm: move dm_task_get_info_with_deferred_remove
Message-ID: <20210406200717.1B9093846079@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1398e66a556fd3ed79353819ca8bef4ccb351990
Commit:        1398e66a556fd3ed79353819ca8bef4ccb351990
Parent:        a8480f0f6e2585a66fb0a9e25135fde8fb11d997
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 3 00:01:00 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 6 21:26:57 2021 +0200

libdm: move dm_task_get_info_with_deferred_remove

Version is only needed for dm_task_get_info().
dm_task_get_info_with_deferred_remove() shall be compiled for
non-versioned library as well.
---
 libdm/ioctl/libdm-iface.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 5b17614e6..47f14398c 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -2225,6 +2225,8 @@ int dm_task_get_info_base(struct dm_task *dmt, struct dm_info *info)
 	return 1;
 }
 
+#endif
+
 int dm_task_get_info_with_deferred_remove(struct dm_task *dmt, struct dm_info *info);
 int dm_task_get_info_with_deferred_remove(struct dm_task *dmt, struct dm_info *info)
 {
@@ -2237,4 +2239,3 @@ int dm_task_get_info_with_deferred_remove(struct dm_task *dmt, struct dm_info *i
 
 	return 1;
 }
-#endif


