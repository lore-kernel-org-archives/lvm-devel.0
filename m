From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 07:40:44 -0400
Subject: master - cleanup: drop const from allocated value
Message-ID: <201707171140.v6HBeiW2022575@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f6c2ee57fa97d374682c229a87700debf5f9302a
Commit:        f6c2ee57fa97d374682c229a87700debf5f9302a
Parent:        ba9820b14223b731125c83dbc9709aa44fdcdbf1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 16 18:21:41 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 12:32:18 2017 +0200

cleanup: drop const from allocated value

Avoid using const for casting to non-const.
---
 daemons/lvmetad/lvmetad-core.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 8910bd4..a0821a3 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1927,7 +1927,7 @@ static response pv_found(lvmetad_state *s, request r)
 	const char *arg_pvid = NULL;
 	const char *arg_pvid_lookup = NULL;
 	const char *new_pvid = NULL;
-	const char *new_pvid_dup = NULL;
+	char *new_pvid_dup = NULL;
 	const char *arg_name = NULL;
 	const char *arg_vgid = NULL;
 	const char *arg_vgid_lookup = NULL;
@@ -2090,7 +2090,7 @@ static response pv_found(lvmetad_state *s, request r)
 		if (!(new_pvid_dup = dm_strdup(new_pvid)))
 			goto nomem_free1;
 
-		if (!dm_hash_insert_binary(s->device_to_pvid, &new_device, sizeof(new_device), (char *)new_pvid_dup))
+		if (!dm_hash_insert_binary(s->device_to_pvid, &new_device, sizeof(new_device), new_pvid_dup))
 			goto nomem_free2;
 
 		if (!dm_hash_insert(s->pvid_to_pvmeta, new_pvid, new_pvmeta))
@@ -2138,7 +2138,7 @@ static response pv_found(lvmetad_state *s, request r)
 		if (!(new_pvid_dup = dm_strdup(new_pvid)))
 			goto nomem_free1;
 
-		if (!dm_hash_insert_binary(s->device_to_pvid, &arg_device, sizeof(arg_device), (char *)new_pvid_dup))
+		if (!dm_hash_insert_binary(s->device_to_pvid, &arg_device, sizeof(arg_device), new_pvid_dup))
 			goto nomem_free2;
 
 		if (!dm_hash_insert(s->pvid_to_pvmeta, new_pvid, new_pvmeta))
@@ -2251,7 +2251,7 @@ static response pv_found(lvmetad_state *s, request r)
 				   NULL);
 
  nomem_free2:
-	dm_free((char *)new_pvid_dup);
+	dm_free(new_pvid_dup);
  nomem_free1:
 	dm_config_destroy(new_pvmeta);
  nomem:


