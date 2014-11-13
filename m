From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 13 Nov 2014 16:53:42 +0000 (UTC)
Subject: master - lvconvert.8: fix bold and italic syntax mistake
Message-ID: <20141113165342.249176104A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=271252eff7bac62c186528ebaee176133eeeabaf
Commit:        271252eff7bac62c186528ebaee176133eeeabaf
Parent:        88e944b5a3c8633f9c6b3994743159801f1a7147
Author:        St??phane Aulery <saulery@free.fr>
AuthorDate:    Wed Nov 12 13:39:36 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 13 17:49:42 2014 +0100

lvconvert.8: fix bold and italic syntax mistake

Signed-off-by: St??phane Aulery <saulery@free.fr>
---
 man/lvconvert.8.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index bf699ee..5c9c083 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -416,7 +416,7 @@ and
 Sets the size of cache or thin pool's metadata logical volume,
 if the pool metadata volume is undefined.
 Pool is specified with the option
-\B\-\-cachepool\P or \fB\-\-thinpool\fP.
+\fB\-\-cachepool\fP or \fB\-\-thinpool\fP.
 For thin pool supported value is in the range between 2MiB and 16GiB.
 The default value is estimated with this formula
 (Pool_LV_size / Pool_LV_chunk_size * 64b).


