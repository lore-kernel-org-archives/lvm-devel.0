From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 14 Mar 2014 14:58:02 +0000 (UTC)
Subject: master - cleanup: use 'define' for systemd runtime unit file directory
Message-ID: <20140314145802.9F89E60F43@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b16235de96a18c9e9e619bebe506d41f80fff834
Commit:        b16235de96a18c9e9e619bebe506d41f80fff834
Parent:        ada47c164ae56b586fae7500be2d6aa66f5323b1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 14 15:57:28 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 14 15:57:44 2014 +0100

cleanup: use 'define' for systemd runtime unit file directory

---
 daemons/dmeventd/dmeventd.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 6206058..f4f09b8 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -55,6 +55,7 @@
 #  define OOM_SCORE_ADJ_MIN (-1000)
 
 /* Systemd on-demand activation support */
+#  define SD_RUNTIME_UNIT_FILE_DIR DEFAULT_DM_RUN_DIR "/systemd/system/"
 #  define SD_ACTIVATION_ENV_VAR_NAME "SD_ACTIVATION"
 #  define SD_LISTEN_PID_ENV_VAR_NAME "LISTEN_PID"
 #  define SD_LISTEN_FDS_ENV_VAR_NAME "LISTEN_FDS"
@@ -1997,7 +1998,7 @@ static void restart(void)
 	if (version < 2) {
 		/* This check is copied from sd-daemon.c. */
 		struct stat st;
-		if (!lstat("/run/systemd/system/", &st) && !!S_ISDIR(st.st_mode))
+		if (!lstat(SD_RUNTIME_UNIT_FILE_DIR, &st) && !!S_ISDIR(st.st_mode))
 			_systemd_activation = 1;
 	}
 #endif


