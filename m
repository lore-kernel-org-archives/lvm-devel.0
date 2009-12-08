From: Milan Broz <mbroz@redhat.com>
Date: Tue,  8 Dec 2009 16:39:59 +0100
Subject: [PATCH 08/10] Allow implicit lock conversion for pre/post callbacks.
In-Reply-To: <cover.1260284754.git.mbroz@redhat.com>
References: <cover.1260284754.git.mbroz@redhat.com>
Message-ID: <6cd62b88d5abb2b31e30d9f616eaf9406e21cfd4.1260284754.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is unnoticed (because of bug mentioned in previous patch)
regression from commit 31672ff60e405795cad70d6d7888ac011f5373ce

The pre/post callback need to convert lock always, local node
is going to modify metadata in this case, it it fails conversion,
the call is ignored.

Also it fixes bug when the lock is not yet held, we cannot set LKF_CONVERT
in this case, it will fail because this lock do not exist.

p.s. I am really not sure if this is correct solution to problem,
but the regression here is obvious. Maybe we should separate the real calls
which _request_ conversion and explicitly set LCK_CONVERT flag.

Note that the automatic conversion is still disabled in activate
call, so the original fix (reactivation of exlusive LV) should
be still in place.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 6f89cc3..bd340fd 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -274,7 +274,7 @@ int hold_lock(char *resource, int mode, int flags)
 			return -1;
 
 		lvi->lock_mode = mode;
-		status = sync_lock(resource, mode, flags, &lvi->lock_id);
+		status = sync_lock(resource, mode, flags & ~LKF_CONVERT, &lvi->lock_id);
 		saved_errno = errno;
 		if (status) {
 			free(lvi);
@@ -551,7 +551,7 @@ int pre_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 		DEBUGLOG("pre_lock_lv: resource '%s', cmd = %s, flags = %s\n",
 			 resource, decode_locking_cmd(command), decode_flags(lock_flags));
 
-		if (hold_lock(resource, LKM_PWMODE, LKF_NOQUEUE| (lock_flags & LCK_CONVERT?LKF_CONVERT:0)))
+		if (hold_lock(resource, LKM_PWMODE, LKF_NOQUEUE | LKF_CONVERT))
 			return errno;
 	}
 	return 0;
@@ -583,7 +583,7 @@ int post_lock_lv(unsigned char command, unsigned char lock_flags,
 				return EIO;
 
 			if (lvi.exists) {
-				if (hold_lock(resource, LKM_CRMODE, lock_flags & LCK_CONVERT?LKF_CONVERT:0))
+				if (hold_lock(resource, LKM_CRMODE, LKF_CONVERT))
 					return errno;
 			} else {
 				if (hold_unlock(resource))
-- 
1.6.5.4


