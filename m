From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 28 Apr 2017 09:35:00 -0400
Subject: master - WHATS_NEW: pvcreate --setphysicalvolumesize
Message-ID: <201704281335.v3SDZ00v026092@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1764524b063b226aa715d17a22ed271add514538
Commit:        1764524b063b226aa715d17a22ed271add514538
Parent:        86b9c23dbe4a5033eea6667c0274655e7c0c8e68
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Apr 28 14:34:26 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Apr 28 14:34:26 2017 +0100

WHATS_NEW: pvcreate --setphysicalvolumesize

---
 WHATS_NEW |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c746bac..6ec5df1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,7 +1,7 @@
 Version 2.02.171 - 
 ==================================
   lvconvert - preserve region size on raid1 image count changes
-  Adjust pvresize messages and add prompt if underlying dev size differs.
+  Adjust pvresize/pvcreate messages and prompt if underlying dev size differs.
   raid - sanely handle insufficient space on takeover.
   Fix configure --enable-notify-dbus status message.
   Change configure option name prefix from --enable-lockd to --enable-lvmlockd.


