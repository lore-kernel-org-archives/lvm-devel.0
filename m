From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 27 Jun 2016 16:11:07 +0000 (UTC)
Subject: master - WHATS_NEW: add recent changes
Message-ID: <20160627161107.C9AE56078D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8eebb4bfb901caa5330676697557943fdb9733a5
Commit:        8eebb4bfb901caa5330676697557943fdb9733a5
Parent:        20f22a8bc0fa84d9abd09f580b93d53d37c4c361
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 27 11:10:58 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 27 11:10:58 2016 -0500

WHATS_NEW: add recent changes

---
 WHATS_NEW |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7238568..7a1f3cb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,11 @@
 Version 2.02.158 - 
 =================================
+  Add a more efficient native vgimportclone command to replace the script.
+  Make lvmlockd always attempt to connect to lvmetad if no connection exists.
+  Let lvmetad handle new connections after shutdown signal.
+  Disable lvmetad when vgcfgrestore begins and enable it again after.
+  Make pvscan do activation if lvmetad is configured but not running.
+  Fix rescanning the PVs for a single VG when using lvmetad.
   Pool metadata lvresize uses now same code as resize of normal volume.
   Preserve monitoring status when updating thin-pool metadata.
   Return 0 (inactive) when status cannot be queried in _lv_active().


