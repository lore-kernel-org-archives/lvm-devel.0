From: David Teigland <teigland@sourceware.org>
Date: Wed, 11 Dec 2019 13:58:22 -0500
Subject: master - drop warnings about missing pvs in foreign vgs
Message-ID: <06350.119121113581601011@us-mta-90.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2173bdb82177fc687474b72561742955cb292522
Commit:        2173bdb82177fc687474b72561742955cb292522
Parent:        2da6f01c1544a0b94bd06abc691fe0ac59268700
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Dec 11 12:56:15 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Dec 11 12:56:15 2019 -0600

drop warnings about missing pvs in foreign vgs

When a foreign VG is ignored, don't print warnings that
it is missing PVs.
---
 lib/metadata/metadata.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 246682c..9c44388 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3564,7 +3564,8 @@ static void _set_pv_device(struct format_instance *fid,
 		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
 			buffer[0] = '\0';
 
-		if (cmd && !cmd->pvscan_cache_single)
+		if (cmd && !cmd->pvscan_cache_single &&
+		    (!vg_is_foreign(vg) && !cmd->include_foreign_vgs))
 			log_warn("WARNING: Couldn't find device with uuid %s.", buffer);
 		else
 			log_debug_metadata("Couldn't find device with uuid %s.", buffer);
@@ -5079,7 +5080,9 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 		if (!pvl->pv->dev) {
 			/* The obvious and common case of a missing device. */
 
-			if (pvl->pv->device_hint)
+			if (vg_is_foreign(vg) && !cmd->include_foreign_vgs)
+				log_debug("VG %s is missing PV %s (last written to %s)", vg_name, uuidstr, pvl->pv->device_hint ?: "na");
+			else if (pvl->pv->device_hint)
 				log_warn("WARNING: VG %s is missing PV %s (last written to %s).", vg_name, uuidstr, pvl->pv->device_hint);
 			else
 				log_warn("WARNING: VG %s is missing PV %s.", vg_name, uuidstr);



