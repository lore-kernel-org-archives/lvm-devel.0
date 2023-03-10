From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 10 Mar 2023 18:52:27 +0000 (GMT)
Subject: main - lvmdbusd: Handle missing key in get_key
Message-ID: <20230310185227.92FB63858C1F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1949afa24b10991408cff362084cdc881f499535
Commit:        1949afa24b10991408cff362084cdc881f499535
Parent:        3d854b39bd8c3740eae087c4d46e5f685b368f5e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Mar 9 11:21:27 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Mar 10 12:51:53 2023 -0600

lvmdbusd: Handle missing key in get_key

When we sort the LVs, we can stumble on a missing key, protect against
this as well.

Seen in error injection testing:
Traceback (most recent call last):
  File "/home/tasleson/projects/lvm2/daemons/lvmdbusd/fetch.py", line 198, in update_thread
    num_changes = load(*_load_args(queued_requests))
  File "/home/tasleson/projects/lvm2/daemons/lvmdbusd/fetch.py", line 83, in load
    rc = MThreadRunner(_main_thread_load, refresh, emit_signal).done()
  File "/home/tasleson/projects/lvm2/daemons/lvmdbusd/utils.py", line 726, in done
    raise self.exception
  File "/home/tasleson/projects/lvm2/daemons/lvmdbusd/utils.py", line 732, in _run
    self.rc = self.f(*self.args)
  File "/home/tasleson/projects/lvm2/daemons/lvmdbusd/fetch.py", line 40, in _main_thread_load
    (lv_changes, remove) = load_lvs(
  File "/home/tasleson/projects/lvm2/daemons/lvmdbusd/lv.py", line 148, in load_lvs
    return common(
  File "/home/tasleson/projects/lvm2/daemons/lvmdbusd/loader.py", line 37, in common
    objects = retrieve(search_keys, cache_refresh=False)
  File "/home/tasleson/projects/lvm2/daemons/lvmdbusd/lv.py", line 72, in lvs_state_retrieve
    lvs = sorted(cfg.db.fetch_lvs(selection), key=get_key)
  File "/home/tasleson/projects/lvm2/daemons/lvmdbusd/lv.py", line 35, in get_key
    pool = i['pool_lv']
KeyError: 'pool_lv'
---
 daemons/lvmdbusd/lv.py | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 6a4161ad8..caee23379 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -65,13 +65,13 @@ def lvs_state_retrieve(selection, cache_refresh=True):
 	if cache_refresh:
 		cfg.db.refresh()
 
-	# When building up the model, it's best to process LVs with the least
-	# dependencies to those that are dependant upon other LVs.  Otherwise, when
-	# we are trying to gather information we could be in a position where we
-	# don't have information available yet.
-	lvs = sorted(cfg.db.fetch_lvs(selection), key=get_key)
-
 	try:
+		# When building up the model, it's best to process LVs with the least
+		# dependencies to those that are dependant upon other LVs.  Otherwise, when
+		# we are trying to gather information we could be in a position where we
+		# don't have information available yet.
+		lvs = sorted(cfg.db.fetch_lvs(selection), key=get_key)
+
 		for l in lvs:
 			if cfg.vdo_support:
 				rc.append(LvStateVdo(

