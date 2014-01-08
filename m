From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  8 Jan 2014 11:05:42 +0000 (UTC)
Subject: master - lvmetad: add parentheses around assignment
Message-ID: <20140108110542.82FE86119F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4417cd288b69479ade4f4ab98adfc4d5eb7f483b
Commit:        4417cd288b69479ade4f4ab98adfc4d5eb7f483b
Parent:        af7297c73eb824f30898ba7dbb4a4b23406625ca
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 8 11:54:28 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 8 11:57:43 2014 +0100

lvmetad: add parentheses around assignment

---
 daemons/lvmetad/lvmetad-core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 19e0b6b..0659c9d 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -882,7 +882,7 @@ static response pv_found(lvmetad_state *s, request r)
 		pvmeta_old_dev = dm_hash_lookup(s->pvid_to_pvmeta, old);
 		dm_hash_remove(s->pvid_to_pvmeta, old);
 
-		if (vgid_old = dm_hash_lookup(s->pvid_to_vgid, pvid)) {
+		if ((vgid_old = dm_hash_lookup(s->pvid_to_vgid, pvid))) {
 			lock_vg(s, vgid_old);
 			vg_remove_if_missing(s, vgid_old, 1);
 			unlock_vg(s, vgid_old);


