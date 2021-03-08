From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Mar 2021 14:46:54 +0000 (GMT)
Subject: main - cleanup: avoid allocating memory for hash key
Message-ID: <20210308144654.836673952035@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dac990ae03f9517e050f8ea3a55529e944c60f4f
Commit:        dac990ae03f9517e050f8ea3a55529e944c60f4f
Parent:        d3cff64408d63dfae20e3e3b307915dc08436ef8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 4 18:17:03 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 8 15:43:27 2021 +0100

cleanup: avoid allocating memory for hash key

Hash always allocates its own copy of the key so avoid
this extra uuid copy.
---
 lib/format_text/export.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index 7a95bdba4..cdae8bc87 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -955,7 +955,8 @@ static int _build_pv_names(struct formatter *f, struct volume_group *vg)
 	int count = 0;
 	struct pv_list *pvl;
 	struct physical_volume *pv;
-	char buffer[32], *uuid, *name;
+	char buffer[32], *name;
+	char uuid[64];
 
 	if (!(f->mem = dm_pool_create("text pv_names", 512)))
 		return_0;
@@ -973,8 +974,7 @@ static int _build_pv_names(struct formatter *f, struct volume_group *vg)
 		if (!(name = dm_pool_strdup(f->mem, buffer)))
 			return_0;
 
-		if (!(uuid = dm_pool_zalloc(f->mem, 64)) ||
-		   !id_write_format(&pv->id, uuid, 64))
+		if (!id_write_format(&pv->id, uuid, sizeof(uuid)))
 			return_0;
 
 		if (!dm_hash_insert(f->pv_names, uuid, name))


