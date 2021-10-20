From: David Teigland <teigland@sourceware.org>
Date: Wed, 20 Oct 2021 21:13:44 +0000 (GMT)
Subject: main - pvscan: fix messages from coverity changes
Message-ID: <20211020211344.C6F003858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ae355ffc3f3286990778517e1ad6620368611258
Commit:        ae355ffc3f3286990778517e1ad6620368611258
Parent:        819a35cc9133889b5efc4833d8191e3e71396552
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 20 16:12:41 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 20 16:12:55 2021 -0500

pvscan: fix messages from coverity changes

---
 tools/pvscan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 95d593d57..7d84e45d4 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1362,7 +1362,7 @@ static int _online_devs(struct cmd_context *cmd, int do_all, struct dm_list *pvs
 		devsize = dev->size;
 		if (!devsize &&
 		    !dev_get_size(dev, &devsize)) {
-			log_print("pvscan[%d] PV %s can get device size.", getpid(), dev_name(dev));
+			log_print_pvscan(cmd, "PV %s missing device size.", dev_name(dev));
 			release_vg(vg);
 			continue;
 		}
@@ -1800,7 +1800,7 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 		int has_pvid;
 
 		if (!label_read_pvid(devl->dev, &has_pvid)) {
-			log_print("pvscan[%d] %s cannot read.", getpid(), dev_name(devl->dev));
+			log_print_pvscan(cmd, "%s cannot read label.", dev_name(devl->dev));
 			dm_list_del(&devl->list);
 			continue;
 		}


