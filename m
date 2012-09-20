From: Petr Rockai <prockai@redhat.com>
Date: Thu, 20 Sep 2012 03:12:48 +0200
Subject: lvmetad patches
Message-ID: <87txutsdin.fsf@aldalome.mornfall.net>
	(sfid-20120920_031251_174648_1B06B321)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I have a bunch of lvmetad-related patches stashed in a git branch at
[1]. The branch as a whole gets through the testsuite just fine [2], and
I think the patches are good enough to go in. I would normally just
rebase and push them, but the test results of the master branch are
currently kind of bleak [3], so we may want to fix that before doing the
merge.

At least bugs #814782 #837599 #839941 #823918 and #845269 should be
fixed. Unfortunately, #845259 is extremely elusive. I'll give it one
more shot tomorrow.

[1]: http://repos.mornfall.net/lvm2/mornfall.git
[2]: http://divine.fi.muni.cz/hydra/eval/2626
[3]: http://divine.fi.muni.cz/hydra/eval/2597

Yours,
   Petr

A summary of the changes, as compared to master:

commit 962e39d98173da263f5b675741123d4f7d2ac785
Author: Petr Rockai <prockai@redhat.com>
Date:   Thu Sep 20 01:57:55 2012 +0200

    TEST: Workaround for lvmetad vs inconsistent metadata.

 test/shell/inconsistent-metadata.sh |  1 +
 test/shell/unlost-pv.sh             | 12 ++++++++----
 2 files changed, 9 insertions(+), 4 deletions(-)

commit c3732c74bd62735f5e2acdeacef31eb6f3a9e025
Author: Petr Rockai <prockai@redhat.com>
Date:   Thu Sep 20 01:56:41 2012 +0200

    lvmetad: Initialise debug_config also if no -d is given.

 daemons/lvmetad/lvmetad-core.c | 1 +
 1 file changed, 1 insertion(+)

commit 266e3c97995971ec9c4257ac9c1574e68427785a
Author: Petr Rockai <prockai@redhat.com>
Date:   Wed Sep 19 23:45:51 2012 +0200

    lvmetad: Give inconsistent metadata warnings in pvscan --cache.

 daemons/lvmetad/lvmetad-core.c | 21 ++++++++++++++++-----
 lib/cache/lvmetad.c            |  5 +++++
 2 files changed, 21 insertions(+), 5 deletions(-)

commit d80d8abb6a10d8cf0fd3ed80c23fc48abe29d46f
Author: Petr Rockai <prockai@redhat.com>
Date:   Wed Sep 19 23:30:16 2012 +0200

    lvmetad: Fix #845269: SEGV on corrupt lvmetad response.

 lib/cache/lvmetad.c              | 6 +++---
 libdaemon/client/daemon-client.c | 2 ++
 2 files changed, 5 insertions(+), 3 deletions(-)

commit c72ec9c8858bf2196c0ac2a89197d0db63dee38c
Author: Petr Rockai <prockai@redhat.com>
Date:   Wed Sep 19 23:18:28 2012 +0200

    lvmetad: Clear metadata/PV cache before a token-triggered rescan.

 daemons/lvmetad/lvmetad-core.c | 82 ++++++++++++++++++++++++++++++------------
 lib/cache/lvmetad.c            |  6 ++++
 2 files changed, 65 insertions(+), 23 deletions(-)

commit f81541fa967b484e8652196d05250faabf883f69
Author: Petr Rockai <prockai@redhat.com>
Date:   Mon Sep 10 16:35:43 2012 +0200

    lvmetad: Make vgscan --cache an alias to pvscan --cache.

 tools/vgscan.c | 16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

commit 83549c6e742c825bb512d440d5ae2529d6d65758
Author: Petr Rockai <prockai@redhat.com>
Date:   Mon Sep 10 07:42:39 2012 +0200

    TEST: Add LVM_VALGRIND_LVMETAD to testing options.

 test/lib/aux.sh | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

commit 9b7bff278930dc82ec490460bb5532546d56374d
Author: Petr Rockai <prockai@redhat.com>
Date:   Mon Sep 10 07:41:15 2012 +0200

    libdaemon: Rename make_nodes* to config_make_nodes*.

 lib/cache/lvmetad.c              | 19 +++++++++++--------
 lib/config/config.c              |  1 +
 lib/format_text/format-text.c    | 12 ++++++------
 libdaemon/client/daemon-client.c |  2 +-
 libdaemon/client/daemon-shared.c | 18 +++++++++---------
 libdaemon/client/daemon-shared.h | 16 ++++++++--------
 6 files changed, 36 insertions(+), 32 deletions(-)

commit e0a8a19a565ad71cc171d2c87866d9be772df450
Author: Petr Rockai <prockai@redhat.com>
Date:   Mon Sep 10 07:40:00 2012 +0200

    Makefiles: Build libdaemonclient unconditionally.

 Makefile.in           | 6 +-----
 libdaemon/Makefile.in | 4 +++-
 make.tmpl.in          | 8 +++-----
 3 files changed, 7 insertions(+), 11 deletions(-)

commit 6470ffd64ecbf5bfda89a25ced0a092268ccb0a1
Author: Petr Rockai <prockai@redhat.com>
Date:   Sun Sep 9 22:05:59 2012 +0200

    lib/cache/lvmetad: s/pvscan_lvmetad/lvmetad_pvscan/ in the API

 lib/cache/lvmetad.c | 18 +++++++++---------
 lib/cache/lvmetad.h |  8 ++++----
 tools/pvscan.c      |  6 +++---
 3 files changed, 16 insertions(+), 16 deletions(-)

