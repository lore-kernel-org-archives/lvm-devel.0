From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  4 Dec 2012 09:38:59 +0000 (UTC)
Subject: master - Allow empty activation/{auto_activation|read_only|}_volume_list config option.
Message-ID: <20121204093900.17014137D@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e2be2652ad147f07f326da0744b32f5160d68340
Commit:        e2be2652ad147f07f326da0744b32f5160d68340
Parent:        a530c70b21e2ba93589e862b979aa3cb068d579a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Dec 4 10:33:54 2012 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Dec 4 10:33:54 2012 +0100

Allow empty activation/{auto_activation|read_only|}_volume_list config option.

In case we don't want to activate, autoactivate or have the
VG/LV read-only. Primarily targeted for the auto_activation_volume_list,
but it makes no harm for other settings (the part of the code
that reads these three settings is shared, but there's no
reason to separate it only for this change).
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cff005d..519d4dd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Allow empty activation/{auto_activation|read_only|}_volume_list config option.
   Add lvm.conf option global/thin_disabled_features.
   Add lvconvert support to swap thin pool metadata volume.
   Implement internal function detach_pool_metadata_lv().
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 185ba5f..ee552b4 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -340,6 +340,8 @@ static int _lv_passes_volumes_filter(struct cmd_context *cmd, struct logical_vol
 		    config_path, lv->vg->name, lv->name);
 
 	for (cv = cn->v; cv; cv = cv->next) {
+		if (cv->type == DM_CFG_EMPTY_ARRAY)
+			return 0;
 		if (cv->type != DM_CFG_STRING) {
 			log_error("Ignoring invalid string in config file %s",
 				  config_path);


