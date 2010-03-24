From: Milan Broz <mbroz@redhat.com>
Date: Wed, 24 Mar 2010 10:19:01 +0100
Subject: [PATCH v2] improve activation monitoring option processing
In-Reply-To: <1269372233-4199-1-git-send-email-snitzer@redhat.com>
References: <1269372233-4199-1-git-send-email-snitzer@redhat.com>
Message-ID: <4BA9D905.9090107@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



On 03/23/2010 08:23 PM, Mike Snitzer wrote:
> Add "monitoring" option to "activation" section of lvm.conf
>
> Have clvmd consult the lvm.conf "activation/monitoring" too.
please do it something like this... (untested)

Milan
---

 daemons/clvmd/lvm-functions.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 60b6db4..b62969c 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -483,6 +483,7 @@ const char *do_lock_query(char *resource)
 int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 {
 	int status = 0;
+	int dmeventd_mode = dmeventd_monitor_mode();
 
 	DEBUGLOG("do_lock_lv: resource '%s', cmd = %s, flags = %s, memlock = %d\n",
 		 resource, decode_locking_cmd(command), decode_flags(lock_flags), memlock());
@@ -542,12 +543,8 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
 	if (lock_flags & LCK_MIRROR_NOSYNC_MODE)
 		init_mirror_in_sync(0);
 
-	if (!(lock_flags & LCK_DMEVENTD_MONITOR_MODE)) {
-		int dmeventd_mode =
-			find_config_tree_bool(cmd, "activation/monitoring",
-					      DEFAULT_DMEVENTD_MONITOR);
+	if (!(lock_flags & LCK_DMEVENTD_MONITOR_MODE))
 		init_dmeventd_monitor(dmeventd_mode);
-	}
 
 	cmd->partial_activation = 0;
 
@@ -638,6 +635,9 @@ int do_refresh_cache()
 		return -1;
 	}
 
+	init_dmeventd_monitor(find_config_tree_bool(cmd,
+			      "activation/monitoring",
+			      DEFAULT_DMEVENTD_MONITOR));
 	init_full_scan_done(0);
 	init_ignore_suspended_devices(1);
 	lvmcache_label_scan(cmd, 2);



