From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  2 Oct 2015 20:43:20 +0000 (UTC)
Subject: master - lockd: add error message for EEXIST
Message-ID: <20151002204320.5FA3E6030E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=df59db6048a6be79acf231b98fd560b11cce7c7c
Commit:        df59db6048a6be79acf231b98fd560b11cce7c7c
Parent:        b33d7586e7f629818e881e26677f4431a47d50b5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 2 15:41:23 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Oct 2 15:41:23 2015 -0500

lockd: add error message for EEXIST

The EEXIST error for LV locks is unusual, and
was missing an explanatory error message.
---
 lib/locking/lvmlockd.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index afbafcb..f741940 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -2010,6 +2010,15 @@ int lockd_lv_name(struct cmd_context *cmd, struct volume_group *vg,
 		return 0;
 	}
 
+	if (result == -EEXIST) {
+		/*
+		 * This happens if lvchange tries to modify the LV with an ex
+		 * LV lock when the LV is already active with a sh LV lock.
+		 */
+		log_error("LV is already locked with incompatible mode: %s/%s", vg->name, lv_name);
+		return 0;
+	}
+
 	if (result == -EMSGSIZE) {
 		/* Another host probably extended lvmlock. */
 		if (!refreshed++) {


