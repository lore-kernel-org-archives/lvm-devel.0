From: tasleson <tasleson@fedoraproject.org>
Date: Wed, 30 Nov 2016 22:48:43 +0000 (UTC)
Subject: master - lvmdbusd: Only allow 0..N for --blackboxsize argument
Message-ID: <20161130224843.6281E607A1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c9848bb7eaa73c9ac92c47062981f0111d30204a
Commit:        c9848bb7eaa73c9ac92c47062981f0111d30204a
Parent:        c0a508cfab66049e3953c7cf14c159170a585088
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Nov 30 16:45:50 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Nov 30 16:47:39 2016 -0600

lvmdbusd: Only allow 0..N for --blackboxsize argument

---
 daemons/lvmdbusd/main.py |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 9bf0871..17e2175 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -54,6 +54,14 @@ def process_request():
 			utils.log_error("process_request exception: \n%s" % st)
 
 
+def check_bb_size(value):
+	v = int(value)
+	if v < 0:
+		raise argparse.ArgumentTypeError(
+			"positive integers only ('%s' invalid)" % value)
+	return v
+
+
 def main():
 	start = time.time()
 	# Add simple command line handling
@@ -80,7 +88,7 @@ def main():
 		"--blackboxsize",
 		help="Size of the black box flight recorder, 0 to disable",
 		default=10,
-		type=int,
+		type=check_bb_size,
 		dest='bb_size')
 
 	use_session = os.getenv('LVMDBUSD_USE_SESSION', False)


