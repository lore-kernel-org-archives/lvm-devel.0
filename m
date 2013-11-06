From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  6 Nov 2013 12:30:12 +0000 (UTC)
Subject: master - profile: add thin_pool_chunk_size_policy to default.profile
Message-ID: <20131106123012.2738E61373@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc144a3fc5389db11c3c34c9c240a763cc850cc7
Commit:        fc144a3fc5389db11c3c34c9c240a763cc850cc7
Parent:        14b852609b20e57c3b2dede0641d31155232b946
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 6 13:29:25 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 6 13:29:25 2013 +0100

profile: add thin_pool_chunk_size_policy to default.profile

By default, thin_pool_chunk_size_policy is set to "generic".
---
 conf/default.profile.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/conf/default.profile.in b/conf/default.profile.in
index 6a0b8f1..29049ef 100644
--- a/conf/default.profile.in
+++ b/conf/default.profile.in
@@ -9,6 +9,7 @@
 # Refer to 'man lvm.conf' for further information about profiles and file layout.
 
 allocation {
+	thin_pool_chunk_size_policy = "generic"
 	thin_pool_chunk_size = 64
 	thin_pool_discards = "passdown"
 	thin_pool_zero = 1


