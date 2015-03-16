From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 16 Mar 2015 16:06:06 +0000 (UTC)
Subject: master - lvmetad: pvscan: do not scan and read ignored MDAs from PVs
Message-ID: <20150316160606.A98FD61128@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=038013cf42710da3e815713c7e7482fca00e110b
Commit:        038013cf42710da3e815713c7e7482fca00e110b
Parent:        ff5217f85079fa8cc969e0a81a66f1e1bd6490b5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 16 17:00:36 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Mar 16 17:00:36 2015 +0100

lvmetad: pvscan: do not scan and read ignored MDAs from PVs

Metadata areas which are marked as ignored should not be scanned
and read during pvscan --cache. Otherwise, this can cause lvmetad
to cache out-of-date metadata in case other PVs with fresh metadata
are missing by chance.

Make this to work like in non-lvmetad case where the behaviour would
be the same as if the PV was orphan (in case we have no other PVs
with valid non-ignored metadata areas).
---
 WHATS_NEW                          |    1 +
 lib/cache/lvmetad.c                |    4 +++-
 test/shell/lvmetad-pvscan-cache.sh |   13 +++++++++++++
 3 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 97b562d..d0a0c2d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.118 - 
 =================================
+  Fix pvscan --cache to not scan and read ignored metadata areas on PVs.
   Add After=iscsi-shutdown.service to blk-availability.service systemd unit.
   Disallow vgconvert from changing metadata format when lvmetad is used.
   Don't do a full read of VG when creating a new VG with an existing name.
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 08c58d2..d878c17 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -895,7 +895,9 @@ struct _lvmetad_pvscan_baton {
 static int _lvmetad_pvscan_single(struct metadata_area *mda, void *baton)
 {
 	struct _lvmetad_pvscan_baton *b = baton;
-	struct volume_group *this = mda->ops->vg_read(b->fid, "", mda, 1);
+	struct volume_group *this;
+
+	this = mda_is_ignored(mda) ? NULL : mda->ops->vg_read(b->fid, "", mda, 1);
 
 	/* FIXME Also ensure contents match etc. */
 	if (!b->vg || this->seqno > b->vg->seqno)
diff --git a/test/shell/lvmetad-pvscan-cache.sh b/test/shell/lvmetad-pvscan-cache.sh
index 5c48817..75890a5 100644
--- a/test/shell/lvmetad-pvscan-cache.sh
+++ b/test/shell/lvmetad-pvscan-cache.sh
@@ -22,4 +22,17 @@ pvscan --cache
 
 vgs | grep $vg1
 
+# When MDA is ignored on PV, do not read any VG
+# metadata from such PV as it may contain old
+# metadata which hasn't been updated for some
+# time and also since the MDA is marked as ignored,
+# it should really be *ignored*!
+pvchange --metadataignore y "$dev1"
+aux disable_dev "$dev2"
+pvscan --cache
+check pv_field "$dev1" vg_name ""
+aux enable_dev "$dev2"
+pvscan --cache
+check pv_field "$dev1" vg_name "$vg1"
+
 vgremove -ff $vg1


