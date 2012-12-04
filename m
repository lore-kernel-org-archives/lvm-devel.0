From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  4 Dec 2012 13:14:34 +0000 (UTC)
Subject: master - activation: don't miss the log on empty {auto_activation|read_only|}_volume_list
Message-ID: <20121204131434.52D8F24A3@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=35a4d70aad02f297d81909ff7c65a032c5e0dbf2
Commit:        35a4d70aad02f297d81909ff7c65a032c5e0dbf2
Parent:        e2be2652ad147f07f326da0744b32f5160d68340
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Dec 4 14:10:03 2012 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Dec 4 14:12:36 2012 +0100

activation: don't miss the log on empty {auto_activation|read_only|}_volume_list

Addendum to previous commit...
---
 lib/activate/activate.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index ee552b4..899f409 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -341,7 +341,7 @@ static int _lv_passes_volumes_filter(struct cmd_context *cmd, struct logical_vol
 
 	for (cv = cn->v; cv; cv = cv->next) {
 		if (cv->type == DM_CFG_EMPTY_ARRAY)
-			return 0;
+			goto out;
 		if (cv->type != DM_CFG_STRING) {
 			log_error("Ignoring invalid string in config file %s",
 				  config_path);
@@ -397,6 +397,7 @@ static int _lv_passes_volumes_filter(struct cmd_context *cmd, struct logical_vol
 			return 1;
 	}
 
+out:
 	log_verbose("No item supplied in %s configuration setting "
 		    "matches %s/%s", config_path, lv->vg->name, lv->name);
 


