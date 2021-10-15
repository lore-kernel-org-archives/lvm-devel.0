From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 15 Oct 2021 21:42:27 +0000 (GMT)
Subject: main - cov: check device_ids_write return code
Message-ID: <20211015214227.5A4EF3858405@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bae1083472d9c589d59f93a4e0a137cb94ba5ed0
Commit:        bae1083472d9c589d59f93a4e0a137cb94ba5ed0
Parent:        c2be6c38d5d878861b7d4ce601a64bcb88bbe38e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 15 15:04:43 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 15 23:40:56 2021 +0200

cov: check device_ids_write return code

At least 'stack' failure code path as the
function device_id_update_vg_uuid() is void.
---
 lib/device/device_id.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index e4208c56b..eb06109ff 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -1351,8 +1351,9 @@ void device_id_update_vg_uuid(struct cmd_context *cmd, struct volume_group *vg,
 		}
 	}
 
-	if (update)
-		device_ids_write(cmd);
+	if (update &&
+	    !device_ids_write(cmd))
+		stack;
  out:
 	unlock_devices_file(cmd);
 }


