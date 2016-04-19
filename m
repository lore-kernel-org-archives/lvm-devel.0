From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 19 Apr 2016 14:37:03 +0000 (UTC)
Subject: master - metadata: don't repair shared VGs
Message-ID: <20160419143703.40D7361BD4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a6a32a7c0e6ed9ef9e61e82b2d1353a1c06a9dd3
Commit:        a6a32a7c0e6ed9ef9e61e82b2d1353a1c06a9dd3
Parent:        a400eba1740c335ed715c67b978dd0ed8228d73a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 14 16:40:26 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 19 09:19:32 2016 -0500

metadata: don't repair shared VGs

When the in-use flag looks like it needs to be repaired.
---
 lib/metadata/metadata.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ecdb5af..782235e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4037,6 +4037,14 @@ static int _check_or_repair_pv_ext(struct cmd_context *cmd,
 					    "VG %s but not marked as used.",
 					    pv_dev_name(pvl->pv), vg->name);
 				*inconsistent_pvs = 1;
+			} else if (is_lockd_type(vg->lock_type)) {
+				/*
+				 * FIXME: decide how to handle repair for shared VGs.
+				 */
+				log_warn("Skip repair of PV %s that is in shared "
+					    "VG %s but not marked as used.",
+					    pv_dev_name(pvl->pv), vg->name);
+				*inconsistent_pvs = 1;
 			} else {
 				log_warn("WARNING: Repairing Physical Volume %s that is "
 					 "in Volume Group %s but not marked as used.",


