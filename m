From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:37 +0000 (GMT)
Subject: main - device_id: fix memleak and free idname
Message-ID: <20210423210537.E1949394480D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=80ef9138726c85e837dbb5a7572178f8b972e300
Commit:        80ef9138726c85e837dbb5a7572178f8b972e300
Parent:        65c4f81dc2eebe4096c48159f2fbd1107e284aea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 23 00:25:14 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 22:57:08 2021 +0200

device_id: fix memleak and free idname

Remove extra code path used only for 'free()'
and free(idname) on all paths that do not add it to list
and avoid memleak in few cases.
---
 lib/device/device_id.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index cf5867dab..1a9705f04 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -1008,21 +1008,24 @@ id_done:
 			break;
 		}
 	}
-	if (found_id && !strcmp(id->idname, idname)) {
-		free((char *)idname);
-	} else if (found_id && strcmp(id->idname, idname)) {
+
+	if (found_id && idname && strcmp(id->idname, idname)) {
 		dm_list_del(&id->list);
 		free_did(id);
 		found_id = 0;
 	}
 	if (!found_id) {
-		if (!(id = zalloc(sizeof(struct dev_id))))
+		if (!(id = zalloc(sizeof(struct dev_id)))) {
+			free((char *)idname);
 			return_0;
+		}
 		id->idtype = idtype;
 		id->idname = (char *)idname;
 		id->dev = dev;
 		dm_list_add(&dev->ids, &id->list);
-	}
+	} else
+		free((char*)idname);
+
 	dev->id = id;
 	dev->flags |= DEV_MATCHED_USE_ID;
 


