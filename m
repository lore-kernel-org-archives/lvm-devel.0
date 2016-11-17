From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 17 Nov 2016 17:46:10 +0000 (UTC)
Subject: master - lvmdbusd: Remove debug JSON file
Message-ID: <20161117174610.1394F60363@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=19a0bf9df61d2ad58cc1be70cf6132b57cb49c85
Commit:        19a0bf9df61d2ad58cc1be70cf6132b57cb49c85
Parent:        bd47b202fb373a93761e038afe39fb6aeee89289
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Nov 17 11:45:11 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 17 11:45:11 2016 -0600

lvmdbusd: Remove debug JSON file

---
 daemons/lvmdbusd/lvm_shell_proxy.py |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py b/daemons/lvmdbusd/lvm_shell_proxy.py
index 193c844..4ab42c5 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py
@@ -229,10 +229,6 @@ class LVMShellProxy(object):
 					else:
 						error_msg = self.get_error_msg()
 			except ValueError:
-				# The json is bad?, lets dump out for debug
-				with open('/tmp/json_bad', 'w') as debug:
-					debug.write(report)
-
 				# Bubble up the invalid json.
 				error_msg = "Invalid json %s" % report
 


