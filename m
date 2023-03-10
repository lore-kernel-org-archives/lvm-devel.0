From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 10 Mar 2023 18:52:26 +0000 (GMT)
Subject: main - lvmdbusd: Replace assert with exception
Message-ID: <20230310185226.7229D385840A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3d854b39bd8c3740eae087c4d46e5f685b368f5e
Commit:        3d854b39bd8c3740eae087c4d46e5f685b368f5e
Parent:        e79c6feb080f30fc4bb4adbfd69c41ac90b6cde3
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Mar 9 11:19:29 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Mar 10 12:51:53 2023 -0600

lvmdbusd: Replace assert with exception

Instead of using an assert we will raise an LvmBug exception
---
 daemons/lvmdbusd/cmdhandler.py | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 8bc741dc6..cf2a70875 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -637,7 +637,9 @@ def lvm_full_report_json():
 	rc, out, err = call(cmd)
 	# When we have an exported vg the exit code of lvs or fullreport will be 5
 	if rc == 0 or rc == 5:
-		assert(type(out) == dict)
+		if type(out) != dict:
+			raise LvmBug("lvm likely returned invalid JSON, lvm exit code = %d, output = %s, err= %s" %
+						 (rc, str(out), str(err)))
 		return out
 	raise LvmBug("'fullreport' exited with code '%d'" % rc)
 

