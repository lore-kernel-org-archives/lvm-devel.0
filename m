From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 20 Sep 2019 11:55:35 -0400
Subject: master - Revert "dmeventd: avoid bail out preventing repair in raid plugin"
Message-ID: <201909201555.x8KFtZ1w022791@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6fc46af8ecd9532aca41df43fd588fb207ed4e92
Commit:        6fc46af8ecd9532aca41df43fd588fb207ed4e92
Parent:        8d8b5e4f75694f62a9af9cda707509f0814d8c8a
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Sep 20 17:26:36 2019 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Sep 20 17:52:37 2019 +0200

Revert "dmeventd: avoid bail out preventing repair in raid plugin"

This reverts commit ad560a286a0b5d08086324e6194b060c136e9353.

The reverted patch also removed the warning which we realized we need
to keep as valuable process information (see related bugzilla below).

In a followup patch, we'll keep the message and avoid bailing out thus
always allowing lvconvert to try repairing if 'allocate' fault policy set.

Related: https://bugzilla.redhat.com/show_bug.cgi?id=1751887
---
 daemons/dmeventd/plugins/raid/dmeventd_raid.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index 3431f1e..aa2b578 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -76,12 +76,16 @@ static int _process_raid_event(struct dso_state *state, char *params, const char
 	}
 
 	if (dead) {
-		/*
-		 * Use the first event to run a repair ignoring any additonal ones.
-		 *
-		 * We presume lvconvert to do pre-repair
-		 * checks to avoid bloat in this plugin.
-		 */
+		if (status->insync_regions < status->total_regions) {
+			if (!state->warned) {
+				state->warned = 1;
+				log_warn("WARNING: waiting for resynchronization to finish "
+					 "before initiating repair on RAID device %s.", device);
+			}
+
+			goto out; /* Not yet done syncing with accessible devices */
+		}
+
 		if (state->failed)
 			goto out; /* already reported */
 


