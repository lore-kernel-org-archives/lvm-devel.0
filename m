From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:57:47 +0000 (GMT)
Subject: main - lvmdbusd: Remove addl. checks on --nojson
Message-ID: <20220919155747.A5BFA3858CDA@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3eb19c4b7ae0b0b862a9cf92760922e4a524600a
Commit:        3eb19c4b7ae0b0b862a9cf92760922e4a524600a
Parent:        4b4d431631ec8df90d6d5793fbfc26c6999e154c
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Aug 8 16:08:23 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:36 2022 -0500

lvmdbusd: Remove addl. checks on --nojson

We check earlier that if you specify --nojson we will exit.
---
 daemons/lvmdbusd/main.py | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 597441a9e..50b8e568f 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -132,20 +132,12 @@ def main():
 	# cmdhandler is for when we are running other code with a different main.
 	cfg.blackbox = LvmFlightRecorder(cfg.args.bb_size)
 
-	if cfg.args.use_lvm_shell and not cfg.args.use_json:
-		log_error("You cannot specify --lvmshell and --nojson")
-		sys.exit(1)
-
 	log_debug("Using lvm binary: %s" % cfg.LVM_CMD)
 
 	# We will dynamically add interfaces which support vdo if it
 	# exists.
 	cfg.vdo_support = supports_vdo()
 
-	if cfg.vdo_support and not cfg.args.use_json:
-		log_error("You cannot specify --nojson when lvm has VDO support")
-		sys.exit(1)
-
 	# List of threads that we start up
 	thread_list = []
 

