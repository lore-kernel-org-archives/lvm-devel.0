From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 19 Mar 2014 08:49:23 +0000 (UTC)
Subject: master - WHATS_NEW: commit 5eef269
Message-ID: <20140319084923.7845360B69@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2f279797f526494887a6163ead9e83e4823c8c94
Commit:        2f279797f526494887a6163ead9e83e4823c8c94
Parent:        000e81a999a456a6db2de1aef70a147b00fb7491
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 19 09:49:09 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 19 09:49:09 2014 +0100

WHATS_NEW: commit 5eef269

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b7040d7..f07d2a9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -16,6 +16,7 @@ Version 2.02.106 -
   Use VG read lock during 'pvscan --cache -aay' autoactivation.
   Issue a VG refresh before autoactivation only if the PV has changed/is new.
   Add flag to lvmetad protocol to indicate the PV scanned has changed/is new.
+  Also add vgname to lvmetad protocol when referencing VGs for PVs scanned.
   Add man page for lvm2-activation-generator.
   Don't print an error and accept empty value for global/thin_disabled_features.
   Update API for internal function build_dm_uuid().


