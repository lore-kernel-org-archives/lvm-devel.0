From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 14 Sep 2015 18:22:31 +0000 (UTC)
Subject: master - vgcreate: initialize new PVs only in first vg_write
Message-ID: <20150914182231.AD9CB61190@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2ce8ee0214c84a4afd12589bbe2fe521c2518b87
Commit:        2ce8ee0214c84a4afd12589bbe2fe521c2518b87
Parent:        cee9ed22441187a2a3a6290d1e07428df0171144
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 11 16:12:03 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 14 13:22:22 2015 -0500

vgcreate: initialize new PVs only in first vg_write

When a command does a sequence of
vg_write + vg_commit + vg_write + vg_commit,

initialization of non-PV devices happens during the
first vg_write, and does not need to be repeated by
the second vg_write.

When creating a lockd VG, this sequence occurs because
the VG is first created, then the lockd data is created,
then the lockd data is then written to the VG metadata.
---
 lib/metadata/metadata.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b45f850..9bd42c9 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3011,7 +3011,7 @@ out:
 int vg_write(struct volume_group *vg)
 {
 	struct dm_list *mdah;
-        struct pv_to_create *pv_to_create;
+	struct pv_to_create *pv_to_create, *pv_to_create_safe;
 	struct metadata_area *mda;
 	struct lv_list *lvl;
 	int revert = 0, wrote = 0;
@@ -3067,10 +3067,11 @@ int vg_write(struct volume_group *vg)
 	memlock_unlock(vg->cmd);
 	vg->seqno++;
 
-        dm_list_iterate_items(pv_to_create, &vg->pvs_to_create) {
+	dm_list_iterate_items_safe(pv_to_create, pv_to_create_safe, &vg->pvs_to_create) {
 		if (!_pvcreate_write(vg->cmd, pv_to_create))
 			return 0;
-        }
+		dm_list_del(&pv_to_create->list);
+	}
 
 	/* Write to each copy of the metadata area */
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {


