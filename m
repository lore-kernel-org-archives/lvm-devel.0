From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 27 Nov 2013 15:50:04 +0000 (UTC)
Subject: master - profile: wipe_signatures_on_new_logical_volumes_when_zeroing not yet profilable
Message-ID: <20131127155004.9B78860D2A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5a4137c804b0ba579c5f368fe91942c465815f66
Commit:        5a4137c804b0ba579c5f368fe91942c465815f66
Parent:        5968f07fd5ccb2b7d4e407cd8fec86b0b1f80f3a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 27 16:49:12 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 27 16:49:12 2013 +0100

profile: wipe_signatures_on_new_logical_volumes_when_zeroing not yet profilable

But it might be - needs more testing...
---
 conf/default.profile.in |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/conf/default.profile.in b/conf/default.profile.in
index 5a481de..29049ef 100644
--- a/conf/default.profile.in
+++ b/conf/default.profile.in
@@ -9,7 +9,6 @@
 # Refer to 'man lvm.conf' for further information about profiles and file layout.
 
 allocation {
-	wipe_signatures_on_new_logical_volumes_when_zeroing = 1
 	thin_pool_chunk_size_policy = "generic"
 	thin_pool_chunk_size = 64
 	thin_pool_discards = "passdown"


