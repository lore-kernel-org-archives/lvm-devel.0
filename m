From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 28 Mar 2014 08:10:52 +0000 (UTC)
Subject: master - lvconvert: fix help message cache_pool -> cache-pool
Message-ID: <20140328081052.8B83F60FE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d0ba79f86a209335a3e391352aa7de685e4992b
Commit:        3d0ba79f86a209335a3e391352aa7de685e4992b
Parent:        a512ea6a6a887e807736fe49fa14b1be791f0e38
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Mar 28 09:10:30 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 28 09:10:30 2014 +0100

lvconvert: fix help message cache_pool -> cache-pool

---
 tools/commands.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index c047cb9..b0bad9d 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -215,7 +215,7 @@ xx(lvconvert,
    "\t[-d|--debug] [-h|-?|--help] [-v|--verbose]\n\n"
 
    "lvconvert "
-   "--type cache_pool\n"
+   "--type cache-pool\n"
    "\t[--cachemode CacheMode]\n"
    "\t[--chunksize size]\n"
    "\t[--poolmetadata CacheMetadataLogicalVolume[Path] |\n"


