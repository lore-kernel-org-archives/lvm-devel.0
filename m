From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 15 Apr 2014 08:15:53 +0000 (UTC)
Subject: master - profiles: comment out thin_pool_chunk_size in default.profile
Message-ID: <20140415081553.ED59D60D8A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=704609b17ee5c67fec65400ba48841aff70c6d21
Commit:        704609b17ee5c67fec65400ba48841aff70c6d21
Parent:        898059251442a89fc039cd49486771b6816df475
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Apr 15 10:09:18 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Apr 15 10:15:38 2014 +0200

profiles: comment out thin_pool_chunk_size in default.profile

By default, the thin_pool_chunk_size is automatically calculated.
When defined, it disables the automatic calculation. So to be more
precise here, we should comment it out for the default.profile.

Also, "lvm dumpconfig --type profilable" was used here to generate
the default.profile content. This will be done automatically in the
future once we have the infrastructure for this in (see also
https://bugzilla.redhat.com/show_bug.cgi?id=1073415).
---
 conf/default.profile.in |   19 ++++++++-----------
 1 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/conf/default.profile.in b/conf/default.profile.in
index 527edb2..cc0279b 100644
--- a/conf/default.profile.in
+++ b/conf/default.profile.in
@@ -9,24 +9,21 @@
 # Refer to 'man lvm.conf' for further information about profiles and file layout.
 
 allocation {
-	thin_pool_chunk_size_policy = "generic"
-	thin_pool_chunk_size = 64
-	thin_pool_discards = "passdown"
-	thin_pool_zero = 1
+	thin_pool_zero=1
+	thin_pool_discards="passdown"
+	thin_pool_chunk_size_policy="generic"
+#	thin_pool_chunk_size=64
 }
-
-activation {
-	thin_pool_autoextend_threshold = 100
-	thin_pool_autoextend_percent = 20
-}
-
 global {
 	units="h"
 	si_unit_consistency=1
 	suffix=1
 	lvdisplay_shows_full_device_path=0
 }
-
+activation {
+	thin_pool_autoextend_threshold=100
+	thin_pool_autoextend_percent=20
+}
 report {
 	aligned=1
 	buffered=1


