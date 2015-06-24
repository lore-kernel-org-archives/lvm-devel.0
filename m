From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 24 Jun 2015 09:27:43 +0000 (UTC)
Subject: master - config: display global/umask in octal form
Message-ID: <20150624092743.9E2B360DF6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6575122c63de3d400ee46ea0f400ab44b8520978
Commit:        6575122c63de3d400ee46ea0f400ab44b8520978
Parent:        74bf75a2f5f7b918e1fe7531766aa377de23191c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 23 13:24:15 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 24 11:13:38 2015 +0200

config: display global/umask in octal form

---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 1b67488..461bacc 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -597,7 +597,7 @@ cfg(backup_retain_days_CFG, "retain_days", backup_CFG_SECTION, 0, CFG_TYPE_INT,
 cfg(shell_history_size_CFG, "history_size", shell_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_MAX_HISTORY, vsn(1, 0, 0), NULL, 0, NULL,
 	"Number of lines of history to store in ~/.lvm_history.\n")
 
-cfg(global_umask_CFG, "umask", global_CFG_SECTION, 0, CFG_TYPE_INT, DEFAULT_UMASK, vsn(1, 0, 0), NULL, 0, NULL,
+cfg(global_umask_CFG, "umask", global_CFG_SECTION, CFG_FORMAT_INT_OCTAL, CFG_TYPE_INT, DEFAULT_UMASK, vsn(1, 0, 0), NULL, 0, NULL,
 	"The file creation mask for any files and directories created.\n"
 	"Interpreted as octal if the first digit is zero.\n")
 


