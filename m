From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 17 Dec 2010 11:55:11 +0100
Subject: [PATCH 0/1] Config tree cache
Message-ID: <cover.1292582945.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Second version of the config tree caching.
Look into the patch header for description of new functionality.

Zdenek Kabelac (1):
  Extend lvm cache with config tree

 lib/cache/lvmcache.c     |   16 +++++++++++++++-
 lib/cache/lvmcache.h     |    2 ++
 lib/format_text/import.c |   23 +++++++++++++++++++++++
 lib/metadata/metadata.h  |    3 +++
 4 files changed, 43 insertions(+), 1 deletions(-)

-- 
1.7.3.3


