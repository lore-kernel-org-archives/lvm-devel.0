From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  5 Jan 2013 03:21:52 +0000 (UTC)
Subject: master - lvmetad: fix format1 updates
Message-ID: <20130105032152.A2DB033A8@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b617109fff859a5b970554b38852fc61deb29f77
Commit:        b617109fff859a5b970554b38852fc61deb29f77
Parent:        48e1ae7f6a48469be7bff795fde6ba978354ca7d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jan 5 03:07:43 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jan 5 03:17:35 2013 +0000

lvmetad: fix format1 updates

fmt1 doesn't have a separate commit function: updates take effect
immediately vg_write is called, so we must update lvmetad at this
point if we're going to go on and ask lvmetad for the VG metadata
again before calling the commit function (though that's probably an
unsupported and pointless thing to do anyway as the client must
already have that data and it cannot have changed because it's locked
and with devs suspended we shouldn't be communicating with lvmetad;
so when that's fixed properly, this fix here can be reverted).

This problem showed up as an internal error when lvremoving an LVM1
snapshot.

> Internal error: LV snap1 (00000000000000000000000000000001) missing from preload metadata

https://bugzilla.redhat.com/891855
---
 lib/cache/lvmetad.h     |    1 +
 lib/metadata/metadata.c |   15 +++++++++++----
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index e985387..ff4cd0a 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -72,6 +72,7 @@ void lvmetad_set_token(const struct dm_config_value *filter);
  */
 void lvmetad_release_token(void);
 
+// FIXME What's described here doesn't appear to be implemented yet.
 /*
  * Send a new version of VG metadata to lvmetad. This is normally called after
  * vg_write but before vg_commit. After vg_commit, lvmetad_vg_commit is called
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 807d06a..a472b18 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2659,6 +2659,13 @@ int vg_write(struct volume_group *vg)
 		}
 	}
 
+	/*
+	 * If precommit is not supported, changes take effect immediately.
+	 * FIXME Replace with a more-accurate FMT_COMMIT flag.
+	 */
+	if (!(vg->fid->fmt->features & FMT_PRECOMMIT) && !lvmetad_vg_update(vg))
+		return_0;
+
 	return 1;
 }
 
@@ -2707,8 +2714,9 @@ int vg_commit(struct volume_group *vg)
 		return cache_updated;
 	}
 
-	if (!lvmetad_vg_update(vg))
-		return 0;
+	/* Skip if we already did this in vg_write */
+	if ((vg->fid->fmt->features & FMT_PRECOMMIT) && !lvmetad_vg_update(vg))
+		return_0;
 
 	cache_updated = _vg_commit_mdas(vg);
 
@@ -3511,7 +3519,7 @@ struct logical_volume *lv_from_lvid(struct cmd_context *cmd, const char *lvid_s,
 
 	lvid = (const union lvid *) lvid_s;
 
-	log_very_verbose("Finding volume group for uuid %s", lvid_s);
+	log_very_verbose("Finding %svolume group for uuid %s", precommitted ? "precommitted " : "", lvid_s);
 	if (!(vg = _vg_read_by_vgid(cmd, (const char *)lvid->id[0].uuid, precommitted))) {
 		log_error("Volume group for uuid not found: %s", lvid_s);
 		return NULL;
@@ -3533,7 +3541,6 @@ out:
 	return NULL;
 }
 
-
 const char *find_vgname_from_pvid(struct cmd_context *cmd,
 				  const char *pvid)
 {


