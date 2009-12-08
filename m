From: Milan Broz <mbroz@redhat.com>
Date: Tue,  8 Dec 2009 16:40:09 +0100
Subject: [PATCH 09/10] Never ever use distributed lock for LV in non-clustered VG.
In-Reply-To: <cover.1260284754.git.mbroz@redhat.com>
References: <cover.1260284754.git.mbroz@redhat.com>
Message-ID: <0c4744f150020f9f9ff458de89fb44bdfcb93679.1260284754.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The LV locks make sense only for clustered LVs.

Properly check cluster flag and never issue cluster lock here.

There are several places in code, where it is already checked, this
patch add this check to all needed calls.

In previous code the lock behaviour was inconsistent,
for example, the pre/post callback can take lock even for local volume,
but deactivate call do not released this lock and it remains held forever.

The local LV lock request now just let run the underlying activation code
on local node, the same process like in local locking.

(Again, this is important for new mirror repair calls, here for local
mirrors but with cluster locking enabled.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 daemons/clvmd/lvm-functions.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index bd340fd..be160c3 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -331,7 +331,8 @@ static int do_activate_lv(char *resource, unsigned char lock_flags, int mode)
 
 	/* Is it already open ? */
 	oldmode = get_current_lock(resource);
-	if (oldmode == mode) {
+	if (oldmode == mode && (lock_flags & LCK_CLUSTER_VG)) {
+		DEBUGLOG("do_activate_lv, lock already held at %d\n", oldmode);
 		return 0;	/* Nothing to do */
 	}
 
@@ -380,13 +381,13 @@ static int do_activate_lv(char *resource, unsigned char lock_flags, int mode)
 }
 
 /* Resume the LV if it was active */
-static int do_resume_lv(char *resource)
+static int do_resume_lv(char *resource, unsigned char lock_flags)
 {
 	int oldmode;
 
 	/* Is it open ? */
 	oldmode = get_current_lock(resource);
-	if (oldmode == -1) {
+	if (oldmode == -1 && (lock_flags & LCK_CLUSTER_VG)) {
 		DEBUGLOG("do_resume_lv, lock not already held\n");
 		return 0;	/* We don't need to do anything */
 	}
@@ -398,15 +399,15 @@ static int do_resume_lv(char *resource)
 }
 
 /* Suspend the device if active */
-static int do_suspend_lv(char *resource)
+static int do_suspend_lv(char *resource, unsigned char lock_flags)
 {
 	int oldmode;
 	struct lvinfo lvi;
 
 	/* Is it open ? */
 	oldmode = get_current_lock(resource);
-	if (oldmode == -1) {
-		DEBUGLOG("do_suspend_lv, lock held at %d\n", oldmode);
+	if (oldmode == -1 && (lock_flags & LCK_CLUSTER_VG)) {
+		DEBUGLOG("do_suspend_lv, lock not already held\n");
 		return 0; /* Not active, so it's OK */
 	}
 
@@ -498,14 +499,14 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 		break;
 
 	case LCK_LV_SUSPEND:
-		status = do_suspend_lv(resource);
+		status = do_suspend_lv(resource, lock_flags);
 		if (!status)
 			suspended++;
 		break;
 
 	case LCK_UNLOCK:
 	case LCK_LV_RESUME:	/* if active */
-		status = do_resume_lv(resource);
+		status = do_resume_lv(resource, lock_flags);
 		if (!status)
 			suspended--;
 		break;
@@ -547,7 +548,7 @@ int pre_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 	   lock out on this node (because we are the node modifying the metadata)
 	   before suspending cluster-wide.
 	 */
-	if (command == LCK_LV_SUSPEND) {
+	if (command == LCK_LV_SUSPEND && (lock_flags & LCK_CLUSTER_VG)) {
 		DEBUGLOG("pre_lock_lv: resource '%s', cmd = %s, flags = %s\n",
 			 resource, decode_locking_cmd(command), decode_flags(lock_flags));
 
@@ -564,7 +565,7 @@ int post_lock_lv(unsigned char command, unsigned char lock_flags,
 	int status;
 
 	/* Opposite of above, done on resume after a metadata update */
-	if (command == LCK_LV_RESUME) {
+	if (command == LCK_LV_RESUME && (lock_flags & LCK_CLUSTER_VG)) {
 		int oldmode;
 
 		DEBUGLOG
-- 
1.6.5.4


