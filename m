From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 17 Jun 2021 14:17:02 +0000 (GMT)
Subject: main - lvmdbusd: Wrap json.load in try/except
Message-ID: <20210617141702.87579385040A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f7730406254f023216d0727c82d46de82c124c92
Commit:        f7730406254f023216d0727c82d46de82c124c92
Parent:        c474f174cc8b0e855f984bf211f5416b42c644a1
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Jun 14 22:04:09 2021 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jun 17 09:14:29 2021 -0500

lvmdbusd: Wrap json.load in try/except

In testing where we inject large amounts of additional output in stderr
we can occassionally get truncated stdout from lvm.  Catching and dumping
the json for debug before we re-raise the exception.  As this doesn't
happen without the error injecting wrapper around lvm, the error seems to
be with the wrapper.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 daemons/lvmdbusd/cmdhandler.py | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 91f69abcf..b88bd9896 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -627,7 +627,13 @@ def lvm_full_report_json():
 			assert(type(out) == dict)
 			return out
 		else:
-			return json.loads(out)
+			try:
+				return json.loads(out)
+			except json.decoder.JSONDecodeError as joe:
+				log_error("JSONDecodeError %s, \n JSON=\n%s\n" %
+							(str(joe), out))
+				raise joe
+
 	return None
 
 


