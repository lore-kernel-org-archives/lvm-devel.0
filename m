From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 07:40:44 -0400
Subject: master - cleanup: shorten dump output code
Message-ID: <201707171140.v6HBeiUl022570@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=55f9e2f39996ad325425d99d4631120e8271cfcd
Commit:        55f9e2f39996ad325425d99d4631120e8271cfcd
Parent:        f6c2ee57fa97d374682c229a87700debf5f9302a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 16 18:22:52 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 12:32:18 2017 +0200

cleanup: shorten dump output code

Save couple lines on code with simpler code.
---
 daemons/lvmetad/lvmetad-core.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index a0821a3..f56eede 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -2578,14 +2578,12 @@ static void _dump_pairs(struct buffer *buf, struct dm_hash_table *ht, const char
 	dm_hash_iterate(n, ht) {
 		const char *key = dm_hash_get_key(ht, n),
 			   *val = dm_hash_get_data(ht, n);
-		buffer_append(buf, "    ");
 		if (int_key)
-			(void) dm_asprintf(&append, "%d = \"%s\"", *(const int*)key, val);
+			(void) dm_asprintf(&append, "    %d = \"%s\"\n", *(const int*)key, val);
 		else
-			(void) dm_asprintf(&append, "%s = \"%s\"", key, val);
+			(void) dm_asprintf(&append, "    %s = \"%s\"\n", key, val);
 		if (append)
 			buffer_append(buf, append);
-		buffer_append(buf, "\n");
 		dm_free(append);
 	}
 	buffer_append(buf, "}\n");
@@ -2603,11 +2601,9 @@ static void _dump_info_version(struct buffer *buf, struct dm_hash_table *ht, con
 	while (n) {
 		const char *key = dm_hash_get_key(ht, n);
 		info = dm_hash_get_data(ht, n);
-		buffer_append(buf, "    ");
-		(void) dm_asprintf(&append, "%s = %lld", key, (long long)info->external_version);
+		(void) dm_asprintf(&append, "    %s = %lld\n", key, (long long)info->external_version);
 		if (append)
 			buffer_append(buf, append);
-		buffer_append(buf, "\n");
 		dm_free(append);
 		n = dm_hash_get_next(ht, n);
 	}
@@ -2626,11 +2622,9 @@ static void _dump_info_flags(struct buffer *buf, struct dm_hash_table *ht, const
 	while (n) {
 		const char *key = dm_hash_get_key(ht, n);
 		info = dm_hash_get_data(ht, n);
-		buffer_append(buf, "    ");
-		(void) dm_asprintf(&append, "%s = %llx", key, (long long)info->flags);
+		(void) dm_asprintf(&append, "    %s = %llx\n", key, (long long)info->flags);
 		if (append)
 			buffer_append(buf, append);
-		buffer_append(buf, "\n");
 		dm_free(append);
 		n = dm_hash_get_next(ht, n);
 	}


