From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:39 +0000 (GMT)
Subject: main - cov: memleak on error path
Message-ID: <20210310003639.EEFFF3858038@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a6075fe2f259c4b2abd946cf06f9b507f9a7a49e
Commit:        a6075fe2f259c4b2abd946cf06f9b507f9a7a49e
Parent:        241c63f7a72cecad085c8983b8a294d8d9985119
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 15:38:54 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:29:44 2021 +0100

cov: memleak on error path

---
 lib/device/dev-cache.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 6cf798858..05b2b9bff 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1713,8 +1713,10 @@ static int _setup_devices_list(struct cmd_context *cmd)
 		if (!(du = zalloc(sizeof(struct dev_use))))
 			return_0;
 
-		if (!(du->devname = strdup(strl->str)))
+		if (!(du->devname = strdup(strl->str))) {
+			free(du);
 			return_0;
+		}
 
 		dm_list_add(&cmd->use_devices, &du->list);
 	}


