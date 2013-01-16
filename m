From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 16 Jan 2013 10:21:22 +0000 (UTC)
Subject: master - lvmetad: Fix a race in metadata update.
Message-ID: <20130116102122.4F20BAAC68@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=15fdd5c90dda7f00f691668c13d5401206d22021
Commit:        15fdd5c90dda7f00f691668c13d5401206d22021
Parent:        6fc596ca90640817fd555942bd5b5d3b7404a177
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Jan 16 11:09:37 2013 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jan 16 11:19:33 2013 +0100

lvmetad: Fix a race in metadata update.

The idea is to avoid a period when an existing VG is not mapped to either the
old or the new name. (Note that the brief "blackout" was present even if the
name did not actually change.) We instead allow a brief overlap of a VG existing
under both names, i.e. a query for a VG might succeed but before a lock is
acquired the VG disappears.
---
 daemons/lvmetad/lvmetad-core.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index cbd6b09..a789bad 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -454,7 +454,8 @@ static response vg_lookup(lvmetad_state *s, request r)
 
 	DEBUGLOG(s, "vg_lookup: updated uuid = %s, name = %s", uuid, name);
 
-	if (!uuid)
+	/* Check the name here. */
+	if (!uuid || !name)
 		return reply_unknown("VG not found");
 
 	cft = lock_vg(s, uuid);
@@ -682,16 +683,14 @@ static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid
 
 	lock_vgid_to_metadata(s);
 	old = dm_hash_lookup(s->vgid_to_metadata, _vgid);
+	oldname = dm_hash_lookup(s->vgid_to_vgname, _vgid);
 	unlock_vgid_to_metadata(s);
 	lock_vg(s, _vgid);
 
 	seq = dm_config_find_int(metadata, "metadata/seqno", -1);
 
-	if (old) {
+	if (old)
 		haveseq = dm_config_find_int(old->root, "metadata/seqno", -1);
-		oldname = dm_hash_lookup(s->vgid_to_vgname, _vgid);
-		assert(oldname);
-	}
 
 	if (seq < 0)
 		goto out;
@@ -743,7 +742,7 @@ static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid
 	if (haveseq >= 0 && haveseq < seq) {
 		INFO(s, "Updating metadata for %s@%d to %d", _vgid, haveseq, seq);
 		/* temporarily orphan all of our PVs */
-		remove_metadata(s, vgid, 1);
+		update_pvid_to_vgid(s, old, "#orphan", 0);
 	}
 
 	lock_vgid_to_metadata(s);
@@ -753,14 +752,17 @@ static int update_metadata(lvmetad_state *s, const char *name, const char *_vgid
 		  dm_hash_insert(s->vgid_to_metadata, vgid, cft) &&
 		  dm_hash_insert(s->vgid_to_vgname, vgid, cfgname) &&
 		  dm_hash_insert(s->vgname_to_vgid, name, (void*) vgid)) ? 1 : 0;
+
+	if (retval && oldname && strcmp(name, oldname))
+		dm_hash_remove(s->vgname_to_vgid, oldname);
+
 	unlock_vgid_to_metadata(s);
 
 	if (retval)
-		/* FIXME: What should happen when update fails */
 		retval = update_pvid_to_vgid(s, cft, vgid, 1);
 
 	unlock_pvid_to_vgid(s);
-out:
+out: /* FIXME: We should probably abort() on partial failures. */
 	if (!retval && cft)
 		dm_config_destroy(cft);
 	unlock_vg(s, _vgid);


