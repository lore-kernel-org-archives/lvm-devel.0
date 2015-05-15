From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 15 May 2015 16:39:20 +0000 (UTC)
Subject: master - config: thin_pool_chunk_size_policy is not undefined
Message-ID: <20150515163920.DE8C3602C1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b7db994aba358d2dc456eb8b22c6b375961e1b07
Commit:        b7db994aba358d2dc456eb8b22c6b375961e1b07
Parent:        03aec36fc05c7cd78e0a5407c09e4d47b973c02f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 15 11:37:16 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 15 11:37:16 2015 -0500

config: thin_pool_chunk_size_policy is not undefined

The default policy setting does not depend on any
system/kernel values.
---
 lib/config/config_settings.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index e255392..9f31f6e 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -491,7 +491,7 @@ cfg(allocation_thin_pool_discards_CFG, "thin_pool_discards", allocation_CFG_SECT
 	"The discards behaviour of thin pool volumes.\n"
 	"Possible options are: ignore, nopassdown, passdown.\n")
 
-cfg(allocation_thin_pool_chunk_size_policy_CFG, "thin_pool_chunk_size_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_UNDEFINED, CFG_TYPE_STRING, DEFAULT_THIN_POOL_CHUNK_SIZE_POLICY, vsn(2, 2, 101), NULL, 0, NULL,
+cfg(allocation_thin_pool_chunk_size_policy_CFG, "thin_pool_chunk_size_policy", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA, CFG_TYPE_STRING, DEFAULT_THIN_POOL_CHUNK_SIZE_POLICY, vsn(2, 2, 101), NULL, 0, NULL,
 	"The chunk size calculation policy for thin pool volumes.\n"
 	"Possible options are: generic, performance.\n"
 	"generic - If thin_pool_chunk_size is defined, use it.\n"


