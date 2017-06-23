From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Jun 2017 17:33:39 -0400
Subject: master - raid: plugin does not to use --config
Message-ID: <201706232133.v5NLXdTf022569@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=653bdedb83fecf2b4fe2f4c84664c72ffd911e41
Commit:        653bdedb83fecf2b4fe2f4c84664c72ffd911e41
Parent:        2b18be87aa7cc1439e8b138690f79dd4eed73afc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 23 21:15:37 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 23 23:32:40 2017 +0200

raid: plugin does not to use --config

Functionality of ignore suspend devices is already granted by:

lvm2_disable_dmeventd_monitoring() -> init_run_by_dmeventd() ->
init_ignore_suspended_devices().

In fact plugins should never use --config because it has
some unpleasant technical issues.
---
 WHATS_NEW_DM                                  |    1 +
 daemons/dmeventd/plugins/raid/dmeventd_raid.c |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 581cd42..3e0e8a5 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.141 - 
 ===============================
+  Drop unneeded --config option from raid dmeventd plugin.
   dm_get_status_raid() handle better some incosistent md statuses.
   Accept truncated files in calls to dm_stats_update_regions_from_fd().
   Restore Warning by 5% increment when thin-pool is over 80% (1.02.138).
diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index afeac28..666362a 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -150,8 +150,7 @@ int register_device(const char *device,
 		goto_bad;
 
 	if (!dmeventd_lvm2_command(state->mem, state->cmd_lvconvert, sizeof(state->cmd_lvconvert),
-				   "lvconvert --config devices{ignore_suspended_devices=1} "
-				   "--repair --use-policies", device))
+				   "lvconvert --repair --use-policies", device))
 		goto_bad;
 
 	*user = state;


