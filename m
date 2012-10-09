From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  9 Oct 2012 10:22:55 +0000 (UTC)
Subject: master - lvchange: do not start dmevent for resyn
Message-ID: <20121009102255.C6D7BAABF0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cdb7502e54aeb464216af271289deec12f15442e
Commit:        cdb7502e54aeb464216af271289deec12f15442e
Parent:        d414fe28fa1754690e8c72a16df5c2cdc1cc87e1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 9 12:20:47 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 9 12:22:26 2012 +0200

lvchange: do not start dmevent for resyn

If monitoring is disabled in lvm.conf, avoid its starting and preserve
DMEVENTD_MONITOR_IGNORE settings internally.
---
 WHATS_NEW        |    1 +
 tools/lvchange.c |    6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cf1b563..b1ed58c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Do not start dmeventd for lvchange --resync when monitoring is off.
   Remove ExecStartPost with pvscan --cache from lvm2-lvmetad.service.
   Report invalid percentage for property snap_percent of non-snaphot LVs.
   Disallow convertion of thins to mirrors.
diff --git a/tools/lvchange.c b/tools/lvchange.c
index b2c1fe4..3525617 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -370,7 +370,8 @@ static int lvchange_resync(struct cmd_context *cmd,
 
 	/* Activate exclusively to ensure no nodes still have LV active */
 	monitored = dmeventd_monitor_mode();
-	init_dmeventd_monitor(0);
+	if (monitored != DMEVENTD_MONITOR_IGNORE)
+		init_dmeventd_monitor(0);
 
 	if (!deactivate_lv(cmd, lv)) {
 		log_error("Unable to deactivate %s for resync", lv->name);
@@ -383,7 +384,8 @@ static int lvchange_resync(struct cmd_context *cmd,
 		return 0;
 	}
 
-	init_dmeventd_monitor(monitored);
+	if (monitored != DMEVENTD_MONITOR_IGNORE)
+		init_dmeventd_monitor(monitored);
 	init_mirror_in_sync(0);
 
 	log_very_verbose("Starting resync of %s%s%s%s \"%s\"",


