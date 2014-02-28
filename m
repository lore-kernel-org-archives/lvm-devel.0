From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 23:58:16 +0000 (UTC)
Subject: master - lvmetad: Fix an invalid memory read that could cause a deadlock.
Message-ID: <20140228235816.6401F612AF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c8e868f6e077e733b56514fb34301e11f4a8300a
Commit:        c8e868f6e077e733b56514fb34301e11f4a8300a
Parent:        301ac8a07cb1c043cea61eb58ea2bae42a2cbcc2
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Sat Mar 1 00:42:09 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Sat Mar 1 00:42:09 2014 +0100

lvmetad: Fix an invalid memory read that could cause a deadlock.

---
 daemons/lvmetad/lvmetad-core.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index db05dc2..1792fc0 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -958,9 +958,13 @@ static response pv_found(lvmetad_state *s, request r)
 	}
 
 	if (vgid_old && (!vgid || strcmp(vgid, vgid_old))) {
+		/* make a copy, because vg_remove_if_missing will deallocate the
+		 * storage behind vgid_old */
+		vgid_old = dm_strdup(vgid_old);
 		lock_vg(s, vgid_old);
 		vg_remove_if_missing(s, vgid_old, 1);
 		unlock_vg(s, vgid_old);
+		dm_free(vgid_old);
 	}
 
 	return daemon_reply_simple("OK",


