From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 28 Jun 2016 19:24:22 +0000 (UTC)
Subject: master - lvmdbusd: Remove sorting in db layer
Message-ID: <20160628192422.F062660FC2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b337b20d47953e130edc8a456e9431eba58a778
Commit:        4b337b20d47953e130edc8a456e9431eba58a778
Parent:        e514284c65a7cffa24549a34612392731f6e06af
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Jun 6 15:08:20 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Jun 28 12:09:28 2016 -0500

lvmdbusd: Remove sorting in db layer

When using the JSON this does not yield a totally sorted list as we don't
have a complete set of LVs, so remove this sort.
---
 daemons/lvmdbusd/lvmdb.py |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/daemons/lvmdbusd/lvmdb.py b/daemons/lvmdbusd/lvmdb.py
index 5ac90e3..f070bb6 100755
--- a/daemons/lvmdbusd/lvmdb.py
+++ b/daemons/lvmdbusd/lvmdb.py
@@ -245,16 +245,10 @@ class DataStore(object):
 		# Each item item in the report is a collection of information pertaining
 		# to the vg
 		for r in _all['report']:
-			tmp_lv = []
 			# Get the lv data for this VG.
 			if 'lv' in r:
-				tmp_lv.extend(r['lv'])
-
-				# Sort them
-				sorted_tmp_lv = sorted(tmp_lv, key=lambda vk: vk['lv_name'])
-
 				# Add them to result set
-				for i in sorted_tmp_lv:
+				for i in r['lv']:
 					full_name = "%s/%s" % (i['vg_name'], i['lv_name'])
 					c_lv_full_lookup[full_name] = i['lv_uuid']
 					c_lvs[i['lv_uuid']] = i


