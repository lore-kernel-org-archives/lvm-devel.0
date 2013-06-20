From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 20 Jun 2013 09:44:18 +0000 (UTC)
Subject: master - Clean-up: WHATS_NEW
Message-ID: <20130620094418.0C4C760F36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8215846aa52b727c3c639d9b354d611319be26c6
Commit:        8215846aa52b727c3c639d9b354d611319be26c6
Parent:        a6d13308ec0baca9a5bd48f80d02e5c71a54287f
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Jun 19 19:55:34 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Jun 19 19:55:34 2013 -0500

Clean-up: WHATS_NEW

Choosing between two entries and forgot to remove one.
---
 WHATS_NEW |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d527854..c24f576 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,7 +1,6 @@
 Version 2.02.99 - 
 ===================================
   Use mirror_segtype_default if type not specified for linear->mirror upconvert.
-  Make upconvert from linear use mirror_segtype_default to determine segtype.
   Fix use of too big chunks of memory when communication with lvmetad.
   Fix vgcfgrestore crash when specified incorrect vg name.
   Refine lvm.conf and man page documentation for autoactivation feature.


