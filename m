From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:45:43 -0400
Subject: master - lvmdbusd: Bug fix for activate/deactivate
Message-ID: <201910301545.x9UFjh03016970@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f56b21ae2c7667d69c050653d527f9071ef83ad5
Commit:        f56b21ae2c7667d69c050653d527f9071ef83ad5
Parent:        9e15c83673436342a60b8f982e521eb32d972a0c
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Oct 10 16:49:09 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbusd: Bug fix for activate/deactivate

Prevent the daemon from stalling when it gets stuck on a y/n prompt.
---
 daemons/lvmdbusd/cmdhandler.py |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 67d4321..e0bb105 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -738,6 +738,7 @@ def activate_deactivate(op, name, activate, control_flags, options):
 		op += 'n'
 
 	cmd.append(op)
+	cmd.append("-y")
 	cmd.append(name)
 	return call(cmd)
 


