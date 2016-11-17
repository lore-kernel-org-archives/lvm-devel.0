From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 17 Nov 2016 20:00:23 +0000 (UTC)
Subject: master - lvmdbusd: Remove extraneous finally
Message-ID: <20161117200023.AF26D60301@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0bbf63134974b85096a7949558f5546204a2a135
Commit:        0bbf63134974b85096a7949558f5546204a2a135
Parent:        3b4c5a2151a3a121123a0e4d5b9fd20344979a23
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Nov 17 13:59:39 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 17 13:59:39 2016 -0600

lvmdbusd: Remove extraneous finally

The print statement is incorrect.
---
 daemons/lvmdbusd/lvm_shell_proxy.py |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/lvm_shell_proxy.py b/daemons/lvmdbusd/lvm_shell_proxy.py
index 4ab42c5..8d15e10 100755
--- a/daemons/lvmdbusd/lvm_shell_proxy.py
+++ b/daemons/lvmdbusd/lvm_shell_proxy.py
@@ -274,5 +274,3 @@ if __name__ == "__main__":
 		pass
 	except Exception:
 		traceback.print_exc(file=sys.stdout)
-	finally:
-		print()


