From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 22 Jul 2015 20:46:04 +0000 (UTC)
Subject: master - pvscan: skip autoactivation for lockd VGs
Message-ID: <20150722204604.D585860EE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b92e5026957c5ca72e6e88304feaf7527ca80af1
Commit:        b92e5026957c5ca72e6e88304feaf7527ca80af1
Parent:        27e6aee3904d195de658505b3bacc65601344d46
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jul 22 14:53:46 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 22 15:44:20 2015 -0500

pvscan: skip autoactivation for lockd VGs

pvscan autoactivation does not work for lockd VGs because
lock start is needed on a lockd VG before locking can be
done for it.  Add a check to skip the attempt at autoactivate
rather than calling it, knowing it will fail.

Add a comment explaining why pvscan --cache works fine for
lockd VGs without locks, and why autoactivate is not done.
---
 lib/cache/lvmetad.c |   45 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 60f0277..856b30f 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -952,6 +952,51 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 	     daemon_reply_int(reply, "seqno_after", -1) != daemon_reply_int(reply, "seqno_before", -1)))
 		log_warn("WARNING: Inconsistent metadata found for VG %s", vg->name);
 
+	/*
+	 * pvscan --cache does not perform any lvmlockd locking, and
+	 * pvscan --cache -aay skips autoactivation in lockd VGs.
+	 *
+	 * pvscan --cache populates lvmetad with VG metadata from disk.
+	 * No lvmlockd locking is needed.  It is expected that lockd VG
+	 * metadata that is read by pvscan and populated in lvmetad may
+	 * be immediately stale due to changes to the VG from other hosts
+	 * during or after this pvscan.  This is normal and not a problem.
+	 * When a subsequent lvm command uses the VG, it will lock the VG
+	 * with lvmlockd, read the VG from lvmetad, and update the cached
+	 * copy from disk if necessary.
+	 *
+	 * pvscan --cache -aay does not activate LVs in lockd VGs because
+	 * activation requires locking, and a lock-start operation is needed
+	 * on a lockd VG before any locking can be performed in it.
+	 *
+	 * An equivalent of pvscan --cache -aay for lockd VGs is:
+	 * 1. pvscan --cache
+	 * 2. vgchange --lock-start
+	 * 3. vgchange -aay -S 'locktype=sanlock || locktype=dlm'
+	 *
+	 * [We could eventually add support for autoactivating lockd VGs
+	 * using pvscan by incorporating the lock start step (which can
+	 * take a long time), but there may be a better option than
+	 * continuing to overload pvscan.]
+	 * 
+	 * Stages of starting a lockd VG:
+	 *
+	 * . pvscan --cache populates lockd VGs in lvmetad without locks,
+	 *   and this initial cached copy may quickly become stale.
+	 *
+	 * . vgchange --lock-start VG reads the VG without the VG lock
+	 *   because no locks are available until the locking is started.
+	 *   It only uses the VG name and lock_type from the VG metadata,
+	 *   and then only uses it to start the VG lockspace in lvmlockd.
+	 *
+	 * . Further lvm commands, e.g. activation, can then lock the VG
+	 *   with lvmlockd and use current VG metdata.
+	 */
+	if (handler && vg && is_lockd_type(vg->lock_type)) {
+		log_debug_lvmetad("Skip pvscan activation for lockd type VG %s", vg->name);
+		handler = NULL;
+	}
+
 	if (result && handler) {
 		status = daemon_reply_str(reply, "status", "<missing>");
 		vgname = daemon_reply_str(reply, "vgname", "<missing>");


