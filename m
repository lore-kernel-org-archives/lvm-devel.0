From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 20 Sep 2019 11:55:39 -0400
Subject: master - dmeventd: avoid bail out preventing repair in raid plugin but keep message
Message-ID: <201909201555.x8KFtdfM022806@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6f355c673631b0d7959191c8a56a577b3a0e97c9
Commit:        6f355c673631b0d7959191c8a56a577b3a0e97c9
Parent:        6fc46af8ecd9532aca41df43fd588fb207ed4e92
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Sep 20 17:35:35 2019 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Sep 20 17:53:20 2019 +0200

dmeventd: avoid bail out preventing repair in raid plugin but keep message

Followup patch mentioned in previous commit fe577f84cbf6bd7be76b457c9d54d0e54e57f93d.

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
  Remove the insync regions check but keep the informal message
  "waiting for resynchronization"  and let lvconvert carry out its
  pre-repair checks and optionally carry out a repair attempt.

Related: https://bugzilla.redhat.com/show_bug.cgi?id=1751887
Related: https://bugzilla.redhat.com/show_bug.cgi?id=1560739
Related: https://bugzilla.redhat.com/show_bug.cgi?id=1468590
Related: https://bugzilla.redhat.com/show_bug.cgi?id=1654860
Related: https://bugzilla.redhat.com/show_bug.cgi?id=1729303
Related: https://bugzilla.redhat.com/show_bug.cgi?id=1741016
---
 daemons/dmeventd/plugins/raid/dmeventd_raid.c |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index aa2b578..525b721 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -76,14 +76,17 @@ static int _process_raid_event(struct dso_state *state, char *params, const char
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
+		/*
+		 * Use the first event to run a repair ignoring any additonal ones.
+		 *
+		 * We presume lvconvert to do pre-repair
+		 * checks to avoid bloat in this plugin.
+		 */
+		if (!state->warned && status->insync_regions < status->total_regions) {
+			state->warned = 1;
+			log_warn("WARNING: waiting for resynchronization to finish "
+				 "before initiating repair on RAID device %s.", device);
+			/* Fall through to allow lvconvert to run. */
 		}
 
 		if (state->failed)


