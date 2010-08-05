From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 5 Aug 2010 16:49:38 -0500
Subject: [PATCH] Specified PVs being ignored when performing mirror split (bug 619221)
In-Reply-To: <5C30BE7ED8B03E448B2E104602D4848A59228865E3@USINDEVS02.corp.hds.com>
References: <5C30BE7ED8B03E448B2E104602D4848A59228865E3@USINDEVS02.corp.hds.com>
Message-ID: <5918B730-E0D8-4B4E-BCC4-D5F9E2143438@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Whether my patch works or not may be irrelevant if your patch is  
better.  I had considered going through the list backwards to save  
some processing, but decided to go with the other method...  If this  
works equally well, let's do it this way instead, yes?

  brassow

On Aug 5, 2010, at 4:31 PM, Takahiro Yasui wrote:

> However, if the answer is no, we need to update the patch, for  
> example, as
> follows.
>
> static int _move_removable_mimages_to_end(struct logical_volume *lv,
>                                          uint32_t count,
>                                          struct dm_list  
> *removable_pvs)
> {
>        struct logical_volume *sub_lv;
>        struct lv_segment *mirrored_seg = first_seg(lv);
>        int i;
>
>        if (!removable_pvs)
>                return 1;
>
>        for (i = mirrored_seg->area_count - 1; i >= 0; i--) {
>                sub_lv = seg_lv(mirrored_seg, i);
>                if (!is_temporary_mirror_layer(sub_lv) &&
>                    is_mirror_image_removable(sub_lv, removable_pvs)) {
>                        if (!shift_mirror_images(mirrored_seg, i))
>                                return_0;
>                        if (!--count)
>                                break;
>                }
>        }
>
>        return !count;
> }


