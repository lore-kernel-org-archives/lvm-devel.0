From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 26 Feb 2016 21:14:26 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160226211426.9FA7960ECA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=731a9c1354481524a5d8674f10f0ca57c503c655
Commit:        731a9c1354481524a5d8674f10f0ca57c503c655
Parent:        98981265963f5c2572687cc7c8b49aa7cb6f85ec
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Feb 26 21:03:30 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Feb 26 21:03:30 2016 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |   10 +++++-----
 WHATS_NEW_DM |    2 +-
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/VERSION b/VERSION
index d831047..0444a0a 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.144(2)-git (2016-02-21)
+2.02.144(2)-git (2016-02-26)
diff --git a/VERSION_DM b/VERSION_DM
index c19e2b5..52e68df 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.118-git (2016-02-21)
+1.02.118-git (2016-02-26)
diff --git a/WHATS_NEW b/WHATS_NEW
index 610ea43..e43dd29 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,14 +1,14 @@
-Version 2.02.144 - 
+Version 2.02.144 - 26th February 2016
 =====================================
   Only show (u)sed pv_attr char when PV is not (a)llocatable. (2.02.143)
   Update makefile to generate lcov output also for lvmpolld and lvmlockd.
   Fix SystemdService lvm2-lvmdbusd.service name.
   Improve support for env LVM_VG_NAME for reference VG name in lvconvert.
-  Fix regresion when lvresize accepted zero sizes (2.02.141).
+  Fix regression when lvresize accepted zero sizes. (2.02.141)
   Always warn user about PV in use even when pvremove uses --force --force.
-  Use uninitilized pool header detection in all cases.
-  Fir read error detection when checking for uninitialized thin-pool header.
-  Fix error path for internal error in lvmetad vg lookup code.
+  Use uninitialized pool header detection in all cases.
+  Fix read error detection when checking for uninitialized thin-pool header.
+  Fix error path for internal error in lvmetad VG lookup code.
 
 Version 2.02.143 - 21st February 2016
 =====================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 14793b3..2edc675 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,4 +1,4 @@
-Version 1.02.118 -
+Version 1.02.118 - 26th February 2016
 =====================================
   Fix string boundary check in _get_canonical_field_name().
   Always initialized hist struct in _stats_parse_histogram().


