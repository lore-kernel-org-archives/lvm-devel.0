From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 16 Mar 2017 09:19:56 -0400
Subject: master - dmeventd: reintroduce fix mirror DSO to work with lvmetad
Message-ID: <201703161319.v2GDJugv020243@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e5b6f2685a462fbdd262685b39c2ac186475a051
Commit:        e5b6f2685a462fbdd262685b39c2ac186475a051
Parent:        a87715b6fdd4e95be425ef629c5247ecf1ef169e
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 16 14:19:06 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 16 14:19:06 2017 +0100

dmeventd: reintroduce fix mirror DSO to work with lvmetad

Commit 07ded8059cbd assumed that the mirror is blocked which is not the case.

It is accessible, degraded and in need of repair because some of its legs
(partially) failed.  Any auto-repair via dmeventd fails though because
of lvmetad not providing proper data about the failed PV(s).  That's why
this workaround got introduced in commit 76f6951c3e8f until we get to
the lvmetad interaction core issue.

Mind any mirror auto-repair failure is caused by such lvmetad interaction
problems not yet solved so disabling lvmetad works as a resort as elaborated
on in the related bz.

Reintroducing the interim solution.

Resolves: rhbz1380521
---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index e99b7a2..d3bd12a 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -188,7 +188,7 @@ int register_device(const char *device,
 
         /* CANNOT use --config as this disables cached content */
 	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvconvert, sizeof(state->cmd_lvconvert),
-				   "lvconvert --repair --use-policies", device))
+				   "lvconvert --config global{use_lvmetad = 0}' --repair --use-policies", device))
 		goto_bad;
 
 	*user = state;


