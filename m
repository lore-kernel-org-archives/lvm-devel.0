From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:25 +0000 (GMT)
Subject: main - lvmdbusd: Don't output debug for fullreport exit code 5
Message-ID: <20220919155825.26D763858283@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=22942f49162bca9e99172d64dfd03e7a881ce5b2
Commit:        22942f49162bca9e99172d64dfd03e7a881ce5b2
Parent:        f5876a1f3fb729d255ea0bc3974d2891381620b3
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Aug 31 11:05:36 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Don't output debug for fullreport exit code 5

This is expected with an exported vg
---
 daemons/lvmdbusd/cmdhandler.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 23104e93e..d5dceb64e 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -164,7 +164,7 @@ def call_lvm(command, debug=False, line_cb=None,
 			break
 
 	if process.returncode is not None:
-		if debug or process.returncode != 0:
+		if debug or (process.returncode != 0 and (process.returncode != 5 and "fullreport" in command)):
 			_debug_c(command, process.returncode, (stdout_text, stderr_text))
 
 		return process.returncode, stdout_text, stderr_text

