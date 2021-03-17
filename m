From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Mar 2021 00:00:40 +0000 (GMT)
Subject: main - cleanup: use dm_strncpy
Message-ID: <20210317000040.1F4B3386181D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=94701b700b83971a49c242e070070526d4eb42dd
Commit:        94701b700b83971a49c242e070070526d4eb42dd
Parent:        4d75c4f597b28e4ea014ef61082074187dc6245a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 16 14:06:24 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 17 00:50:22 2021 +0100

cleanup: use dm_strncpy

Use own function.
---
 lib/activate/dev_manager.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index cd9d27e11..aa88e6868 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -839,8 +839,7 @@ static int _info(struct cmd_context *cmd,
 			if (strcmp(suffix_position + 1, suffix))
 				continue;
 
-			(void) strncpy(old_style_dlid, dlid, sizeof(old_style_dlid));
-			old_style_dlid[sizeof(old_style_dlid) - 1] = '\0';
+			(void) dm_strncpy(old_style_dlid, dlid, sizeof(old_style_dlid));
 			if (!_info_run(old_style_dlid, dminfo, read_ahead, seg_status,
 				       name_check, with_open_count, with_read_ahead,
 				       0, 0))


