From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 10 Jul 2015 20:54:31 +0000 (UTC)
Subject: master - lockd: note that external origins don't work in lockd VGs
Message-ID: <20150710205431.B3CCF60139@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=222bb2b88d06a67cc25ed19332919fa339d7e831
Commit:        222bb2b88d06a67cc25ed19332919fa339d7e831
Parent:        b8538f5dcd2e1c0880607a2bbd067d6aa60e689a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 10 13:27:02 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 10 15:53:21 2015 -0500

lockd: note that external origins don't work in lockd VGs

in a comment at the point where it fails, and in the
lvmlockd man page.
---
 man/lvmlockd.8.in |    2 ++
 tools/lvconvert.c |   10 ++++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/man/lvmlockd.8.in b/man/lvmlockd.8.in
index c3b0ac0..659fead 100644
--- a/man/lvmlockd.8.in
+++ b/man/lvmlockd.8.in
@@ -686,6 +686,8 @@ Things that do not yet work in lockd VGs:
 .br
 - using lvcreate to create cache pools or cache LVs (use lvconvert)
 .br
+- using external origins for thin LVs
+.br
 - splitting mirrors and snapshots from LVs
 .br
 - vgsplit
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c543a1e..1461f4a 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2533,6 +2533,16 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 	}
 
 	if (is_lockd_type(lv->vg->lock_type)) {
+		/*
+		 * FIXME: external origins don't work in lockd VGs.
+		 * Prior to the lvconvert, there's a lock associated with
+		 * the uuid of the external origin LV.  After the convert,
+		 * that uuid belongs to the new thin LV, and a new LV with
+		 * a new uuid exists as the non-thin, readonly external LV.
+		 * We'd need to remove the lock for the previous uuid
+		 * (the new thin LV will have no lock), and create a new
+		 * lock for the new LV uuid used by the external LV.
+		 */
 		log_error("Can't use lock_type %s LV as external origin.",
 			  lv->vg->lock_type);
 		return 0;


