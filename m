From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 26 Mar 2012 14:30:34 +0200
Subject: [PATCH 0/2] Speedup pvs
Message-ID: <cover.1332764920.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Proposals to fight slow execution of commands likes pvs.
Which is especially visible with lvmetad.

Zdenek Kabelac (2):
  Proposal to speedup pvs ver.1
  Avoid reparsing same metadata

 lib/config/config.c              |   10 ++-
 lib/config/config.h              |    3 +-
 lib/format_text/import.c         |   19 +++++-
 lib/metadata/metadata-exported.h |   10 +++
 lib/metadata/metadata.c          |   30 ++++++---
 tools/toollib.c                  |  128 ++++++++++++++++++++++++++++----------
 6 files changed, 153 insertions(+), 47 deletions(-)

-- 
1.7.9.3


