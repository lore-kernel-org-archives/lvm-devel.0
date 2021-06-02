From: David Teigland <teigland@sourceware.org>
Date: Wed,  2 Jun 2021 21:40:54 +0000 (GMT)
Subject: main - pvchange: fix file locking deadlock
Message-ID: <20210602214054.E3E0A3844072@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2bce6faed017df8da3e659eff3f42f39d25c7f09
Commit:        2bce6faed017df8da3e659eff3f42f39d25c7f09
Parent:        e7f107c24666c8577f30e530b74f1ce0347e459b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 2 16:29:54 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 2 16:29:54 2021 -0500

pvchange: fix file locking deadlock

Calling clear_hint_file() to invalidate hints would acquire
the hints flock before the global flock which could cause deadlock.
The lock order requires the global lock to be taken first.

pvchange was always invalidating hints, which was unnecessary;
only invalidate hints when changing a PV uuid.  Because of the
lock ordering, take the global lock before clear_hint_file which
locks the hints file.
---
 tools/pvchange.c | 27 ++++++++++++++++++++++++++-
 1 file changed, 26 insertions(+), 1 deletion(-)

diff --git a/tools/pvchange.c b/tools/pvchange.c
index d6e35d66f..04cbb428d 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -248,7 +248,32 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 
 	set_pv_notify(cmd);
 
-	clear_hint_file(cmd);
+	/*
+	 * Changing a PV uuid is the only pvchange that invalidates hints.
+	 * Invalidating hints (clear_hint_file) is called at the start of
+	 * the command and takes the hints lock.
+	 * The global lock must always be taken first, then the hints lock
+	 * (the required lock ordering.)
+	 *
+	 * Because of these constraints, the global lock is taken ex here
+	 * for any PV uuid change, even though the global lock is technically
+	 * required only for changing an orphan PV (we don't know until later
+	 * if the PV is an orphan).  The VG lock is used when changing
+	 * non-orphan PVs.
+	 *
+	 * For changes other than uuid on an orphan PV, the global lock is
+	 * taken sh by process_each, then converted to ex in pvchange_single,
+	 * which works because the hints lock is not held.
+	 *
+	 * (Eventually, perhaps always do lock_global(ex) here to simplify.)
+	 */
+	if (arg_is_set(cmd, uuid_ARG)) {
+		if (!lock_global(cmd, "ex")) {
+			ret = ECMD_FAILED;
+			goto out;
+		}
+		clear_hint_file(cmd);
+	}
 
 	ret = process_each_pv(cmd, argc, argv, NULL, 0, READ_FOR_UPDATE, handle, _pvchange_single);
 


