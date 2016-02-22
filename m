From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 22 Feb 2016 22:11:04 +0000 (UTC)
Subject: master - lvmdbusd: Remove unlimited retries
Message-ID: <20160222221104.C3C1960AA1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ecc040688601ec0f4b35f4250e057db13fd847a0
Commit:        ecc040688601ec0f4b35f4250e057db13fd847a0
Parent:        21034644b6582a6d9ad571ff51cc57ad5e08b9ff
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Feb 22 15:53:31 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Feb 22 16:07:54 2016 -0600

lvmdbusd: Remove unlimited retries

Change while to for loop to prevent the daemon from getting stuck
when lvm is messed up.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 daemons/lvmdbusd/cmdhandler.py |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 83feb0a..370fb61 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -388,6 +388,9 @@ def lv_detach_cache(lv_full_name, detach_options, destroy_cache):
 
 def pv_retrieve_with_segs(device=None):
 	d = []
+	err = ""
+	out = ""
+	rc = 0
 
 	columns = ['pv_name', 'pv_uuid', 'pv_fmt', 'pv_size', 'pv_free',
 				'pv_used', 'dev_size', 'pv_mda_size', 'pv_mda_free',
@@ -398,7 +401,7 @@ def pv_retrieve_with_segs(device=None):
 	# Lvm has some issues where it returns failure when querying pvs when other
 	# operations are in process, see:
 	# https://bugzilla.redhat.com/show_bug.cgi?id=1274085
-	while True:
+	for i in range(0, 10):
 		cmd = _dc('pvs', ['-o', ','.join(columns)])
 
 		if device:
@@ -413,6 +416,13 @@ def pv_retrieve_with_segs(device=None):
 			time.sleep(0.2)
 			log_debug("LVM Bug workaround, retrying pvs command...")
 
+	if rc != 0:
+		msg = "We were unable to get pvs to return without error after " \
+			"trying 10 times, RC=%d, STDERR=(%s), STDOUT=(%s)" % \
+			(rc, err, out)
+		log_error(msg)
+		raise RuntimeError(msg)
+
 	return d
 
 


