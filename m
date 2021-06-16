From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 16 Jun 2021 17:19:55 +0000 (GMT)
Subject: main - lvmdbusd: Defer dbus object removal
Message-ID: <20210616171955.3A7BE3986814@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f70d97b91620bc7c2e5c5ccc39913c54379322c2
Commit:        f70d97b91620bc7c2e5c5ccc39913c54379322c2
Parent:        e8f3a63000e692b00070b337e475fd4a38e1f1c9
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Jun 10 13:38:38 2021 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Jun 16 12:19:02 2021 -0500

lvmdbusd: Defer dbus object removal

When we are walking the new lvm state comparing it to the old state we can
run into an issue where we remove a VG that is no longer present from the
object manager, but is still needed by LVs that are left to be processed.
When we try to process existing LVs to see if their state needs to be
updated, or if they need to be removed, we need to be able to reference the
VG that was associated with it.  However, if it's been removed from the
object manager we fail to find it which results in:

Traceback (most recent call last):
File "/usr/lib/python3.6/site-packages/lvmdbusd/utils.py", line 666, in _run
  self.rc = self.f(*self.args)
File "/usr/lib/python3.6/site-packages/lvmdbusd/fetch.py", line 36, in _main_thread_load
  cache_refresh=False)[1]
File "/usr/lib/python3.6/site-packages/lvmdbusd/lv.py", line 146, in load_lvs
  lv_name, object_path, refresh, emit_signal, cache_refresh)
File "/usr/lib/python3.6/site-packages/lvmdbusd/loader.py", line 68, in common
  num_changes += dbus_object.refresh(object_state=o)
File "/usr/lib/python3.6/site-packages/lvmdbusd/automatedproperties.py", line 160, in refresh
  search = self.lvm_id
File "/usr/lib/python3.6/site-packages/lvmdbusd/lv.py", line 483, in lvm_id
  return self.state.lvm_id
File "/usr/lib/python3.6/site-packages/lvmdbusd/lv.py", line 173, in lvm_id
  return "%s/%s" % (self.vg_name_lookup(), self.Name)
File "/usr/lib/python3.6/site-packages/lvmdbusd/lv.py", line 169, in vg_name_lookup
  return cfg.om.get_object_by_path(self.Vg).Name

Instead of removing objects from the object manager immediately, we will
keep them in a list and remove them once we have processed all of the state.

Ref:
https://bugzilla.redhat.com/show_bug.cgi?id=1968752
---
 daemons/lvmdbusd/fetch.py  | 37 +++++++++++++++++++++++++++++--------
 daemons/lvmdbusd/loader.py |  7 +++----
 2 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/daemons/lvmdbusd/fetch.py b/daemons/lvmdbusd/fetch.py
index b7eb8c83a..c17827b5a 100644
--- a/daemons/lvmdbusd/fetch.py
+++ b/daemons/lvmdbusd/fetch.py
@@ -20,22 +20,30 @@ import traceback
 
 def _main_thread_load(refresh=True, emit_signal=True):
 	num_total_changes = 0
+	to_remove = []
 
-	num_total_changes += load_pvs(
+	(changes, remove) = load_pvs(
 		refresh=refresh,
 		emit_signal=emit_signal,
-		cache_refresh=False)[1]
-	num_total_changes += load_vgs(
+		cache_refresh=False)[1:]
+	num_total_changes += changes
+	to_remove.extend(remove)
+
+	(changes, remove) = load_vgs(
 		refresh=refresh,
 		emit_signal=emit_signal,
-		cache_refresh=False)[1]
+		cache_refresh=False)[1:]
+
+	num_total_changes += changes
+	to_remove.extend(remove)
 
-	lv_changes = load_lvs(
+	(lv_changes, remove) = load_lvs(
 		refresh=refresh,
 		emit_signal=emit_signal,
-		cache_refresh=False)[1]
+		cache_refresh=False)[1:]
 
 	num_total_changes += lv_changes
+	to_remove.extend(remove)
 
 	# When the LVs change it can cause another change in the VGs which is
 	# missed if we don't scan through the VGs again.  We could achieve this
@@ -44,10 +52,23 @@ def _main_thread_load(refresh=True, emit_signal=True):
 	# changes causing the dbus object representing it to be removed and
 	# recreated.
 	if refresh and lv_changes > 0:
-		num_total_changes += load_vgs(
+		(changes, remove) = load_vgs(
 			refresh=refresh,
 			emit_signal=emit_signal,
-			cache_refresh=False)[1]
+			cache_refresh=False)[1:]
+
+	num_total_changes += changes
+	to_remove.extend(remove)
+
+	# Remove any objects that are no longer needed.  We do this after we process
+	# all the objects to ensure that references still exist for objects that
+	# are processed after them.
+	to_remove.reverse()
+	for i in to_remove:
+		dbus_obj = cfg.om.get_object_by_path(i)
+		if dbus_obj:
+			cfg.om.remove_object(dbus_obj, True)
+			num_total_changes += 1
 
 	return num_total_changes
 
diff --git a/daemons/lvmdbusd/loader.py b/daemons/lvmdbusd/loader.py
index f0462ef2d..101502add 100644
--- a/daemons/lvmdbusd/loader.py
+++ b/daemons/lvmdbusd/loader.py
@@ -75,11 +75,10 @@ def common(retrieve, o_type, search_keys,
 
 		object_path = None
 
+	to_remove = []
 	if refresh:
-		for k in list(existing_paths.keys()):
-			cfg.om.remove_object(cfg.om.get_object_by_path(k), True)
-			num_changes += 1
+		to_remove = list(existing_paths.keys())
 
 	num_changes += len(rc)
 
-	return rc, num_changes
+	return rc, num_changes, to_remove


