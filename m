From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:27:48 -0400
Subject: master - tests: add space to split words
Message-ID: <201707101227.v6ACRm0X021692@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e11de5847d8f367c6c07221db560d3c82371ed81
Commit:        e11de5847d8f367c6c07221db560d3c82371ed81
Parent:        270e526734ee6f97412adf52c52194c46ac9ae21
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 6 20:40:46 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: add space to split words

Fixing shellcheck warning:
This word is outside of quotes. Did you intend to 'nest '"'single quotes'"' instead'?
---
 test/shell/profiles.sh |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/test/shell/profiles.sh b/test/shell/profiles.sh
index 923baec..cecb6e8 100644
--- a/test/shell/profiles.sh
+++ b/test/shell/profiles.sh
@@ -81,10 +81,9 @@ aux profileconf valid_cmd_profile 'global/units = "h"' \
 
 aux profileconf valid_mda_profile 'allocation/thin_pool_zero = 0' \
 				  'allocation/thin_pool_discards = "passdown"' \
-				  'allocation/thin_pool_chunk_size = 64'\
+				  'allocation/thin_pool_chunk_size = 64' \
 				  'activation/thin_pool_autoextend_threshold = 100' \
-				  'activation/thin_pool_autoextend_percent = 20' \
-
+				  'activation/thin_pool_autoextend_percent = 20'
 
 aux profileconf extra_mda_profile 'allocation/thin_pool_chunk_size = 128'
 


