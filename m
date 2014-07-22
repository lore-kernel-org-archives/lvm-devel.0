From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue, 22 Jul 2014 20:49:53 +0000 (UTC)
Subject: master - dmeventd: Call lvscan --cache in the RAID plugin.
Message-ID: <20140722204953.7F6156110F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5dc6671bb550f4b480befee03d234373d08e188a
Commit:        5dc6671bb550f4b480befee03d234373d08e188a
Parent:        a9ea014e5152b806f57f6099311b64a2c03ca482
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jul 21 04:33:21 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Jul 22 22:48:21 2014 +0200

dmeventd: Call lvscan --cache in the RAID plugin.

---
 daemons/dmeventd/plugins/raid/dmeventd_raid.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index 3fbae15..4690cfa 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -33,10 +33,20 @@ static int run_repair(const char *device)
 	char cmd_str[CMD_SIZE];
 
 	if (!dmeventd_lvm2_command(dmeventd_lvm2_pool(), cmd_str, sizeof(cmd_str),
+				  "lvscan --cache", device))
+		return -1;
+
+	r = dmeventd_lvm2_run(cmd_str);
+
+	if (!r)
+		syslog(LOG_INFO, "Re-scan of RAID device %s failed.", device);
+
+	if (!dmeventd_lvm2_command(dmeventd_lvm2_pool(), cmd_str, sizeof(cmd_str),
 				  "lvconvert --config devices{ignore_suspended_devices=1} "
 				  "--repair --use-policies", device))
 		return -1;
 
+	/* if repair goes OK, report success even if lvscan has failed */
 	r = dmeventd_lvm2_run(cmd_str);
 
 	if (!r)


