From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 16 Aug 2019 12:07:22 -0400
Subject: master - dmeventd: avoid bail out preventing repair in raid plugin
Message-ID: <201908161607.x7GG7Mpx002042@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ad560a286a0b5d08086324e6194b060c136e9353
Commit:        ad560a286a0b5d08086324e6194b060c136e9353
Parent:        125f27ac37bc9b93cc96f64052b9681b3d479ee1
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Aug 16 16:25:08 2019 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Aug 16 18:07:03 2019 +0200

dmeventd: avoid bail out preventing repair in raid plugin

Problem:
even though dead raid component devices are detected, the
raid plugin is bailing out thus preventing a repair attempt.

Rational:
in case of component device errors, the MD resynchronization
thread runs in parallel with the thrown event being processed
by the raid plugin.  The plugin retrieves the raid device status
but that still reflects insync regions as 0 (when it should
already be total regions) because the MD thread didn't update it yet.

Solution:
Remove the insync regions check and let lvconvert carry out its
pre-repair checks and optionally carry out a repair attempt.

Resolves: https://bugzilla.redhat.com/show_bug.cgi?id=1560739
Related:  https://bugzilla.redhat.com/show_bug.cgi?id=1468590
Related:  https://bugzilla.redhat.com/show_bug.cgi?id=1654860
Related:  https://bugzilla.redhat.com/show_bug.cgi?id=1729303
Related:  https://bugzilla.redhat.com/show_bug.cgi?id=1741016
---
 daemons/dmeventd/plugins/raid/dmeventd_raid.c |   16 ++++++----------
 1 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index aa2b578..3431f1e 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -76,16 +76,12 @@ static int _process_raid_event(struct dso_state *state, char *params, const char
 	}
 
 	if (dead) {
-		if (status->insync_regions < status->total_regions) {
-			if (!state->warned) {
-				state->warned = 1;
-				log_warn("WARNING: waiting for resynchronization to finish "
-					 "before initiating repair on RAID device %s.", device);
-			}
-
-			goto out; /* Not yet done syncing with accessible devices */
-		}
-
+		/*
+		 * Use the first event to run a repair ignoring any additonal ones.
+		 *
+		 * We presume lvconvert to do pre-repair
+		 * checks to avoid bloat in this plugin.
+		 */
 		if (state->failed)
 			goto out; /* already reported */
 


