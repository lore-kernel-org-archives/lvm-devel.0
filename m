From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 20 May 2015 17:48:03 +0000 (UTC)
Subject: master - lvmetad: Clear the vgid_to_outdated_pvs hash on shutdown.
Message-ID: <20150520174803.5DCE560188@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=da1527d65dbe474fe4c9e620ad028a9a09213ac8
Commit:        da1527d65dbe474fe4c9e620ad028a9a09213ac8
Parent:        925268794f4c97091674d99d98e3d73349a75502
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Apr 15 16:38:57 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed May 20 19:46:13 2015 +0200

lvmetad: Clear the vgid_to_outdated_pvs hash on shutdown.

---
 daemons/lvmetad/lvmetad-core.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 7e30add..d14bac2 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -61,6 +61,9 @@ static void destroy_metadata_hashes(lvmetad_state *s)
 	dm_hash_iterate(n, s->vgid_to_metadata)
 		dm_config_destroy(dm_hash_get_data(s->vgid_to_metadata, n));
 
+	dm_hash_iterate(n, s->vgid_to_outdated_pvs)
+		dm_config_destroy(dm_hash_get_data(s->vgid_to_outdated_pvs, n));
+
 	dm_hash_iterate(n, s->pvid_to_pvmeta)
 		dm_config_destroy(dm_hash_get_data(s->pvid_to_pvmeta, n));
 


