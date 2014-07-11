From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 11 Jul 2014 10:27:07 +0000 (UTC)
Subject: master - metadata: fix ALLOCATABLE_PV for lvm1 format
Message-ID: <20140711102707.7C4A0615AD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5c3d8940136f39a017ab434651789647161350b1
Commit:        5c3d8940136f39a017ab434651789647161350b1
Parent:        fd5912762b4815deb7a58fc4c5971801888e0ed3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jul 11 12:24:15 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 11 12:24:15 2014 +0200

metadata: fix ALLOCATABLE_PV for lvm1 format

This is addendum for commit 6dc7b783c80c6834aa724df49b5d47b9b5601506.

LVM1 format stores the ALLOCATABLE flag directly in PV header, not
in VG metadata. So the code needs to be fixed further to work
properly for lvm1 format so that the correct PV header is written
(the flag is set only if the PV is in some VG, unset otherwise).
---
 lib/format1/format1.c   |    6 +++++-
 lib/metadata/metadata.c |    2 +-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 16746e3..8ee2f48 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -381,6 +381,7 @@ static int _format1_pv_setup(const struct format_type *fmt,
 			     struct physical_volume *pv,
 			     struct volume_group *vg)
 {
+	int r;
 	struct pvcreate_restorable_params rp = {.restorefile = NULL,
 						.id = {{0}},
 						.idp = NULL,
@@ -390,7 +391,10 @@ static int _format1_pv_setup(const struct format_type *fmt,
 						.extent_count = 0,
 						.extent_size = vg->extent_size};
 
-	return _format1_pv_initialise(fmt, -1, 0, 0, &rp, pv);
+	if ((r = _format1_pv_initialise(fmt, -1, 0, 0, &rp, pv)))
+		pv->status |= ALLOCATABLE_PV;
+
+	return r;
 }
 
 static int _format1_lv_setup(struct format_instance *fid, struct logical_volume *lv)
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2d69714..0832750 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -602,7 +602,7 @@ int vg_remove(struct volume_group *vg)
 		log_verbose("Removing physical volume \"%s\" from "
 			    "volume group \"%s\"", pv_dev_name(pv), vg->name);
 		pv->vg_name = vg->fid->fmt->orphan_vg_name;
-		pv->status = ALLOCATABLE_PV;
+		pv->status &= ~ALLOCATABLE_PV;
 
 		if (!dev_get_size(pv_dev(pv), &pv->size)) {
 			log_error("%s: Couldn't get size.", pv_dev_name(pv));


