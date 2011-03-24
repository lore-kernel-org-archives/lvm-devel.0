From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 24 Mar 2011 12:16:33 +0100
Subject: [PATCH 0/4] Valgrind fixes
Message-ID: <cover.1300965223.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Another small set mainly with fixes discover with valgrind.
I assume patch2 is the really important one.

Zdenek Kabelac (4):
  Reading of unitialized memory
  Fix access to released memory
  Another fix for garbage send in clvmd message
  Better shutdown for clvmd

 daemons/clvmd/clvmd.c         |   30 ++++++++++++++++++++++--------
 daemons/clvmd/refresh_clvmd.c |    5 +++--
 lib/cache/lvmcache.c          |   24 ++++++++++++++----------
 lib/format1/import-extents.c  |    2 +-
 4 files changed, 40 insertions(+), 21 deletions(-)

-- 
1.7.4.1


