From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Feb 2021 14:04:18 +0000 (GMT)
Subject: main - cleanup: simplify initilization
Message-ID: <20210223140418.AA8A83939C17@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5237175cb6486c782589d7c9afb4f532ee5897b1
Commit:        5237175cb6486c782589d7c9afb4f532ee5897b1
Parent:        b5f906e984abea169209302b78bfa935869d6ea4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 20 22:44:06 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 14:56:48 2021 +0100

cleanup: simplify initilization

Simplier code and also drop duplicate check for active LV.
---
 tools/lvconvert.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4dee97ee0..a67b4ee72 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -6126,7 +6126,7 @@ int lvconvert_writecache_attach_single(struct cmd_context *cmd,
 	struct volume_group *vg = lv->vg;
 	struct logical_volume *lv_wcorig;
 	struct logical_volume *lv_fast;
-	struct writecache_settings settings;
+	struct writecache_settings settings = { 0 };
 	const char *fast_name;
 	uint32_t block_size_sectors = 0;
 	char *lockd_fast_args = NULL;
@@ -6181,10 +6181,6 @@ int lvconvert_writecache_attach_single(struct cmd_context *cmd,
 
 	is_active = lv_is_active(lv);
 
-	is_active = lv_is_active(lv);
-
-	memset(&settings, 0, sizeof(settings));
-
 	if (!get_writecache_settings(cmd, &settings, &block_size_sectors)) {
 		log_error("Invalid writecache settings.");
 		goto bad;


