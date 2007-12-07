From: Heinz Mauelshagen <mauelshagen@redhat.com>
Date: Fri, 7 Dec 2007 12:49:54 +0100
Subject: [PATCH pvmove 0/6] Refactoring pvmove with generic APIs
In-Reply-To: <475825EF.6000803@ce.jp.nec.com>
References: <475825EF.6000803@ce.jp.nec.com>
Message-ID: <20071207114954.GA6313@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Nick,

it would be better to make this more generic.

Ie. convert_segments(struct lvm_conversion_handler *handler, ...)
rather than having a per target conversion function.

Heinz


On Thu, Dec 06, 2007 at 11:40:15AM -0500, Jun'ichi Nomura wrote:
> Hi,
> 
> This patchset is a follow up to the previous post:
> https://www.redhat.com/archives/lvm-devel/2007-November/msg00034.html
> 
> This version introduces 3 APIs and let pvmove use them:
>   - insert_layer_for_segments_on_pv()
>       Insert a layer (a linear lv segment) below each lv segment
>       of the LV, only when the segment is on a specified PV.
>   - convert_segments_mirrored()
>       Convert each segment in the LV to mirrored.
>   - split_parent_segments()
>       For a given layer LV, walk through LVs in the VG and split
>       any LV segment whose underlying layer segment is splitted.
> 
> I'm trying to add functionality for lvconvert, i.e. mirroring
> as a whole LV, not segment by segment.
> However, it involves moving some codes from toollib to lib and
> I think further discussion may be necessary.
> And anyway they will be an addition to this patchset.
> 
> So I'm posting this set first as they are stable and easy to review.
> 
> [1/6] add insert_layer_for_segments_on_pv()
> [2/6] add convert_segments_mirrored()
> [3/6] add split_parent_segments()
> [4/6] change pvmove to use the generalized APIs
> [5/6] remove unused mirrored_pv/mirrored_pe params from internal code
> [6/6] remove unused can_split param from allocate_extents()
> [Appendix] pvmove test script for 'make check'
> 
> Thanks,
> -- 
> Jun'ichi Nomura, NEC Corporation of America
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel

-- 

Regards,
Heinz    -- The LVM Guy --

*** Software bugs are stupid.
    Nevertheless it needs not so stupid people to solve them ***

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Heinz Mauelshagen                                 Red Hat GmbH
Consulting Development Engineer                   Am Sonnenhang 11
Storage Development                               56242 Marienrachdorf
                                                  Germany
Mauelshagen at RedHat.com                            PHONE +49  171 7803392
                                                  FAX   +49 2626 924446
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-


