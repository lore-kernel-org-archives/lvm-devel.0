From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 21 Sep 2021 19:51:02 +0000 (GMT)
Subject: main - gcc-fanalyzer: zallocate memory for clean buffer
Message-ID: <20210921195102.C78233858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8c4459782000ffe8b6c21a710e15464f5905ab3a
Commit:        8c4459782000ffe8b6c21a710e15464f5905ab3a
Parent:        4ef8f7cde6ea481f96f101dc6189979cf3674cfe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 21 18:36:44 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 21 21:03:47 2021 +0200

gcc-fanalyzer: zallocate memory for clean buffer

---
 lib/label/hints.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/label/hints.c b/lib/label/hints.c
index 47236a15a..3dba9f8ec 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -821,7 +821,7 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 			if (!dm_strncpy(hint.vgname, vgname + 3, sizeof(hint.vgname)))
 				continue;
 
-		if (!(alloc_hint = malloc(sizeof(struct hint)))) {
+		if (!(alloc_hint = zalloc(sizeof(struct hint)))) {
 			ret = 0;
 			break;
 		}


