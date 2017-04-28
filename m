From: David Teigland <teigland@sourceware.org>
Date: Fri, 28 Apr 2017 10:07:02 -0400
Subject: master - WHATS_NEW: pvcreate prompt
Message-ID: <201704281407.v3SE72Yx030124@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c73b9f062c8ed59dc0bfa859cab4a692295a56cb
Commit:        c73b9f062c8ed59dc0bfa859cab4a692295a56cb
Parent:        1764524b063b226aa715d17a22ed271add514538
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 28 09:06:41 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 28 09:06:41 2017 -0500

WHATS_NEW: pvcreate prompt

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6ec5df1..2db7dc4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.171 - 
 ==================================
+  Add pvcreate prompt when device size doesn't match setphysicalvolumesize.
   lvconvert - preserve region size on raid1 image count changes
   Adjust pvresize/pvcreate messages and prompt if underlying dev size differs.
   raid - sanely handle insufficient space on takeover.


