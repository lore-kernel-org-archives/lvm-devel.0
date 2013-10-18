From: Mikulas Patocka <mpatocka@redhat.com>
Date: Thu, 17 Oct 2013 20:31:55 -0400 (EDT)
Subject: [PATCH] libdm: Fix memory corruption if dm_asprintf fails.
Message-ID: <alpine.LRH.2.02.1310172030470.5268@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I found this bug when reading through my lvm changes.

We must set the variable dmt->geometry to NULL after freeing it.

dm_asprintf may fail, on failure it may not set dmt->geometry, thus
dmt->geometry would be pointing to a free string.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 libdm/ioctl/libdm-iface.c |    1 +
 1 file changed, 1 insertion(+)

Index: lvm2-copy/libdm/ioctl/libdm-iface.c
===================================================================
--- lvm2-copy.orig/libdm/ioctl/libdm-iface.c	2013-10-18 02:26:07.000000000 +0200
+++ lvm2-copy/libdm/ioctl/libdm-iface.c	2013-10-18 02:26:16.000000000 +0200
@@ -817,6 +817,7 @@ int dm_task_set_geometry(struct dm_task
 			 const char *sectors, const char *start)
 {
 	dm_free(dmt->geometry);
+	dmt->geometry = NULL;
 	if (dm_asprintf(&(dmt->geometry), "%s %s %s %s",
 			cylinders, heads, sectors, start) < 0) {
 		log_error("dm_task_set_geometry: sprintf failed");


