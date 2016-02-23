From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 23 Feb 2016 21:45:27 +0000 (UTC)
Subject: master - lvmlockd: fix sparse snapshot case
Message-ID: <20160223214527.D2AE1605A9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e79325308454814d968dd3e06cd261a269716675
Commit:        e79325308454814d968dd3e06cd261a269716675
Parent:        79809d6cdc3a1e4dfb4466fc0e10040bd069211d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 23 15:44:14 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 23 15:45:25 2016 -0600

lvmlockd: fix sparse snapshot case

A snapshot can be created without a real origin LV
in this case, so there's no lock to use.
---
 lib/locking/lvmlockd.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index e78e2cb..c55f2b5 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2331,6 +2331,12 @@ int lockd_init_lv(struct cmd_context *cmd, struct volume_group *vg, struct logic
 		 * represents itself and all associated cow snapshots.
 		 */
 
+		if (!lp->origin_name) {
+			/* Sparse LV case. We require a lock from the origin LV. */
+			log_error("Cannot create snapshot without origin LV in shared VG.");
+			return 0;
+		}
+
 		if (!(origin_lv = find_lv(vg, lp->origin_name))) {
 			log_error("Failed to find origin LV %s/%s", vg->name, lp->origin_name);
 			return 0;


