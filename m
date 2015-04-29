From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 29 Apr 2015 11:24:18 +0000 (UTC)
Subject: master - lvmetad: Avoid duplicate entries in the list of alternate devices.
Message-ID: <20150429112418.472F061094@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4946c64092a04d6a5a7a09a31f7c74c193d3484f
Commit:        4946c64092a04d6a5a7a09a31f7c74c193d3484f
Parent:        3be3eb2995f83ab73a2a1419b1db5f1098fcb5a8
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Apr 23 01:39:39 2015 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Wed Apr 29 13:23:23 2015 +0200

lvmetad: Avoid duplicate entries in the list of alternate devices.

---
 daemons/lvmetad/lvmetad-core.c |   29 +++++++++++++++++++++++------
 1 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 1a2ce44..e3394ab 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -936,12 +936,29 @@ static response pv_found(lvmetad_state *s, request r)
 			altdev = dm_config_clone_node(cft, altdev, 0);
 			chain_node(altdev, cft->root, 0);
 		} else
-			altdev = make_config_node(cft, "devices_alternate", cft->root, 0);
-		if (!altdev || !(altdev_v = dm_config_create_value(cft)))
-			goto out_of_mem;
-		altdev_v->next = altdev->v;
-		altdev->v = altdev_v;
-		altdev->v->v.i = device_old_pvid;
+			if (!(altdev = make_config_node(cft, "devices_alternate", cft->root, 0)))
+				goto out_of_mem;
+                altdev_v = altdev->v;
+                while (1) {
+			if (altdev_v && altdev_v->v.i == device_old_pvid)
+				break;
+			if (altdev_v)
+				altdev_v = altdev_v->next;
+			if (!altdev_v) {
+				if (!(altdev_v = dm_config_create_value(cft)))
+					goto out_of_mem;
+				altdev_v->next = altdev->v;
+				altdev->v = altdev_v;
+				altdev->v->v.i = device_old_pvid;
+				break;
+			}
+		};
+		altdev_v = altdev->v;
+		while (altdev_v) {
+			if (altdev_v->next && altdev_v->next->v.i == device)
+				altdev_v->next = altdev_v->next->next;
+			altdev_v = altdev_v->next;
+		}
 		changed |= 1;
 	}
 


