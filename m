From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 07:40:11 -0400
Subject: master - lvmetad: fix memory leaks
Message-ID: <201707171140.v6HBeBIF022482@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=919fa89482b85eb467ecd9561c89c1dfdaae7217
Commit:        919fa89482b85eb467ecd9561c89c1dfdaae7217
Parent:        fb641c342343ac48cc623c8079900b1f4f395a69
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 16 10:20:37 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 12:27:53 2017 +0200

lvmetad: fix memory leaks

Hash tables need to release no longer needed inserted data.
---
 WHATS_NEW                      |    1 +
 daemons/lvmetad/lvmetad-core.c |   17 +++++++++++++++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 29678f4..2fece12 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.173 - 
 =================================
+  Fix memory leak in lvmetad when working with duplicates.
   Accept 'lvm -h' and 'lvm --help' as well as 'lvm help' for help.
   Suppress error message from accept() on clean lvmetad shutdown.
   Tidy clvmd client list processing and fix segfaults.
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index af5d429..8910bd4 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -258,6 +258,21 @@ static void destroy_metadata_hashes(lvmetad_state *s)
 	dm_hash_iterate(n, s->pvid_to_pvmeta)
 		dm_config_destroy(dm_hash_get_data(s->pvid_to_pvmeta, n));
 
+	dm_hash_iterate(n, s->vgid_to_vgname)
+		dm_free(dm_hash_get_data(s->vgid_to_vgname, n));
+
+	dm_hash_iterate(n, s->vgname_to_vgid)
+		dm_free(dm_hash_get_data(s->vgname_to_vgid, n));
+
+	dm_hash_iterate(n, s->vgid_to_info)
+		dm_free(dm_hash_get_data(s->vgid_to_info, n));
+
+	dm_hash_iterate(n, s->device_to_pvid)
+		dm_free(dm_hash_get_data(s->device_to_pvid, n));
+
+	dm_hash_iterate(n, s->pvid_to_vgid)
+		dm_free(dm_hash_get_data(s->pvid_to_vgid, n));
+
 	dm_hash_destroy(s->pvid_to_pvmeta);
 	dm_hash_destroy(s->vgid_to_metadata);
 	dm_hash_destroy(s->vgid_to_vgname);
@@ -2111,6 +2126,8 @@ static response pv_found(lvmetad_state *s, request r)
 				DEBUGLOG(s, "pv_found ignore duplicate device %" PRIu64 " of existing PV for pvid %s",
 				         arg_device, arg_pvid);
 				dm_config_destroy(new_pvmeta);
+				/* device_to_pvid no longer references prev_pvid_lookup */
+				dm_free((void*)prev_pvid_on_dev);
 				s->flags |= GLFL_DISABLE;
 				s->flags |= GLFL_DISABLE_REASON_DUPLICATES;
 				return reply_fail("Ignore duplicate PV");


