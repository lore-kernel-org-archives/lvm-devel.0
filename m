From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 28 Jun 2016 19:24:39 +0000 (UTC)
Subject: master - lvmdbusd: Remove WARNING for 'lvm help'
Message-ID: <20160628192439.C7E4B611B3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e6e5c3d3ecb7de18ec2d103df8e5b0229df9ce1c
Commit:        e6e5c3d3ecb7de18ec2d103df8e5b0229df9ce1c
Parent:        7c5a08521b687c7c7074b41d880e1e559d4ea6b8
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Jun 28 12:52:31 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jun 28 12:54:48 2016 -0500

lvmdbusd: Remove WARNING for 'lvm help'

We call 'lvm help' to find out if fullreport is supported.  Lvm
dumps help to stderr.  Common code prints a warning if we exit
with 0, but have something in stderr so we are skipping the warning
message.
---
 daemons/lvmdbusd/cmdhandler.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 560b389..391757d 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -110,7 +110,7 @@ def call_lvm(command, debug=False):
 		_debug_c(command, process.returncode, (stdout_text, stderr_text))
 
 	if process.returncode == 0:
-		if cfg.DEBUG and out[1] and len(out[1]):
+		if cfg.DEBUG and out[1] and len(out[1]) and 'help' not in command:
 			log_error('WARNING: lvm is out-putting text to STDERR on success!')
 			_debug_c(command, process.returncode, (stdout_text, stderr_text))
 


