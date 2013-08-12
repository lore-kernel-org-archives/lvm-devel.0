From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 12 Aug 2013 18:57:34 +0000 (UTC)
Subject: master - Mirror: Fix inability to remove VG's cluster flag if it contains a mirror
Message-ID: <20130812185734.EE7B460DE7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=abc89422af75fa9e20d24285d1366e4631cb8748
Commit:        abc89422af75fa9e20d24285d1366e4631cb8748
Parent:        bb457adbb6d625a5f942faf8498bb5ee87645ec3
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Aug 12 13:56:47 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Aug 12 13:56:47 2013 -0500

Mirror: Fix inability to remove VG's cluster flag if it contains a mirror

According to bug 995193, if a volume group
	1) contains a mirror
	2) is clustered
	3) 'locking_type' = 0 is used
then it is not possible to remove the 'c'luster flag from the VG.  This
is due to the way _lv_is_active behaves.

We shouldn't allow the cluster flag to be flipped unless the mirrors in
the cluster are not active.  This is because different kernel modules
are used depending on whether a mirror is cluster or not.  When we
attempt to see if the mirror is active, we first check locally.  If it
is not, then we attempt to check for remotely active instances if the VG
is clustered.  Since the no_lock locking type is LCK_CLUSTERED, but does
not implement 'query_resource', remote_lock_held will always return an
error in this case.  An error from remove_lock_held is treated as though
the lock _is_ held (i.e. the LV is active remotely).  This blocks the
cluster flag from changing.

The solution is to implement 'query_resource' for the no_lock type.  It
will report a message and return 1.  This will allow _lv_is_active to
function properly.  The LV would be considered not active remotely and
the VG can change its flag.
---
 WHATS_NEW                |    1 +
 lib/locking/no_locking.c |    9 +++++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 44a1437..68d4679 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.100 -
 ================================
+  Fix inability to remove a VG's cluster flag if it contains a mirror.
   Suppress arg: prefix in log_sys_error macro when arg is empty string.
   Fix bug making lvchange unable to change recovery rate for RAID.
   Prohibit conversion of thin pool to external origin.
diff --git a/lib/locking/no_locking.c b/lib/locking/no_locking.c
index b1b235c..5f3f0b6 100644
--- a/lib/locking/no_locking.c
+++ b/lib/locking/no_locking.c
@@ -66,6 +66,13 @@ static int _no_lock_resource(struct cmd_context *cmd, const char *resource,
 	return 1;
 }
 
+static int _no_query_resource(const char *resource, int *mode)
+{
+	log_very_verbose("Locking is disabled: Treating lock %s as not held.",
+			 resource);
+	return 1;
+}
+
 static int _readonly_lock_resource(struct cmd_context *cmd,
 				   const char *resource,
 				   uint32_t flags, struct logical_volume *lv)
@@ -86,6 +93,7 @@ int init_no_locking(struct locking_type *locking, struct cmd_context *cmd __attr
 		    int suppress_messages)
 {
 	locking->lock_resource = _no_lock_resource;
+	locking->query_resource = _no_query_resource;
 	locking->reset_locking = _no_reset_locking;
 	locking->fin_locking = _no_fin_locking;
 	locking->flags = LCK_CLUSTERED;
@@ -97,6 +105,7 @@ int init_readonly_locking(struct locking_type *locking, struct cmd_context *cmd
 			  int suppress_messages)
 {
 	locking->lock_resource = _readonly_lock_resource;
+	locking->query_resource = _no_query_resource;
 	locking->reset_locking = _no_reset_locking;
 	locking->fin_locking = _no_fin_locking;
 	locking->flags = 0;


