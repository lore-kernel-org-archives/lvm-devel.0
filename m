From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  8 Jan 2016 15:54:34 +0000 (UTC)
Subject: master - document commits since last release
Message-ID: <20160108155434.984D660DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=580c67486fde1a382910b5694589536642346d22
Commit:        580c67486fde1a382910b5694589536642346d22
Parent:        8d11468ab20f5aec25eabab214ca9d3107e9685b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jan 8 09:53:58 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jan 8 09:53:58 2016 -0600

document commits since last release

---
 WHATS_NEW |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 137ad18..515f6ce 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.02.139 - 
 =====================================
+  Update lvmlockd with the new VG seqno before devices are suspended.
+  Rework vgrename to use the common processing code in toollib.
+  Make pvs show new devices on the system since the last .cache update.
   Document F,D and M thin pool health status chars for lv_attr in lvs man page.
   Also add lvm2-activation{-early,-net}.service systemd status for lvmdump -s.
 


