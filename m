From: Milan Broz <mbroz@redhat.com>
Date: Tue,  8 Dec 2009 16:39:32 +0100
Subject: [PATCH 05/10] Allow implicit "convert" to the same lock mode.
In-Reply-To: <cover.1260284754.git.mbroz@redhat.com>
References: <cover.1260284754.git.mbroz@redhat.com>
Message-ID: <357424a00b84cecf28431be1397e323783026c84.1260284754.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

(Code already not fauils if unlocking not locked resource.)

This is needed in pre/post lock_lv call, where we can
request the same lock on local node becuase of suspend call.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index e56d11b..6f89cc3 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -245,6 +245,11 @@ int hold_lock(char *resource, int mode, int flags)
 
 	lvi = lookup_info(resource);
 
+	if (lvi && lvi->lock_mode == mode) {
+		DEBUGLOG("hold_lock, lock mode %d already held\n", mode);
+		return 0;
+	}
+
 	/* Only allow explicit conversions */
 	if (lvi && !(flags & LKF_CONVERT)) {
 		errno = EBUSY;
-- 
1.6.5.4


