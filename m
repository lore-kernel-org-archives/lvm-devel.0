From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 Sep 2020 11:24:46 +0000 (GMT)
Subject: master - cov: drop model for origin_from_cow
Message-ID: <20200912112446.AD83638708A2@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a5d45b237dbb6d9c1984fd98ba84bce9bde0ea99
Commit:        a5d45b237dbb6d9c1984fd98ba84bce9bde0ea99
Parent:        a9cb96f146377ff59a34a40792a9d8537ec89755
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 12 09:45:52 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 12 13:23:49 2020 +0200

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


