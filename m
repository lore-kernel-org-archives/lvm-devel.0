From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 26 Sep 2013 03:37:51 +0000 (UTC)
Subject: master - WHATS_NEW: description for previous commit
Message-ID: <20130926033751.33BBB60FBD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d6516d2f7900aa233c2a96e171b355bec7e54395
Commit:        d6516d2f7900aa233c2a96e171b355bec7e54395
Parent:        098896fb2905cd02d02b7271be489e32d86c073d
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Sep 25 22:35:52 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Sep 25 22:35:52 2013 -0500

WHATS_NEW: description for previous commit

commit 098896fb2905cd02d02b7271be489e32d86c073d failed to include
description of what was fixed.

"Conversion from linear to mirror or RAID1 now honors
 mirror_segtype_default."
---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 14ae12e..7750d2e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.103 - 
 ======================================
+  Conversion from linear to mirror or RAID1 now honors mirror_segtype_default.
   Add thin-performance configuration profile.
   Add lvm.conf allocation/thin_pool_chunk_size_calculation option.
   Fix contiguous & cling allocation policies for parity RAID.  (2.02.100)


