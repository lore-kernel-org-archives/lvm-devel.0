From: David Teigland <teigland@sourceware.org>
Date: Wed, 3 May 2017 16:39:56 -0400
Subject: master - man pvscan: add description for --activate
Message-ID: <201705032039.v43KduED000997@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b869db30ac9d22fbdf17218d6bdc9356922e397c
Commit:        b869db30ac9d22fbdf17218d6bdc9356922e397c
Parent:        892f3b1002837abeed5c0a239de107678c6fb794
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 3 15:37:48 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 3 15:38:53 2017 -0500

man pvscan: add description for --activate

---
 tools/args.h |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 704b4e7..2dc738f 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -808,6 +808,9 @@ arg(metadatacopies_ARG, '\0', "metadatacopies", metadatacopies_VAL, 0, 0, NULL)
  * ... and now the short args.
  */
 arg(activate_ARG, 'a', "activate", activation_VAL, 0, 0,
+    "#pvscan\n"
+    "Auto-activate LVs in a VG when the PVs scanned have completed the VG.\n"
+    "(Only \\fBay\\fP is applicable.)\n"
     "#lvchange\n"
     "#vgchange\n"
     "Change the active state of LVs.\n"


