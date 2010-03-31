From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 31 Mar 2010 14:35:34 +0200
Subject: [PATCH 0/5] Fix some scaling problems for large VGs (many LVs)
In-Reply-To: <cover.1269866168.git.mbroz@redhat.com>
References: <cover.1269866168.git.mbroz@redhat.com>
Message-ID: <4BB34196.6070403@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

..
> 
> Milan Broz (5):
>   Use hash table for quick lv reference when reading metadata.
>   Remove vg_validate call when parsing cached metadata.
>   Optimise PV segments search.
>   Do not traverse PV segment list twice.
>   Fix all segments memory is allocated from vg private mempool.
> 
>  lib/cache/lvmcache.c          |    3 +-
>  lib/format_text/import.c      |    2 +-
>  lib/format_text/import_vsn1.c |   42 +++++++++++++++++++++-------
>  lib/metadata/lv_manip.c       |    2 +-
>  lib/metadata/merge.c          |    4 +-
>  lib/metadata/metadata.c       |   12 --------
>  lib/metadata/metadata.h       |    3 --
>  lib/metadata/pv_alloc.h       |    4 ++-
>  lib/metadata/pv_manip.c       |   60 ++++++++++++++++++++++++++++------------
>  9 files changed, 81 insertions(+), 51 deletions(-)
> 
> 

Patch set goes to right direction - but still there is probably more complex
solution - In activation we could keep locked & parsed VG data in volume_group
structure in memory - instead of parsing them for each LV again.
(for the case of having like 3000LV in one VG)

Zdenek