commit 848417f15fb88314f2ef94551877ff5f408dfb26
Author: Petr Rockai <prockai@redhat.com>
Date:   Sun Sep 9 21:57:59 2012 +0200

    lvmetad: Use "%" PRId64 in place of "%d" for extra clarity.

 lib/cache/lvmetad.c              | 12 ++++++------
 lib/format_text/format-text.c    |  8 ++++----
 libdaemon/client/daemon-shared.c |  8 ++++----
 libdaemon/server/daemon-server.c |  2 +-
 4 files changed, 15 insertions(+), 15 deletions(-)

commit 3a74a5bed37ea6e43d5d5c0994ee75f3179701f6
Author: Petr Rockai <prockai@redhat.com>
Date:   Mon Aug 13 19:44:10 2012 +0200

    Implement devices/global_filter.
    
    The global filter is applied first, and is also applied in pvscan --cache (which
    is called from udev rules to keep lvmetad updated). Cf. example.conf.

 daemons/lvmetad/lvmetad-core.c   |  87 +++++++++++++-------
 doc/example.conf.in              |   8 ++
 lib/cache/lvmcache.c             |   2 -
 lib/cache/lvmetad.c              | 167 +++++++++++++++++++++++++++++++--------
 lib/cache/lvmetad.h              |  27 ++++++-
 lib/commands/toolcontext.c       |  45 +++++++++--
 lib/commands/toolcontext.h       |   1 +
 lib/device/dev-cache.c           |   4 +-
 lib/device/dev-cache.h           |   1 +
 lib/filters/filter-persistent.c  |   5 +-
 lib/filters/filter-persistent.h  |   1 -
 libdaemon/client/daemon-shared.c |   4 +-
 test/lib/aux.sh                  |   2 +-
 tools/pvscan.c                   |  31 +-------
 tools/vgrename.c                 |   3 +-
 tools/vgscan.c                   |   3 +-
 16 files changed, 279 insertions(+), 112 deletions(-)

commit 6f584b42a9a8d12bc4e5d0d9b48b05840493482d
Author: Petr Rockai <prockai@redhat.com>
Date:   Mon Aug 13 14:41:57 2012 +0200

    example.conf.in: The command to refresh lvmetad is pvscan --cache.

 doc/example.conf.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

commit bc10d1b76f1ec310dfb7af5ad199b0dc46063248
Author: Petr Rockai <prockai@redhat.com>
Date:   Sat Aug 11 10:37:28 2012 +0200

    lib/cache/lvmetad: Refactor to use dm_config_tree in requests.
    
    We were using daemon_send_simple until now, but it is no longer adequate, since
    we need to manipulate requests in a generic way (adding a validity token to each
    request), and the tree-based request interface is much more suitable for this.

 lib/cache/lvmetad.c           | 220 +++++++++++++++++++++++-------------------
 lib/cache/lvmetad.h           |   2 +
 lib/format_text/format-text.c |  23 ++---
 lib/metadata/metadata.h       |   3 +-
 4 files changed, 137 insertions(+), 111 deletions(-)

commit 7d424c2c98e226d5271a48169df8be32426e442f
Author: Petr Rockai <prockai@redhat.com>
Date:   Sat Aug 11 10:33:53 2012 +0200

    libdaemon: Extend and refactor APIs.
    
    - move common dm_config_tree manipulation functions from lvmetad-core to
      daemon-shared
    - add config-tree-based request manipulation APIs to daemon-client
    - factor out _v (va_list) variants of most variadic functions in libdaemon

 daemons/lvmetad/lvmetad-core.c   | 123 ----------------------
 libdaemon/client/daemon-client.c |  74 +++++++++++--
 libdaemon/client/daemon-client.h |   6 ++
 libdaemon/client/daemon-shared.c | 218 ++++++++++++++++++++++++++++++++++++++-
 libdaemon/client/daemon-shared.h |  38 ++++++-
 libdaemon/server/daemon-server.c |  45 +++-----
 6 files changed, 341 insertions(+), 163 deletions(-)

commit e94006c9deaf1b41111b19921f28d39c823993ed
Author: Petr Rockai <prockai@redhat.com>
Date:   Sat Aug 18 22:03:46 2012 +0200

    dev-cache: Make it possible to pass in a NULL filter.

 lib/device/dev-cache.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

commit b7885824aefc8579897ddf8a2c1b883f68345e4a
Author: Petr Rockai <prockai@redhat.com>
Date:   Sat Aug 18 18:59:07 2012 +0200

    filters: Alwayz zalloc the filter struct.
    
    Not all pointers need to be initialised explicitly that way.

 lib/filters/filter-composite.c  | 2 +-
 lib/filters/filter-md.c         | 2 +-
 lib/filters/filter-mpath.c      | 2 +-
 lib/filters/filter-persistent.c | 2 +-
 lib/filters/filter.c            | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

commit 6cb2d830cf9c66dbb24efface4c6af8f80d1f3e5
Author: Petr Rockai <prockai@redhat.com>
Date:   Sat Aug 11 10:29:38 2012 +0200

    TEST: Kill lvmetad early in teardown.

 test/lib/aux.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


