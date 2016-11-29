From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 29 Nov 2016 22:51:33 +0000 (UTC)
Subject: master - lvmdbusd: Remove debug log_error
Message-ID: <20161129225133.50861612EC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=58f4d98af11eaf21df00aaaf987ca6a92039db7f
Commit:        58f4d98af11eaf21df00aaaf987ca6a92039db7f
Parent:        617a819abc553aaf79058f4016697328a9b1d98a
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Nov 29 15:02:52 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Nov 29 16:50:30 2016 -0600

lvmdbusd: Remove debug log_error

---
 daemons/lvmdbusd/lvm_shell_proxy.py |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py b/daemons/lvmdbusd/lvm_shell_proxy.py
index ae8049f..f3862a1 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py
@@ -101,8 +101,6 @@ class LVMShellProxy(object):
 									keep_reading = False
 								except ValueError:
 									pass
-						else:
-							log_error("RACE!", 'bg_black', 'fg_light_red')
 
 						if keep_reading:
 							extra_passes -= 1


