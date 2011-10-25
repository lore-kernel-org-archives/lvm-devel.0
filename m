From: Mikulas Patocka <mpatocka@redhat.com>
Date: Tue, 25 Oct 2011 09:03:40 -0400 (EDT)
Subject: [PATCH] Fix vgchange for sparse devices
Message-ID: <Pine.LNX.4.64.1110250902480.16067@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix vgchange for sparse devices

If we create a sparse snapshot volume with "lvcreate --virtualsize", the volume
is not activated or deactivated with vgchange.

This patch fixes it so that vgchange activates and deactivates such volumes.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 tools/vgchange.c |    4 ++++
 1 file changed, 4 insertions(+)

Index: LVM2.2.02.85/tools/vgchange.c
===================================================================
--- LVM2.2.02.85.orig/tools/vgchange.c	2011-05-19 17:41:17.000000000 +0200
+++ LVM2.2.02.85/tools/vgchange.c	2011-05-19 18:32:00.000000000 +0200
@@ -96,6 +96,10 @@ static int _activate_lvs_in_vg(struct cm
 		if (!lv_is_visible(lv))
 			continue;
 
+		/* If LV is sparse, activate origin instead */
+		if (lv_is_cow(lv) && lv_is_virtual_origin(origin_from_cow(lv)))
+			lv = origin_from_cow(lv);
+
 		/* Only request activation of snapshot origin devices */
 		if ((lv->status & SNAPSHOT) || lv_is_cow(lv))
 			continue;


