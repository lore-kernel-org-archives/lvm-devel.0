From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 28 Jun 2016 01:33:24 +0000 (UTC)
Subject: master - WHATS_NEW: add recent changes
Message-ID: <20160628013324.47D3360237@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5a327755b4cfe45b35863a2b4177a6b32c17642f
Commit:        5a327755b4cfe45b35863a2b4177a6b32c17642f
Parent:        17ad29ebba4ba1a9361cd424ad1f58e89418a986
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 27 11:10:58 2016 -0500
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jun 28 02:28:57 2016 +0100

WHATS_NEW: add recent changes

---
 WHATS_NEW |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4b074a6..cfa707f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -3,6 +3,12 @@ Version 2.02.159 -
 
 Version 2.02.158 - 25th June 2016
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


