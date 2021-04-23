From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:39 +0000 (GMT)
Subject: main - devicesfile: use pool memory
Message-ID: <20210423210539.0EAF0393BC13@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2b90466f78892c1e578c830a72566662d137dace
Commit:        2b90466f78892c1e578c830a72566662d137dace
Parent:        80ef9138726c85e837dbb5a7572178f8b972e300
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 23 15:03:11 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 22:58:45 2021 +0200

devicesfile: use pool memory

Switch to use command mempool instead of zalloc() as relase
part would be required otherwise.
---
 lib/device/dev-cache.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 05b2b9bff..112296a81 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1710,13 +1710,11 @@ static int _setup_devices_list(struct cmd_context *cmd)
 	 */
 
 	dm_list_iterate_items(strl, &cmd->deviceslist) {
-		if (!(du = zalloc(sizeof(struct dev_use))))
+		if (!(du = dm_pool_zalloc(cmd->mem, sizeof(struct dev_use))))
 			return_0;
 
-		if (!(du->devname = strdup(strl->str))) {
-			free(du);
+		if (!(du->devname = dm_pool_strdup(cmd->mem, strl->str)))
 			return_0;
-		}
 
 		dm_list_add(&cmd->use_devices, &du->list);
 	}


