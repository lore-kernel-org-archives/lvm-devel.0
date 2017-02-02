From: tasleson <tasleson@fedoraproject.org>
Date: Thu,  2 Feb 2017 16:59:25 +0000 (UTC)
Subject: master - lvmdbusd: lvmdb.py, remove duplicate code
Message-ID: <20170202165925.0180F6024A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=945842fa680d6c967b64362fe8b2ce6c3334a52d
Commit:        945842fa680d6c967b64362fe8b2ce6c3334a52d
Parent:        681d69c70ae70dffa9d21bfd82e1e9821371ee82
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Feb 1 18:56:39 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Feb 1 18:56:39 2017 -0600

lvmdbusd: lvmdb.py, remove duplicate code

Move similar code to common functions, less is more!
---
 daemons/lvmdbusd/lvmdb.py |   39 ++++++++++++++++-----------------------
 1 files changed, 16 insertions(+), 23 deletions(-)

diff --git a/daemons/lvmdbusd/lvmdb.py b/daemons/lvmdbusd/lvmdb.py
index 9529e03..974e7d7 100755
--- a/daemons/lvmdbusd/lvmdb.py
+++ b/daemons/lvmdbusd/lvmdb.py
@@ -69,18 +69,7 @@ class DataStore(object):
 			table[key] = record
 
 	@staticmethod
-	def _parse_pvs(_pvs):
-		pvs = sorted(_pvs, key=lambda pk: pk['pv_name'])
-
-		c_pvs = OrderedDict()
-		c_lookup = {}
-		c_pvs_in_vgs = {}
-
-		for p in pvs:
-			DataStore._insert_record(
-				c_pvs, p['pv_uuid'], p,
-				['pvseg_start', 'pvseg_size', 'segtype'])
-
+	def _pvs_parse_common(c_pvs, c_pvs_in_vgs, c_lookup):
 		for p in c_pvs.values():
 			# Capture which PVs are associated with which VG
 			if p['vg_uuid'] not in c_pvs_in_vgs:
@@ -93,6 +82,20 @@ class DataStore(object):
 			# Lookup for translating between /dev/<name> and pv uuid
 			c_lookup[p['pv_name']] = p['pv_uuid']
 
+	@staticmethod
+	def _parse_pvs(_pvs):
+		pvs = sorted(_pvs, key=lambda pk: pk['pv_name'])
+
+		c_pvs = OrderedDict()
+		c_lookup = {}
+		c_pvs_in_vgs = {}
+
+		for p in pvs:
+			DataStore._insert_record(
+				c_pvs, p['pv_uuid'], p,
+				['pvseg_start', 'pvseg_size', 'segtype'])
+
+		DataStore._pvs_parse_common(c_pvs, c_pvs_in_vgs, c_lookup)
 		return c_pvs, c_lookup, c_pvs_in_vgs
 
 	@staticmethod
@@ -132,17 +135,7 @@ class DataStore(object):
 						i['pvseg_size'] = i['pv_pe_count']
 						i['segtype'] = 'free'
 
-		for p in c_pvs.values():
-			# Capture which PVs are associated with which VG
-			if p['vg_uuid'] not in c_pvs_in_vgs:
-				c_pvs_in_vgs[p['vg_uuid']] = []
-
-			if p['vg_name']:
-				c_pvs_in_vgs[p['vg_uuid']].append(
-					(p['pv_name'], p['pv_uuid']))
-
-			# Lookup for translating between /dev/<name> and pv uuid
-			c_lookup[p['pv_name']] = p['pv_uuid']
+		DataStore._pvs_parse_common(c_pvs, c_pvs_in_vgs, c_lookup)
 
 		return c_pvs, c_lookup, c_pvs_in_vgs
 


