From: David Teigland <teigland@sourceware.org>
Date: Tue, 15 Jan 2019 11:33:45 -0500
Subject: master - WHATS_NEW: device hints
Message-ID: <201901151633.x0FGXjaN009131@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3cf7668e347af547e6d986ffbfa7fe0d5b425a7f
Commit:        3cf7668e347af547e6d986ffbfa7fe0d5b425a7f
Parent:        6620dc9475d55207bfcd5e666f0379bcdf11831a
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jan 15 10:33:25 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jan 15 10:33:25 2019 -0600

WHATS_NEW: device hints

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 822d045..1187fb4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Add device hints to reduce scanning.
   Introduce LVM_SUPPRESS_SYSLOG to suppress syslog usage by generator.
   Fix generator quering lvmconfig unpresent config option.
   Fix memleak on bcache error path code.


