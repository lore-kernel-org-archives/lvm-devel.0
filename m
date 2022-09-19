From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:47 +0000 (GMT)
Subject: main - lvmdbusd: Remove --reportformat
Message-ID: <20220919155847.DF98E385829F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=868665766491d9d42b8acedaf07cafc7118d165c
Commit:        868665766491d9d42b8acedaf07cafc7118d165c
Parent:        3d3c517b0b4206adec9673b52ad931a64805af13
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Sep 14 13:11:47 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Remove --reportformat

Latest upstream build of lvm results in the following error when
trying to use lvmshell.

"Argument --reportformat cannot be used in interactive mode.,
Error during parsing of command line."
---
 daemons/lvmdbusd/cmdhandler.py | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 0e344d3ca..0c7bd8528 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -608,8 +608,7 @@ def lvm_full_report_json():
 		'--configreport', 'vg', '-o', ','.join(vg_columns),
 		'--configreport', 'lv', '-o', ','.join(lv_columns),
 		'--configreport', 'seg', '-o', ','.join(lv_seg_columns),
-		'--configreport', 'pvseg', '-o', ','.join(pv_seg_columns),
-		'--reportformat', 'json'
+		'--configreport', 'pvseg', '-o', ','.join(pv_seg_columns)
 	])
 
 	# We are running the fullreport command, we will ask lvm to output the debug

