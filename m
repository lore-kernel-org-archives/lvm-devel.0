From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  3 Nov 2015 19:43:30 +0000 (UTC)
Subject: master - vg_read: skip repair and wipe for foreign and shared VGs
Message-ID: <20151103194330.C0FCE6051E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=16780f6faa4fc24613720acc893f9f14955a6053
Commit:        16780f6faa4fc24613720acc893f9f14955a6053
Parent:        4103896ca02045d1ac13c788031a27e316b0c47a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 28 16:06:15 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 3 13:42:21 2015 -0600

vg_read: skip repair and wipe for foreign and shared VGs

When reading a foreign VG we cannot write it, since
it belongs to another host.  When reading a shared VG
we cannot write it because we may not have an ex lock.
(Or we may be reading the shared VG while not using
lvmlockd in which case it's like reading a foreign VG.)

Add the same checks for wiping outdated PVs.  We may
read a foreign or shared VG, or see the PVs, while
another host is part way through writing a new version
of the VG to the PVs.  This might cause us to think
some of the PVs are outdated.  We do not want to
write another host's PVs, especially when we may
wrongly conclude they are outdated.
---
 lib/metadata/metadata.c |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 1db8f58..fa166e4 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3428,6 +3428,18 @@ static int _repair_inconsistent_vg(struct volume_group *vg)
 {
 	unsigned saved_handles_missing_pvs = vg->cmd->handles_missing_pvs;
 
+	/* Cannot write foreign VGs, the owner will repair it. */
+	if (vg->cmd->system_id && strcmp(vg->system_id, vg->cmd->system_id)) {
+		log_verbose("Skip metadata repair for foreign VG.");
+		return 0;
+	}
+
+	/* FIXME: do this at higher level where lvmlockd lock can be changed. */
+	if (is_lockd_type(vg->lock_type)) {
+		log_verbose("Skip metadata repair for shared VG.");
+		return 0;
+	}
+
 	vg->cmd->handles_missing_pvs = 1;
 	if (!vg_write(vg)) {
 		log_error("Automatic metadata correction failed");
@@ -3457,6 +3469,30 @@ static int _wipe_outdated_pvs(struct cmd_context *cmd, struct volume_group *vg,
 {
 	struct pv_list *pvl, *pvl2;
 	char uuid[64] __attribute__((aligned(8)));
+
+	/*
+	 * Cannot write foreign VGs, the owner will repair it.
+	 * Also, if another host is updating its VG, we may read
+	 * the PVs while some are written but not others, making
+	 * some PVs look outdated to us just because we're reading
+	 * the VG while it's only partially written out.
+	 */
+	if (cmd->system_id && strcmp(vg->system_id, cmd->system_id)) {
+		log_verbose("Skip wiping outdated PVs for foreign VG.");
+		return 0;
+	}
+
+	/*
+	 * FIXME: do this at higher level where lvmlockd lock can be changed.
+	 * Also if we're reading the VG with the --shared option (not using
+	 * lvmlockd), we can see a VG while it's being written by another
+	 * host, same as the foreign VG case.
+	 */
+	if (is_lockd_type(vg->lock_type)) {
+		log_verbose("Skip wiping outdated PVs for shared VG.");
+		return 0;
+	}
+
 	dm_list_iterate_items(pvl, to_check) {
 		dm_list_iterate_items(pvl2, &vg->pvs) {
 			if (pvl->pv->dev == pvl2->pv->dev)


