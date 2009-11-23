From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 23 Nov 2009 18:23:45 -0500
Subject: data alignment of structures with 'status'
Message-ID: <20091123232344.GA16119@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I used F11's "dwarves" package's 'pahole' tool to analyze what impact
changing 'status' from 32-bits to 64-bits would have (on x86_64); more
info on dwarves and pahole here:
http://lwn.net/Articles/335942/
https://ols2006.108.redhat.com/2007/Reprints/melo-Reprint.pdf

As you can see below, if we reorganize the 'lv_segment' structure
slightly and increase status to 64-bit we are able to have a perfectly
aligned structure.

I'll soon be sending in a proper patch to extend 'status' of 
lv_segment, logical_volume, volume_group, and physical_volume
to be 64-bits.  Extending to 64-bits is mostly free because there was at
least 1 4-byte hole in all structures except logical_volume (But
'physical_volume' would still have a 4-byte hole; it currently has 2
4-byte holes).

BTW, I think it'd be worthwhile to audit all structures with pahole
(and the kernel's DM structures too?); here are some example savings
(eliminated all holes in the following):

cmd_context: saved 16 bytes and 1 cacheline!
physical_volume: saved 8 bytes! (this was without extending status)
volume_group: saved 4 bytes! (this was without extending status)
pvcreate_params: saved 8 bytes!
vgcreate_params: saved 4 bytes!
config_info: saved 8 bytes!
daemon_parms: saved 8 bytes!


with 32-bit status:

struct lv_segment {
        struct dm_list             list;                 /*     0    16 */
        struct logical_volume *    lv;                   /*    16     8 */
        const struct segment_type  * segtype;            /*    24     8 */
        uint32_t                   le;                   /*    32     4 */
        uint32_t                   len;                  /*    36     4 */
        uint32_t                   status;               /*    40     4 */
        uint32_t                   stripe_size;          /*    44     4 */
        uint32_t                   area_count;           /*    48     4 */
        uint32_t                   area_len;             /*    52     4 */
        struct logical_volume *    origin;               /*    56     8 */
        /* --- cacheline 1 boundary (64 bytes) --- */
        struct logical_volume *    cow;                  /*    64     8 */
        struct dm_list             origin_list;          /*    72    16 */
        uint32_t                   chunk_size;           /*    88     4 */
        uint32_t                   region_size;          /*    92     4 */
        uint32_t                   extents_copied;       /*    96     4 */

        /* XXX 4 bytes hole, try to pack */

        struct logical_volume *    log_lv;               /*   104     8 */
        void *                     segtype_private;      /*   112     8 */
        struct dm_list             tags;                 /*   120    16 */
        /* --- cacheline 2 boundary (128 bytes) was 8 bytes ago --- */
        struct lv_segment_area *   areas;                /*   136     8 */

        /* size: 144, cachelines: 3, members: 19 */
        /* sum members: 140, holes: 1, sum holes: 4 */
        /* last cacheline: 16 bytes */
};

with 64-bit status:

struct lv_segment {
        struct dm_list             list;                 /*     0    16 */
        struct logical_volume *    lv;                   /*    16     8 */
        const struct segment_type  * segtype;            /*    24     8 */
        uint32_t                   le;                   /*    32     4 */
        uint32_t                   len;                  /*    36     4 */
        uint64_t                   status;               /*    40     8 */
        uint32_t                   stripe_size;          /*    48     4 */
        uint32_t                   area_count;           /*    52     4 */
        uint32_t                   area_len;             /*    56     4 */

        /* XXX 4 bytes hole, try to pack */

        /* --- cacheline 1 boundary (64 bytes) --- */
        struct logical_volume *    origin;               /*    64     8 */
        struct logical_volume *    cow;                  /*    72     8 */
        struct dm_list             origin_list;          /*    80    16 */
        uint32_t                   chunk_size;           /*    96     4 */
        uint32_t                   region_size;          /*   100     4 */
        uint32_t                   extents_copied;       /*   104     4 */

        /* XXX 4 bytes hole, try to pack */

        struct logical_volume *    log_lv;               /*   112     8 */
        void *                     segtype_private;      /*   120     8 */
        /* --- cacheline 2 boundary (128 bytes) --- */
        struct dm_list             tags;                 /*   128    16 */
        struct lv_segment_area *   areas;                /*   144     8 */

        /* size: 152, cachelines: 3, members: 19 */
        /* sum members: 144, holes: 2, sum holes: 8 */
        /* last cacheline: 24 bytes */
};

with 64-bit status (alignment after reoragnizing):

$ pahole --show_reorg_steps --reorganize -C lv_segment metadata.o
/* Moving 'extents_copied' from after 'region_size' to after 'area_len' */
struct lv_segment {
        struct dm_list             list;                 /*     0    16 */
        struct logical_volume *    lv;                   /*    16     8 */
        const struct segment_type  * segtype;            /*    24     8 */
        uint32_t                   le;                   /*    32     4 */
        uint32_t                   len;                  /*    36     4 */
        uint64_t                   status;               /*    40     8 */
        uint32_t                   stripe_size;          /*    48     4 */
        uint32_t                   area_count;           /*    52     4 */
        uint32_t                   area_len;             /*    56     4 */
        uint32_t                   extents_copied;       /*    60     4 */
        /* --- cacheline 1 boundary (64 bytes) --- */
        struct logical_volume *    origin;               /*    64     8 */
        struct logical_volume *    cow;                  /*    72     8 */
        struct dm_list             origin_list;          /*    80    16 */
        uint32_t                   chunk_size;           /*    96     4 */
        uint32_t                   region_size;          /*   100     4 */
        struct logical_volume *    log_lv;               /*   104     8 */
        void *                     segtype_private;      /*   112     8 */
        struct dm_list             tags;                 /*   120    16 */
        /* --- cacheline 2 boundary (128 bytes) was 8 bytes ago --- */
        struct lv_segment_area *   areas;                /*   136     8 */

        /* size: 144, cachelines: 3, members: 19 */
        /* last cacheline: 16 bytes */
}


