From: tasleson <tasleson@fedoraproject.org>
Date: Fri, 10 Jun 2016 21:06:27 +0000 (UTC)
Subject: master - lvmdbusd: Bug fix for missing LV properties
Message-ID: <20160610210627.556DD60E3F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b717c5efae942c845f07d695593cfb2406627fe9
Commit:        b717c5efae942c845f07d695593cfb2406627fe9
Parent:        e04705b305626d37cbd076b47d6ad37c9b1b282e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Jun 10 11:58:55 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Jun 10 15:28:42 2016 -0500

lvmdbusd: Bug fix for missing LV properties

When we are processing the LVs we need to build up dbus objects from least
dependent to most dependent, so that we have information available when
constructing.
---
 daemons/lvmdbusd/lv.py |   41 ++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 40 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 61cf7d3..2786f68 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -24,6 +24,39 @@ from . import background
 from .utils import round_size
 
 
+# Try and build a key for a LV, so that we sort the LVs with least dependencies
+# first.  This may be error prone because of the flexibility LVM
+# provides and what you can stack.
+def get_key(i):
+
+	name = i['lv_name']
+	parent = i['lv_parent']
+	pool = i['pool_lv']
+	a1 = ""
+	a2 = ""
+
+	if name[0] == '[':
+		a1 = '#'
+
+	# We have a parent
+	if parent:
+		# Check if parent is hidden
+		if parent[0] == '[':
+			a2 = '##'
+		else:
+			a2 = '#'
+
+	# If a LV has a pool, then it should be sorted/loaded after the pool
+	# lv, unless it's a hidden too, then after other hidden, but before visible
+	if pool:
+		if pool[0] != '[':
+			a2 += '~'
+		else:
+			a1 = '$' + a1
+
+	return "%s%s%s" % (a1, a2, name)
+
+
 # noinspection PyUnusedLocal
 def lvs_state_retrieve(selection, cache_refresh=True):
 	rc = []
@@ -31,7 +64,13 @@ def lvs_state_retrieve(selection, cache_refresh=True):
 	if cache_refresh:
 		cfg.db.refresh()
 
-	for l in cfg.db.fetch_lvs(selection):
+	# When building up the model, it's best to process LVs with the least
+	# dependencies to those that are dependant upon other LVs.  Otherwise, when
+	# we are trying to gather information we could be in a position where we
+	# don't have information available yet.
+	lvs = sorted(cfg.db.fetch_lvs(selection), key=get_key)
+
+	for l in lvs:
 		rc.append(LvState(
 			l['lv_uuid'], l['lv_name'],
 			l['lv_path'], n(l['lv_size']),


