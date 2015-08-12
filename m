From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 12:41:08 +0000 (UTC)
Subject: master - config: support longer config paths
Message-ID: <20150812124108.922DC6020B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13c7bbf8a9ff2fad2718ba6cb627d7fcef766900
Commit:        13c7bbf8a9ff2fad2718ba6cb627d7fcef766900
Parent:        533ac4d47dcecc976c05ba503acff11b9546b67c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 23 14:21:35 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 14:33:15 2015 +0200

config: support longer config paths

64 bytes might not be enough, so use larger buffer size.
---
 lib/config/config.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/config.h b/lib/config/config.h
index fb39e6e..e112223 100644
--- a/lib/config/config.h
+++ b/lib/config/config.h
@@ -50,7 +50,7 @@ struct profile_params {
 	struct dm_list profiles;                 /* list of profiles which are loaded already and which are ready for use */
 };
 
-#define CFG_PATH_MAX_LEN 64
+#define CFG_PATH_MAX_LEN 128
 
 /*
  * Structures used for definition of a configuration tree.


