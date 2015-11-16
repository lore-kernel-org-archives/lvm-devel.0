From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 16 Nov 2015 21:14:15 +0000 (UTC)
Subject: master - lvmetad: remove unneeded FIXME
Message-ID: <20151116211415.25E4760DE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a984cabc475160cf54274f0c822259a67bd8d1f
Commit:        4a984cabc475160cf54274f0c822259a67bd8d1f
Parent:        920a28199411445f6489912efd5b8bfca00dc588
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 16 13:44:57 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 16 13:44:57 2015 -0600

lvmetad: remove unneeded FIXME

This case is now handled correctly.
---
 daemons/lvmetad/lvmetad-core.c |   22 +++++-----------------
 1 files changed, 5 insertions(+), 17 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 0fddd7c..08c4632 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1542,23 +1542,11 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 		}
 
 		if (strcmp(arg_vgid_lookup, arg_vgid)) {
-			/*
-			 * This shouldn't usually happen, but could when
-			 * disks are moved (or filters are changed?)
-			 *
-			 * FIXME: two different VGs with different uuids, on
-			 * different PVs could have the same name, e.g. disks
-			 * are moved, filters are changed.  Possible solution:
-			 * purge all info for these VGs and return an error
-			 * that causes the command to go to disk.  Would this
-			 * only happen from pv_found?
-			 * Until there's a proper solution, ignore this VG.
-			 */
-			ERROR(s, "update_metadata ignore VG with duplicate name %s vgid %s pvid %s existing vgid %s",
-			      arg_name, arg_vgid, pvid ?: "none", arg_vgid_lookup);
-			unlock_vgid_to_metadata(s);
-			retval = 0;
-			goto out;
+			/* This shouldn't happen.  Two VGs with the same name is handled above. */
+			ERROR(s, "update_metadata arg_vgid %s arg_name %s mismatch arg_vgid_lookup %s",
+			      arg_vgid, arg_name, arg_vgid_lookup);
+			needs_repair = 1;
+			goto update;
 		}
 
 		/* old_vgid == arg_vgid, and old_name == arg_name */


