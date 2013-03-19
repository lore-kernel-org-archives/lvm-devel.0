From: Petr Rockai <prockai@redhat.com>
Date: Wed, 20 Mar 2013 00:39:27 +0100
Subject: [PATCH] Pass parsed metadata to activation code.
Message-ID: <8738vrc634.fsf@mornfall.net>
	(sfid-20130320_003928_215503_2A328EE0)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the actual patches can be seen as follows:

$ git clone http://repos.mornfall.net/lvm2/mornfall.git
$ git checkout origin/mornfall
$ git log 6a995ba..65718c8 -p

There might be some cleaning up to do, but otherwise the patches should
be in a reasonably good shape. Since the status on Monday, both
precommit (incore) and ondisk (committed) metadata is now passed into
suspend, so no reading or scanning is necessary.

These patches directly improve performance when lvmetad is in use (since
when lvmetad is active, lvmcache is bypassed in those calls, causing an
extra roundtrip to lvmetad). They also pave way for removing the
dependency of the activation code on lvmcache (in a later patchset).

Petr

PS: The current incarnation just went into Hydra, so I don't have
complete test results yet. I moved to using an explicit in-repo branch
in git and hydra kept picking up "master" which is the same in my repo
as it is in fedorahosted. Tests seem OK on my machine though.

commit 65718c8cc49bc980a43ab4089b51dc7f0f40eb96
Author: Petr Rockai <me@mornfall.net>
Date:   Wed Mar 20 00:00:11 2013 +0100

    activation: Pass both ondisk and incore LV to suspend.

 daemons/clvmd/lvm-functions.c |  2 +-
 lib/activate/activate.c       | 69 ++++++++++++++++++++++---------------------
 lib/activate/activate.h       |  2 +-
 lib/locking/file_locking.c    |  2 +-
 lib/locking/no_locking.c      |  4 +--
 5 files changed, 40 insertions(+), 39 deletions(-)

commit 777b50c117b6bcd587bc54066dede378976cf97b
Author: Petr Rockai <me@mornfall.net>
Date:   Mon Mar 18 15:46:00 2013 +0100

    metadata: Fix a pool CRC failure due to "late" ondisk copy creation.

 lib/metadata/metadata.c | 9 +++++++++
 1 file changed, 9 insertions(+)

commit 665ba9afb5a427965d22f04489ba4e04808e3b86
Author: Petr Rockai <me@mornfall.net>
Date:   Sun Mar 17 21:49:00 2013 +0100

    Actually pass LV metadata to activation code, when available.
    
    This ties the two preceding changes together, actually using the "ondisk"
    version of VG metadata instead of calling into lvmcache when activating
    volumes. The cache hooks are still used as a fallback, because we don't have an
    uncached scanning API yet.

 lib/locking/file_locking.c | 10 +++++-----
 lib/locking/no_locking.c   |  6 +++---
 2 files changed, 8 insertions(+), 8 deletions(-)

commit 1c3b3c37745f8e666840e52af6f892bb08ff8f3a
Author: Petr Rockai <me@mornfall.net>
Date:   Sun Mar 17 21:29:58 2013 +0100

    locking: Make it possible to pass down an LV to activation code.
    
    Previously, we have relied on UUIDs alone, and on lvmcache to make getting a
    "new copy" of VG metadata fast. If the code which triggers the activation has
    the correct VG metadata at hand (the version which is currently on disk), it can
    now hand it to the activation code directly.

 daemons/clvmd/lvm-functions.c  | 12 +++----
 lib/activate/activate.c        | 79 ++++++++++++++++++++++--------------------
 lib/activate/activate.h        | 14 ++++----
 lib/locking/cluster_locking.c  |  4 +--
 lib/locking/external_locking.c |  2 +-
 lib/locking/file_locking.c     | 12 +++----
 lib/locking/locking.c          | 14 ++++----
 lib/locking/locking.h          | 16 +++++----
 lib/locking/locking_types.h    |  2 +-
 lib/locking/no_locking.c       | 16 ++++-----
 lib/metadata/metadata.c        |  8 ++---
 liblvm/lvm_vg.c                |  4 +--
 tools/lvconvert.c              |  2 +-
 tools/pvchange.c               |  2 +-
 tools/pvcreate.c               |  2 +-
 tools/pvremove.c               |  2 +-
 tools/pvresize.c               |  2 +-
 tools/pvscan.c                 |  4 +--
 tools/toollib.c                |  2 +-
 tools/vgcfgrestore.c           |  4 +--
 tools/vgcreate.c               |  2 +-
 tools/vgextend.c               |  2 +-
 tools/vgreduce.c               |  2 +-
 tools/vgscan.c                 |  2 +-
 24 files changed, 108 insertions(+), 103 deletions(-)

commit 9c305583ef0c33d606bd7459de9b3383c35f3e98
Author: Petr Rockai <me@mornfall.net>
Date:   Sun Mar 17 16:27:44 2013 +0100

    Add and track an "ondisk" pointer to struct volume_group.
    
    This allows us to get the current on-disk version of the metadata whenever we
    have the current in-flight version, without a recourse to scanning or lvmcache.

 lib/metadata/lv.h       |  1 +
 lib/metadata/metadata.c | 57 +++++++++++++++++++++++++++++++++++++++++++++++++
 lib/metadata/vg.c       |  1 +
 lib/metadata/vg.h       |  3 +++
 4 files changed, 62 insertions(+)

commit 9fd154e68d4c204845410c0563b577341959bb3b
Author: Petr Rockai <me@mornfall.net>
Date:   Sun Mar 17 16:25:12 2013 +0100

    Move export_vg_to_config_tree alongside export_vg_to_buffer.

 lib/cache/lvmetad.c      | 24 ++----------------------
 lib/format_text/export.c | 20 ++++++++++++++++++++
 lib/metadata/metadata.h  |  2 +-
 3 files changed, 23 insertions(+), 23 deletions(-)

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


