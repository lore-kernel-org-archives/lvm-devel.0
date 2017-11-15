From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 15 Nov 2017 04:04:39 -0500
Subject: master - Update WHATS_NEW
Message-ID: <201711150904.vAF94drI032293@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7c5531b4ca2bb261a7a37fd1c895963afb9d80e8
Commit:        7c5531b4ca2bb261a7a37fd1c895963afb9d80e8
Parent:        fe63c09381103324c52cc380a80cef21b693e9db
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Nov 15 10:01:50 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Nov 15 10:01:50 2017 +0100

Update WHATS_NEW

---
 WHATS_NEW |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7db534c..d3670bc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -6,6 +6,11 @@ Version 2.02.177 -
   Fix memleak of string buffer when vgcfgbackup runs in secure mode.
   Do not print error when clvmd cannot find running clvmd.
   Prevent start of new merge of snapshot if origin is already being merged.
+  Fix offered type for raid6_n_6 to raid5 conversion (raid5_n).
+  Deactivate sub LVs when removing unused cache-pool.
+  Do not take backup with suspended devices.
+  Avoid RAID4 activation on incompatible kernels under all circumstances.
+  Reject conversion request to striped/raid0 on 2-legged raid4/5.
 
 Version 2.02.176 - 3rd November 2017
 ====================================


