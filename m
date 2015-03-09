From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  9 Mar 2015 18:57:27 +0000 (UTC)
Subject: master - metadata: Detect internal use of LVM_WRITE_LOCKED.
Message-ID: <20150309185727.77B71610C3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a8545462349c560cf66362cb3d25b44b7b0e819b
Commit:        a8545462349c560cf66362cb3d25b44b7b0e819b
Parent:        faccdeda83ee8c04546a2224fa2dee82a55413fe
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Mar 9 18:56:24 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Mar 9 18:56:24 2015 +0000

metadata: Detect internal use of LVM_WRITE_LOCKED.

Generate internal error if LVM_WRITE_LOCKED ever appears
in struct volume_group: it's only used in external
metadata.
---
 lib/metadata/metadata.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ab23d25..21066fb 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2495,6 +2495,12 @@ int vg_validate(struct volume_group *vg)
 		r = 0;
 	}
 
+	if (vg->status & LVM_WRITE_LOCKED) {
+		log_error(INTERNAL_ERROR "VG %s has external flag LVM_WRITE_LOCKED set internally.",
+			  vg->name);
+		r = 0;
+	}
+
 	/* FIXME Also check there's no data/metadata overlap */
 	if (!(vhash.pvid = dm_hash_create(vg->pv_count))) {
 		log_error("Failed to allocate pvid hash.");
@@ -2568,6 +2574,12 @@ int vg_validate(struct volume_group *vg)
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv_count++;
 
+		if (lvl->lv->status & LVM_WRITE_LOCKED) {
+			log_error(INTERNAL_ERROR "LV %s has external flag LVM_WRITE_LOCKED set internally.",
+				  vg->name);
+			r = 0;
+		}
+
 		dev_name_len = strlen(lvl->lv->name) + vg_name_len + 3;
 		if (dev_name_len >= NAME_LEN) {
 			log_error(INTERNAL_ERROR "LV name \"%s/%s\" length %"


