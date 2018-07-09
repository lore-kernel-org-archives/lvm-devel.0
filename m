From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:34:05 -0400
Subject: master - activate: kvdo modprobe workaround
Message-ID: <201807091334.w69DY533030563@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2e05f6018bc3cbc8104ea53fb8a3e041ef5f899a
Commit:        2e05f6018bc3cbc8104ea53fb8a3e041ef5f899a
Parent:        80e6097ea6bc56548304185715f04e8eaca2da48
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 29 11:02:24 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:28:35 2018 +0200

activate: kvdo modprobe workaround

To support autoloading of VDO dm target driver loading of 'kvdo'
kernel module is needed - ATM it's not using 'dm-vdo' name.
So to support this strange name - add temporarily solution to
autoload  kvdo kernel module in this case.
---
 lib/activate/activate.c |    6 ++++++
 lib/activate/activate.h |    1 +
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 8f4462a..4facb7c 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -585,6 +585,12 @@ int module_present(struct cmd_context *cmd, const char *target_name)
 	}
 
 #ifdef MODPROBE_CMD
+	if (strcmp(target_name, MODULE_NAME_VDO) == 0) {
+		argv[1] = target_name;		/* ATM kvdo is without dm- prefix */
+		if ((ret = exec_cmd(cmd, argv, NULL, 0)))
+			return ret;
+	}
+
 	if (dm_snprintf(module, sizeof(module), "dm-%s", target_name) < 0) {
 		log_error("module_present module name too long: %s",
 			  target_name);
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 2f0b0a0..5d77f40 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -271,6 +271,7 @@ void fs_unlock(void);
 #define MODULE_NAME_MIRROR TARGET_NAME_MIRROR
 #define MODULE_NAME_SNAPSHOT TARGET_NAME_SNAPSHOT
 #define MODULE_NAME_RAID TARGET_NAME_RAID
+#define MODULE_NAME_VDO "kvdo"          /* does NOT use dm- prefix */
 #define MODULE_NAME_ZERO TARGET_NAME_ZERO
 
 #endif


