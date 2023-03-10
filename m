From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 10 Mar 2023 18:52:31 +0000 (GMT)
Subject: main - lvmdbustest: Only inject 1 missing key error
Message-ID: <20230310185231.017713858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9714f3ec4f3d4526a33781baf706c24930b6f26c
Commit:        9714f3ec4f3d4526a33781baf706c24930b6f26c
Parent:        2359023009db40112f4220899f0983684d897765
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Mar 9 11:25:58 2023 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Mar 10 12:51:53 2023 -0600

lvmdbustest: Only inject 1 missing key error

Previously we were injecting a missing key in the lv, vg, and pv.
Given the order of processing in lvmdbusd, this prevented us from
exercising all the error paths.  Change to returning just 1 instead.
---
 test/dbus/lvm_error_inject.py | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/test/dbus/lvm_error_inject.py b/test/dbus/lvm_error_inject.py
index d87286740..98520845c 100755
--- a/test/dbus/lvm_error_inject.py
+++ b/test/dbus/lvm_error_inject.py
@@ -79,6 +79,7 @@ def write_some(q, stream, remaining=False, binary=False):
 def del_random_key(src_dict):
     keys = list(src_dict.keys())
     pick = random.randint(0, len(keys) - 1)
+    debug("%s will be deleted" % keys[pick])
     del src_dict[keys[pick]]
 
 
@@ -87,16 +88,19 @@ def inject_key_error(output_json):
     for r in output_json['report']:
         if 'lv' in r:
             for i in r['lv']:
+                debug("deleting a lv key")
                 del_random_key(i)
-                break
+                return
         if 'vg' in r:
             for i in r["vg"]:
+                debug("deleting a vg key")
                 del_random_key(i)
-                break
+                return
         elif 'pv' in r:
             for i in r["pv"]:
+                debug("deleting a pv key")
                 del_random_key(i)
-                break
+                return
 
 
 def inject_exit_error(output_json, val):

