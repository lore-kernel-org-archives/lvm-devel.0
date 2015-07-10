From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 10 Jul 2015 20:54:27 +0000 (UTC)
Subject: master - lvconvert: disallow splitting in lockd VGs
Message-ID: <20150710205427.201C960139@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c4fdcb04be174dd3ec68eb0c3f17dd8a08314b59
Commit:        c4fdcb04be174dd3ec68eb0c3f17dd8a08314b59
Parent:        0823511262bd52bb14b150a180fcd23ea35fc8fb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 10 11:46:24 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 10 15:53:21 2015 -0500

lvconvert: disallow splitting in lockd VGs

A new lockd lock needs to be created for the new LV
created by split mirror and split snapshot.  Disallow
these options in lockd VGs until that is implemented.
---
 tools/lvconvert.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index b10798e..c543a1e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1130,6 +1130,12 @@ static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
 	*old_mimage_count = lv_mirror_count(lv);
 	*old_log_count = _get_log_count(lv);
 
+	if (is_lockd_type(lv->vg->lock_type) && arg_count(cmd, splitmirrors_ARG)) {
+		/* FIXME: we need to create a lock for the new LV. */
+		log_error("Unable to split mirrors in VG with lock_type %s", lv->vg->lock_type);
+		return 0;
+	}
+
 	/*
 	 * Collapsing a stack of mirrors:
 	 *
@@ -1838,6 +1844,12 @@ static int _lvconvert_splitsnapshot(struct cmd_context *cmd, struct logical_volu
 		return 0;
 	}
 
+	if (is_lockd_type(vg->lock_type)) {
+		/* FIXME: we need to create a lock for the new LV. */
+		log_error("Unable to split snapshots in VG with lock_type %s", vg->lock_type);
+		return 0;
+	}
+
 	if (!vg_check_status(vg, LVM_WRITE))
 		return_0;
 


