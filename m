From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 21 Sep 2017 15:36:54 -0400
Subject: master - lvmdbusd: Ensure vg_uuid is present
Message-ID: <201709211936.v8LJasAc015553@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7a6e438df8d3e2bb83723d707048e4431016d84a
Commit:        7a6e438df8d3e2bb83723d707048e4431016d84a
Parent:        e3965d392cc1cf1b29c4fcd6f2effb925d8df550
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Sep 20 16:39:35 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Sep 21 14:35:36 2017 -0500

lvmdbusd: Ensure vg_uuid is present

In some cases we are seeing where there are no VGs, but the data returned from
lvm shows that the PVs have the following for the VG:

"vg_name":"[unknown]", "vg_uuid":""

The code was only checking for the exitence of the VG name and we called into
the function get_object_path_by_uuid_lvm_id which requires both the VG name and
the LV name to exist (asserts this) which results in the following stack trace:

Traceback (most recent call last):
  File "/home/tasleson/lvm2/daemons/lvmdbusd/utils.py", line 563, in runner
    obj._run()
  File "/home/tasleson/lvm2/daemons/lvmdbusd/utils.py", line 584, in _run
    self.rc = self.f(*self.args)
  File "/home/tasleson/lvm2/daemons/lvmdbusd/fetch.py", line 26, in
		_main_thread_load
    cache_refresh=False)[1]
  File "/home/tasleson/lvm2/daemons/lvmdbusd/pv.py", line 48, in load_pvs
    emit_signal, cache_refresh)
  File "/home/tasleson/lvm2/daemons/lvmdbusd/loader.py", line 37, in common
    objects = retrieve(search_keys, cache_refresh=False)
  File "/home/tasleson/lvm2/daemons/lvmdbusd/pv.py", line 40, in
		pvs_state_retrieve
    p["pv_attr"], p["pv_tags"], p["vg_name"], p["vg_uuid"]))
  File "/home/tasleson/lvm2/daemons/lvmdbusd/pv.py", line 84, in __init__
    vg_uuid, vg_name, vg_obj_path_generate)
  File "/home/tasleson/lvm2/daemons/lvmdbusd/objectmanager.py", line 318,
		in get_object_path_by_uuid_lvm_id
    assert uuid
AssertionError
---
 daemons/lvmdbusd/pv.py |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/pv.py b/daemons/lvmdbusd/pv.py
index fe32143..e5f8b9d 100644
--- a/daemons/lvmdbusd/pv.py
+++ b/daemons/lvmdbusd/pv.py
@@ -79,7 +79,9 @@ class PvState(State):
 
 		self.lv = self._lv_object_list(vg_name)
 
-		if vg_name:
+		# It's possible to have a vg_name and no uuid with the main example
+		# being when the vg_name == '[unknown]'
+		if vg_uuid and vg_name:
 			self.vg_path = cfg.om.get_object_path_by_uuid_lvm_id(
 				vg_uuid, vg_name, vg_obj_path_generate)
 		else:


