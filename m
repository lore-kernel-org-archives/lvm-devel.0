From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 19 Nov 2012 22:31:53 +0000 (UTC)
Subject: master - docs: host tags has a default volume_list
Message-ID: <20121119223154.0120A22CD@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5ef6ca00b99e0a2ed83a00c4ddcb577dd3b52a7b
Commit:        5ef6ca00b99e0a2ed83a00c4ddcb577dd3b52a7b
Parent:        999952c5b9a21451d1b76c53a7dca615cd815113
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Nov 19 22:29:23 2012 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Nov 19 22:29:23 2012 +0000

docs: host tags has a default volume_list

Document that lvm.conf activation/volume_list defaults to @* when
there's a host tag.
---
 doc/example.conf.in |   11 +++++++++--
 man/lvm.conf.5.in   |    2 ++
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index f7344bb..7f94223 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -569,15 +569,21 @@ activation {
 
     # If volume_list is defined, each LV is only activated if there is a
     # match against the list.
+    #
     #   "vgname" and "vgname/lvname" are matched exactly.
     #   "@tag" matches any tag set in the LV or VG.
     #   "@*" matches if any tag defined on the host is also set in the LV or VG
     #
+    # If any host tags exist but volume_list is not defined, a default
+    # single-entry list containing "@*" is assumed.
+    #
     # volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
 
     # If auto_activation_volume_list is defined, each LV that is to be
-    # activated is checked against the list while using the autoactivation
-    # option (--activate ay/-a ay), and if it matches, it is activated.
+    # activated with the autoactivation option (--activate ay/-a ay)
+    # is first checked against the list.  If it does not match, the LV
+    # is not activated.  This list is checked as well as volume_list.
+    #
     #   "vgname" and "vgname/lvname" are matched exactly.
     #   "@tag" matches any tag set in the LV or VG.
     #   "@*" matches if any tag defined on the host is also set in the LV or VG
@@ -588,6 +594,7 @@ activation {
     # is checked against the list, and if it matches, it as activated
     # in read-only mode.  (This overrides '--permission rw' stored in the
     # metadata.)
+    #
     #   "vgname" and "vgname/lvname" are matched exactly.
     #   "@tag" matches any tag set in the LV or VG.
     #   "@*" matches if any tag defined on the host is also set in the LV or VG
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 718cf4d..5592f34 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -447,6 +447,8 @@ metadata for a match.
 \fBtags\fP above).
 Logical volume and volume groups can also be included in the list
 by name e.g. vg00, vg00/lvol1.
+If this setting is not present but at least one host tag is defined
+then a default single-entry list containing @* is assumed.
 .IP
 \fBauto_activation_volume_list\fP \(em This acts as a filter through
 which all requests to autoactivate a logical volume on this machine


