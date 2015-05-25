From: okozina <okozina@fedoraproject.org>
Date: Mon, 25 May 2015 08:49:28 +0000 (UTC)
Subject: master - WHATS_NEW: update
Message-ID: <20150525084928.874EF61026@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b244fffc182ef15ff23d4fc11658997347f66d79
Commit:        b244fffc182ef15ff23d4fc11658997347f66d79
Parent:        da20e0c5079eab7d76e3bae96ed3f4dd473efde6
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon May 25 10:46:38 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon May 25 10:48:53 2015 +0200

WHATS_NEW: update

update for commit: f8bf6410954fcf82bf28852e0dba015c6b7f19dc
---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e5864eb..29eb501 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.121 - 
 ================================
+  Fix a segfault in pvscan --cache --background command.
   Fix test for AREA_PV when checking for failed mirrors.
   Do not use --sysinit in lvm2-activation{-early,-net}.service if lvmpolld used.
   Do not fail polling when poll LV not found (already finished or removed).


