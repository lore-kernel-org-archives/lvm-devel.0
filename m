From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 29 Aug 2016 23:07:07 +0000 (UTC)
Subject: master - lvmdbusd: Prefix tag string with '@'
Message-ID: <20160829230707.756E460DE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7412690dd2ca55d0a790ba50a3425565758130ce
Commit:        7412690dd2ca55d0a790ba50a3425565758130ce
Parent:        257ce5733e386dbf3b270ca0efffe744f8d888c5
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Aug 29 18:00:21 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Aug 29 18:00:21 2016 -0500

lvmdbusd: Prefix tag string with '@'

---
 daemons/lvmdbusd/cmdhandler.py |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 2739497..c8c7baa 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -235,10 +235,7 @@ def pv_remove(device, remove_options):
 
 
 def _qt(tag_name):
-	# When running in lvm shell you need to quote the tags
-	if cfg.SHELL_IN_USE:
-		return '"%s"' % tag_name
-	return tag_name
+	return '@%s' % tag_name
 
 
 def _tag(operation, what, add, rm, tag_options):


