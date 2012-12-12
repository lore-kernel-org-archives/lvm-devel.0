From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 12 Dec 2012 14:17:40 +0000 (UTC)
Subject: master - Update WHATS_NEW.
Message-ID: <20121212141740.C3859AABD3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c089029b70d64e4f7d2851336d463ce40f1b7023
Commit:        c089029b70d64e4f7d2851336d463ce40f1b7023
Parent:        b19f840af82cf176a26c8bddc2217fe862087794
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Dec 12 15:17:08 2012 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Dec 12 15:17:08 2012 +0100

Update WHATS_NEW.

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4214b27..075fda2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Avoid a global lock in pvs when lvmetad is in use.
   Fix crash in pvscan --cache -aay triggered by non-mda PV.
   Allow lvconvert --stripes/stripesize only with --mirrors/--repair/--thinpool.
   Fix memleak in device_is_usable mirror testing function.


