From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 14 Jan 2015 17:08:10 +0000 (UTC)
Subject: master - dmeventd: Call lvscan --cache also for mirrors (in addition to RAID).
Message-ID: <20150114170810.540B460300@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eac4e1e939c6fe7eba0d2c3865e25b8ed43fe6d9
Commit:        eac4e1e939c6fe7eba0d2c3865e25b8ed43fe6d9
Parent:        4a55175bacbad1261917f170254040fb2846f994
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Jan 14 18:04:46 2015 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jan 14 18:05:44 2015 +0100

dmeventd: Call lvscan --cache also for mirrors (in addition to RAID).

---
 daemons/dmeventd/plugins/mirror/dmeventd_mirror.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
index 2328089..084be28 100644
--- a/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
+++ b/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
@@ -136,10 +136,20 @@ static int _remove_failed_devices(const char *device)
 	char cmd_str[CMD_SIZE];
 
 	if (!dmeventd_lvm2_command(dmeventd_lvm2_pool(), cmd_str, sizeof(cmd_str),
+				   "lvscan --cache", device))
+		return -1;
+
+	r = dmeventd_lvm2_run(cmd_str);
+
+	if (!r)
+		syslog(LOG_INFO, "Re-scan of mirror device %s failed.", device);
+
+	if (!dmeventd_lvm2_command(dmeventd_lvm2_pool(), cmd_str, sizeof(cmd_str),
 				  "lvconvert --config devices{ignore_suspended_devices=1} "
 				  "--repair --use-policies", device))
 		return -ENAMETOOLONG; /* FIXME Replace with generic error return - reason for failure has already got logged */
 
+	/* if repair goes OK, report success even if lvscan has failed */
 	r = dmeventd_lvm2_run(cmd_str);
 
 	syslog(LOG_INFO, "Repair of mirrored device %s %s.", device,


