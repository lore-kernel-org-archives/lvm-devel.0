From: Milan Broz <mbroz@redhat.com>
Date: Tue,  8 Dec 2009 16:40:18 +0100
Subject: [PATCH 10/10] Add memlock information to do_lock_lv debug output.
In-Reply-To: <cover.1260284754.git.mbroz@redhat.com>
References: <cover.1260284754.git.mbroz@redhat.com>
Message-ID: <3de2d1e5dc539cd9957839abcc1ebae58cd651ff.1260284754.git.mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This helps a lot to detect that something strange happened.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 daemons/clvmd/lvm-functions.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index be160c3..72b5b25 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -473,8 +473,8 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 {
 	int status = 0;
 
-	DEBUGLOG("do_lock_lv: resource '%s', cmd = %s, flags = %s\n",
-		 resource, decode_locking_cmd(command), decode_flags(lock_flags));
+	DEBUGLOG("do_lock_lv: resource '%s', cmd = %s, flags = %s, memlock = %d\n",
+		 resource, decode_locking_cmd(command), decode_flags(lock_flags), memlock());
 
 	if (!cmd->config_valid || config_files_changed(cmd)) {
 		/* Reinitialise various settings inc. logging, filters */
@@ -537,7 +537,7 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 	dm_pool_empty(cmd->mem);
 	pthread_mutex_unlock(&lvm_lock);
 
-	DEBUGLOG("Command return is %d\n", status);
+	DEBUGLOG("Command return is %d, memlock is %d\n", status, memlock());
 	return status;
 }
 
-- 
1.6.5.4


