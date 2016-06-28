From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 28 Jun 2016 19:24:20 +0000 (UTC)
Subject: master - lvmdbusd: Add hidden in for json too
Message-ID: <20160628192420.D203C60FC2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e514284c65a7cffa24549a34612392731f6e06af
Commit:        e514284c65a7cffa24549a34612392731f6e06af
Parent:        ec45be9976a3c0633d89e0516f7947c305c61e47
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Jun 3 16:52:17 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jun 28 12:09:28 2016 -0500

lvmdbusd: Add hidden in for json too

---
 daemons/lvmdbusd/cmdhandler.py |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 46fb68c..0440dbd 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -466,6 +466,7 @@ def lvm_full_report_json():
 	lv_seg_columns = ['seg_pe_ranges', 'segtype', 'lv_uuid']
 
 	cmd = _dc('fullreport', [
+		'-a',		# Need hidden too
 		'-o', '/pv/' + ','.join(pv_columns),
 		'-o', '/vg/' + ','.join(vg_columns),
 		'-o', '/lv/' + ','.join(lv_columns),


