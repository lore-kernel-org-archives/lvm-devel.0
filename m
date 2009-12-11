From: Milan Broz <mbroz@redhat.com>
Date: Fri, 11 Dec 2009 11:37:51 +0100
Subject: [PATCH 0/4] Fixes and cleanups
In-Reply-To: <cover.1260449368.git.zkabelac@redhat.com>
References: <cover.1260449368.git.zkabelac@redhat.com>
Message-ID: <4B2220FF.2090701@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Well, these are all cleanup patches + segfault fix,
ACK.

Milan


On 12/10/2009 01:53 PM, Zdenek Kabelac wrote:
> Zdenek Kabelac (4):
>   Fix coredump and memory leak for 'dmsetup help -c'
>   Fix unlocking for vgrelease for error paths
>   Skip 'return' keyword for void() functions
>   Call dm_pool_destroy on allocation error path
> 
>  lib/display/display.c           |   11 -----------
>  lib/filters/filter-persistent.c |    2 --
>  lib/filters/filter.c            |    1 -
>  lib/format1/format1.c           |    1 -
>  lib/format1/lvm1-label.c        |    1 -
>  lib/format_pool/format_pool.c   |    1 -
>  lib/format_pool/pool_label.c    |    1 -
>  lib/format_text/format-text.c   |    1 -
>  lib/locking/locking.c           |    4 ----
>  lib/locking/no_locking.c        |    2 --
>  lib/metadata/metadata.c         |    2 +-
>  lib/misc/lvm-string.c           |    2 +-
>  libdm/libdm-deptree.c           |    4 ++--
>  tools/dmsetup.c                 |    7 ++++---
>  tools/lvmcmdlib.c               |    2 --
>  tools/pvresize.c                |    8 ++++++--
>  tools/pvscan.c                  |    1 -
>  tools/toollib.c                 |    6 +++---
>  18 files changed, 17 insertions(+), 40 deletions(-)


