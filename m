From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 11 Oct 2016 18:18:47 +0000 (UTC)
Subject: master - lvmdbusd: Remove log ouput when ec=0 & stderr != 0 bytes
Message-ID: <20161011181847.659B660DFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4fab8339207fd8846e04e775897a7ba7a3cd074c
Commit:        4fab8339207fd8846e04e775897a7ba7a3cd074c
Parent:        2830f722882d064a6ffbe143f5a580364bcba2e6
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Oct 11 09:42:18 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Oct 11 13:16:57 2016 -0500

lvmdbusd: Remove log ouput when ec=0 & stderr != 0 bytes

lvm likes to log to stderr virtually all the time, this isn't
helpful.
---
 daemons/lvmdbusd/cmdhandler.py |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 4bdbee5..fa34a7a 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -108,12 +108,6 @@ def call_lvm(command, debug=False):
 	if debug or process.returncode != 0:
 		_debug_c(command, process.returncode, (stdout_text, stderr_text))
 
-	if process.returncode == 0:
-		if cfg.args and cfg.args.debug and out[1] and len(out[1]) and \
-				'help' not in command:
-			log_error('WARNING: lvm is out-putting text to STDERR on success!')
-			_debug_c(command, process.returncode, (stdout_text, stderr_text))
-
 	return process.returncode, stdout_text, stderr_text
 
 # The actual method which gets called to invoke the lvm command, can vary


