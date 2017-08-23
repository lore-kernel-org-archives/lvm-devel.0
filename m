From: David Teigland <teigland@sourceware.org>
Date: Wed, 23 Aug 2017 12:32:25 -0400
Subject: master - lvmlockd: add comment about temp ls name
Message-ID: <201708231632.v7NGWPLu013045@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=46ddd5520cd4d5415ee936b6cbdb6e1936bc7d26
Commit:        46ddd5520cd4d5415ee936b6cbdb6e1936bc7d26
Parent:        539a48a328a7ddd1030dd5809a2f9f0df6c1fe70
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 23 11:25:18 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 23 11:25:18 2017 -0500

lvmlockd: add comment about temp ls name

---
 daemons/lvmlockd/lvmlockd-core.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 6fd4b88..da17b71 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -2652,8 +2652,14 @@ out_act:
 	ls->drop_vg = drop_vg;
 	if (ls->lm_type == LD_LM_DLM && !strcmp(ls->name, gl_lsname_dlm))
 		global_dlm_lockspace_exists = 0;
-	/* Avoid a name collision of the same lockspace is added again before this thread is cleaned up. */
-	/* FIXME: detect loss of 4 chars? (use 'size(tmp_name) == (MAX_NAME - 4)' and fail??) */
+
+	/*
+	 * Avoid a name collision of the same lockspace is added again before
+	 * this thread is cleaned up.  We just set ls->name to a "junk" value
+	 * for the short period until the struct is freed.  We could make it
+	 * blank or fill it with garbage, but instead set it to REM:<name>
+	 * to make it easier to follow progress of freeing is via log_debug.
+	 */
 	dm_strncpy(tmp_name, ls->name, sizeof(tmp_name));
 	snprintf(ls->name, sizeof(ls->name), "REM:%s", tmp_name);
 	pthread_mutex_unlock(&lockspaces_mutex);


