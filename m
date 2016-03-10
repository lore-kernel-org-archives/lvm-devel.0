From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 10 Mar 2016 19:37:57 +0000 (UTC)
Subject: master - pvchange, pvresize: move exported VG check
Message-ID: <20160310193757.C1E1560F96@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0f10823ec910c0a6015b20580f5aa26f209cea04
Commit:        0f10823ec910c0a6015b20580f5aa26f209cea04
Parent:        9f4451193b8db4bd9c894248f50da9319704293e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 10 13:28:47 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 10 13:37:42 2016 -0600

pvchange, pvresize: move exported VG check

Allow pvchange and pvresize to process exported VGs,
and have them check for the exported state in their
single function.

Previously, the exported VG state would trigger a
failure in vg_read()/ignore_vg() because the VGs are
being read with READ_FOR_UPDATE.  Because these commands
read all VGs to search for the intended PVs, any
exported VG would trigger a failure, even if it was
not related to the intended PV.
---
 tools/pvchange.c |    7 ++++++-
 tools/pvresize.c |    8 ++++++--
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/tools/pvchange.c b/tools/pvchange.c
index 5f99016..e103ebe 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -35,6 +35,11 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 
 	params->total++;
 
+	if (vg && vg_is_exported(vg)) {
+		log_error("Volume group %s is exported", vg->name);
+		goto bad;
+	}
+
 	/* If in a VG, must change using volume group. */
 	if (!is_orphan(pv)) {
 		if (tagargs && !(vg->fid->fmt->features & FMT_TAGS)) {
@@ -230,7 +235,7 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 
 	set_pv_notify(cmd);
 
-	ret = process_each_pv(cmd, argc, argv, NULL, 0, READ_FOR_UPDATE, handle, _pvchange_single);
+	ret = process_each_pv(cmd, argc, argv, NULL, 0, READ_FOR_UPDATE | READ_ALLOW_EXPORTED, handle, _pvchange_single);
 
 	if (!argc)
 		unlock_vg(cmd, VG_GLOBAL);
diff --git a/tools/pvresize.c b/tools/pvresize.c
index 1312290..9931cc6 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -36,6 +36,11 @@ static int _pvresize_single(struct cmd_context *cmd,
 	}
 	params->total++;
 
+	if (vg && vg_is_exported(vg)) {
+		log_error("Volume group %s is exported", vg->name);
+		return ECMD_FAILED;
+	}
+
 	/*
 	 * Needed to change a property on an orphan PV.
 	 * i.e. the global lock is only needed for orphans.
@@ -89,8 +94,7 @@ int pvresize(struct cmd_context *cmd, int argc, char **argv)
 
 	handle->custom_handle = &params;
 
-	ret = process_each_pv(cmd, argc, argv, NULL, 0, READ_FOR_UPDATE, handle,
-			      _pvresize_single);
+	ret = process_each_pv(cmd, argc, argv, NULL, 0, READ_FOR_UPDATE | READ_ALLOW_EXPORTED, handle, _pvresize_single);
 
 	log_print_unless_silent("%d physical volume(s) resized / %d physical volume(s) "
 				"not resized", params.done, params.total - params.done);


