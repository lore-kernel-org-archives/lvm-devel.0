From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Oct 2013 10:36:44 +0000 (UTC)
Subject: master - WHATS_NEW: renamed thin_pool_chunk_size_calculation -> policy
Message-ID: <20131004103644.2D56661345@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a7ff7aee4f49015db03536bbaee13b9795d63e6c
Commit:        a7ff7aee4f49015db03536bbaee13b9795d63e6c
Parent:        8cf0810d57a0c47173c4775a08dd728c452f8eb8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 4 12:36:32 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 4 12:36:32 2013 +0200

WHATS_NEW: renamed thin_pool_chunk_size_calculation -> policy

---
 WHATS_NEW |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cfcd8c9..0b71786 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -5,7 +5,7 @@ Version 2.02.103 -
   Fix RAID calculation for sufficient allocatable space.
   Conversion from linear to mirror or RAID1 now honors mirror_segtype_default.
   Add thin-performance configuration profile.
-  Add lvm.conf allocation/thin_pool_chunk_size_calculation option.
+  Add lvm.conf allocation/thin_pool_chunk_size_policy option.
   Fix contiguous & cling allocation policies for parity RAID.  (2.02.100)
   Have lvmconf --enable/disable-cluster reset/set use_lvmetad.
   Don't install separate command symlink in binary directory for 'lvm devtypes'.


