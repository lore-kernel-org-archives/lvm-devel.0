From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:23 +0000 (GMT)
Subject: stable-2.02 - cov: drop model for origin_from_cow
Message-ID: <20201016191123.8ACAA396EC94@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=92ee7e4c1fe1e6bc5be2fdd54a80d59da07d1fcd
Commit:        92ee7e4c1fe1e6bc5be2fdd54a80d59da07d1fcd
Parent:        9c6089b2d0472a6e212ad0838009f47d611ac1b2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 12 09:45:52 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:58 2020 +0200

cov: drop model for origin_from_cow

---
 coverity/coverity_model.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/coverity/coverity_model.c b/coverity/coverity_model.c
index 24a6afeef..a6840a6ed 100644
--- a/coverity/coverity_model.c
+++ b/coverity/coverity_model.c
@@ -46,6 +46,7 @@ const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile
 	return "STRING";
 }
 
+/*
 struct logical_volume *origin_from_cow(const struct logical_volume *lv)
 {
 	if (lv)
@@ -53,6 +54,7 @@ struct logical_volume *origin_from_cow(const struct logical_volume *lv)
 
 	__coverity_panic__();
 }
+*/
 
 /* simple_memccpy() from glibc */
 void *memccpy(void *dest, const void *src, int c, size_t n)


