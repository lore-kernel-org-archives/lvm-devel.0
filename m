From: Eric Ren <zren@suse.com>
Date: Wed, 24 May 2017 16:45:19 +0800
Subject: [PATCH] clvmd: try to refresh device cache on the first failure
Message-ID: <20170524084519.12204-1-zren@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Sometimes, the device cache in clvmd could be out of date.
"clvmd -R" is invented for this issue. However, to run
"clvmd -R" manually is not convenient, because it's hard
to predict when device change would happen.

This patch gives another try after refreshing the device
cache. In normal, it doesn't cause any side-effect. In
case of the issue above, it's worth a retry.

Signed-off-by: Eric Ren <zren@suse.com>
---
 daemons/clvmd/lvm-functions.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index e872fbe..b4a64b3 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -507,11 +507,14 @@ const char *do_lock_query(char *resource)
 int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 {
 	int status = 0;
+	int do_refresh = 0;
 
 	DEBUGLOG("do_lock_lv: resource '%s', cmd = %s, flags = %s, critical_section = %d\n",
 		 resource, decode_locking_cmd(command), decode_flags(lock_flags), critical_section());
 
-	if (!cmd->initialized.config || config_files_changed(cmd)) {
+again:
+	if (!cmd->initialized.config || config_files_changed(cmd)
+	    || do_refresh) {
 		/* Reinitialise various settings inc. logging, filters */
 		if (do_refresh_cache()) {
 			log_error("Updated config file invalid. Aborting.");
@@ -577,6 +580,12 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 	init_test(0);
 	pthread_mutex_unlock(&lvm_lock);
 
+	/* Try again in case device cache is stale */
+	if (status == EIO && !do_refresh) {
+		do_refresh = 1;
+		goto again;
+	}
+
 	DEBUGLOG("Command return is %d, critical_section is %d\n", status, critical_section());
 	return status;
 }
-- 
2.10.2


