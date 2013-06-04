From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:27:19 +0000 (UTC)
Subject: dev-mornfall-activate - dmeventd: revert back percent to int
Message-ID: <20130604192719.2932F60DCA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=55f42944bd76ffdf3f77331c491e7de24ed56a2f
Commit:        55f42944bd76ffdf3f77331c491e7de24ed56a2f
Parent:        5e7cdd60f0043d54651a8441803daaea345897f1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 29 12:29:48 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 30 16:46:58 2013 +0200

dmeventd: revert back percent to int

int is perfectly ok here.
---
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index ac33ef3..98dd1b4 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -134,7 +134,7 @@ void process_event(struct dm_task *dmt,
 	char *params;
 	struct dm_status_snapshot *status = NULL;
 	const char *device = dm_task_get_name(dmt);
-	uint64_t percent;
+	int percent;
 	struct dso_state *state = *private;
 
 	/* No longer monitoring, waiting for remove */
@@ -175,7 +175,7 @@ void process_event(struct dm_task *dmt,
 		goto out;
 	}
 
-	percent = 100 * status->used_sectors / status->total_sectors;
+	percent = (int) (100 * status->used_sectors / status->total_sectors);
 	if (percent >= state->percent_check) {
 		/* Usage has raised more than CHECK_STEP since the last
 		   time. Run actions. */


