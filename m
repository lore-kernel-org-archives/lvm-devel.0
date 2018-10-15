From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:56:08 -0400
Subject: master - cov: pvscan ensure sigle_devs list is always initialized
Message-ID: <201810151556.w9FFu8x9020745@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c4f39decc8d6fb213af21f16d99b460362ce295f
Commit:        c4f39decc8d6fb213af21f16d99b460362ce295f
Parent:        43e4bfe428cb4e8a953a74aeca5b1942ce6f55a4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 16:57:32 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: pvscan ensure sigle_devs list is always initialized

---
 tools/pvscan.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 613a4c4..d110a6b 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -620,6 +620,7 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	int add_errors = 0;
 	int ret = ECMD_PROCESSED;
 
+	dm_list_init(&single_devs);
 	dm_list_init(&found_vgnames);
 
 	if (arg_is_set(cmd, major_ARG) + arg_is_set(cmd, minor_ARG))
@@ -664,8 +665,6 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	/* Creates a list of dev names from /dev, sysfs, etc; does not read any. */
 	dev_cache_scan();
 
-	dm_list_init(&single_devs);
-
 	while (argc--) {
 		pv_name = *argv++;
 		if (pv_name[0] == '/') {


