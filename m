From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 16 Feb 2022 00:03:13 +0000 (GMT)
Subject: main - dev_manager: do not query for open_count
Message-ID: <20220216000313.7098E3858C2D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fa7b67eeebfc28bce355991eebe1b5f21f075e9a
Commit:        fa7b67eeebfc28bce355991eebe1b5f21f075e9a
Parent:        4fd76de4b69f8e5e6d5afa03d54cb4b8986c4bcc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 11 23:55:08 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 16 01:00:36 2022 +0100

dev_manager: do not query for open_count

Oepn count is not used along this code path.
---
 lib/activate/dev_manager.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 4d18d9838..feea06a47 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -2268,7 +2268,7 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 		return 1;
 	}
 
-	if (!_info(dm->cmd, name, dlid, 1, 0, 0, &info, NULL, NULL))
+	if (!_info(dm->cmd, name, dlid, 0, 0, 0, &info, NULL, NULL))
 		return_0;
 
 	/*


