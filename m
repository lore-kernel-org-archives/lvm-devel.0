From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 5 Mar 2020 11:39:37 -0500
Subject: master - WHATS_NEW_DM: update
Message-ID: <202003051639.025GdbBk023925@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c9526e859eba5a406e49853d59041a3497154fa8
Commit:        c9526e859eba5a406e49853d59041a3497154fa8
Parent:        f439716b7583556352f1b7a6696ada32f52e44b4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 5 17:38:00 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 5 17:38:55 2020 +0100

WHATS_NEW_DM: update

---
 WHATS_NEW_DM | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c707538..4cb0bd3 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,7 @@
 Version 1.02.171 - 
 =====================================
+  Fix dm_list interators with gcc 10 optimization (-ftree-pta).
+  Dmeventd handles timer without looping on short intervals.
 
 Version 1.02.169 - 11th February 2020
 =====================================



