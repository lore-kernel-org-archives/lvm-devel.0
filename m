From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 28 Jun 2016 19:24:25 +0000 (UTC)
Subject: master - lvmdbusd: Correct command line args for JSON
Message-ID: <20160628192425.1910860FC2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0aadd6b0fb4eaa9e59d6f750f2efe2fdfdacdd8f
Commit:        0aadd6b0fb4eaa9e59d6f750f2efe2fdfdacdd8f
Parent:        4b337b20d47953e130edc8a456e9431eba58a778
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Jun 27 17:04:44 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jun 28 12:09:28 2016 -0500

lvmdbusd: Correct command line args for JSON

Use the updated syntax.
---
 daemons/lvmdbusd/cmdhandler.py |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 0440dbd..2ca23e7 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -467,11 +467,11 @@ def lvm_full_report_json():
 
 	cmd = _dc('fullreport', [
 		'-a',		# Need hidden too
-		'-o', '/pv/' + ','.join(pv_columns),
-		'-o', '/vg/' + ','.join(vg_columns),
-		'-o', '/lv/' + ','.join(lv_columns),
-		'-o', '/seg/' + ','.join(lv_seg_columns),
-		'-o', '/pvseg/' + ','.join(pv_seg_columns),
+		'--configreport', 'pv', '-o', ','.join(pv_columns),
+		'--configreport', 'vg', '-o', ','.join(vg_columns),
+		'--configreport', 'lv', '-o', ','.join(lv_columns),
+		'--configreport', 'seg', '-o', ','.join(lv_seg_columns),
+		'--configreport', 'pvseg', '-o', ','.join(pv_seg_columns),
 		'--reportformat', 'json'
 	])
 


