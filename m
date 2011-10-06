From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu,  6 Oct 2011 11:42:59 +0200
Subject: [PATCH 0/3] Allow empty prefix
Message-ID: <cover.1317893838.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Resolving problem of command like  'lvs/pvs/vgs' were always 
printing 2 space prefix "  " even if user has specified no prefix.

1. fix coredump of lvm if buggy config is read.
   (introduced with cascaded patch).

2. For reading empty string introduce find_config_tree_str_allow_empty()
   and dm_config_tree_find_str_allow_empty().

3. Change default to "" (no prefix) - since that what most users 
   would expect here probably.

Zdenek Kabelac (3):
  Fix core on buggy config file
  Add find_config_tree_str_allow_empty
  Change default prefix.

 doc/example.conf.in        |    6 +++---
 lib/commands/toolcontext.c |    7 ++++---
 lib/config/config.c        |    6 ++++++
 lib/config/config.h        |    2 ++
 lib/config/defaults.h      |    6 +++++-
 libdm/libdevmapper.h       |    2 ++
 libdm/libdm-config.c       |   25 +++++++++++++++++++------
 test/t-000-basic.sh        |    3 +++
 8 files changed, 44 insertions(+), 13 deletions(-)

-- 
1.7.6.4


