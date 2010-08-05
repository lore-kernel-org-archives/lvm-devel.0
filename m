From: Takahiro Yasui <takahiro.yasui@hds.com>
Date: Thu, 5 Aug 2010 17:31:56 -0400
Subject: [PATCH] Specified PVs being ignored when performing mirror split (bug 619221)
Message-ID: <5C30BE7ED8B03E448B2E104602D4848A59228865E3@USINDEVS02.corp.hds.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Jon,

On 08/04/10 18:51, Jonathan Brassow wrote:
...
> This patch reverses the aforementioned check-in (solving the regressions)
> and posits a new solution to the list reversal problem.  The original
> problem was that we would always take the lowest mimage LVs from a mirror
> when performing a split, but what we really want is to take the highest
> mimage LVs.  This patch accomplishes that by simply not short-circuiting
> the processing done in _move_removable_mimages_to_end.  This function
> would start from the beginning of the mirror sub-lv list and work its
> way to the end - quiting when it found just enough to cover the requested
> amount.  This would always leave the least desirable LVs to be removed
> at the end of the list.

If I understand correctly, the expected result with the following examples are:

* Mirror volume (vg/org) consists of legs A (sda), B (sdb), C (sdc) and D (sdd)

(1) lvconvert --splitmirrors 1 --name new vg/org
    vg/org: Mirror volume consists of legs A, B, and C    (leg A is primary)
    vg/new: Linear volume consists of D

(2) lvconvert --splitmirrors 2 --name new vg/org
    vg/org: Mirror volume consists of legs A and B      (leg A is primary)
    vg/new: Mirror volume consists of legs C and D

(3) lvconvert --splitmirrors 1 --name new vg/org /dev/sda
    vg/org: Mirror volume consists of legs B, C and D    (leg B is primary)
    vg/new: Linear volume consists of A

(4) lvconvert --splitmirrors 2 --name new vg/org /dev/sda /dev/sdb
    vg/org: Mirror volume consists of legs C and D    (leg C is primary)
    vg/new: Mirror volume consists of legs A and B

(5) lvconvert --splitmirrors 1 --name new vg/org /dev/sda /dev/sdb
    vg/org: Mirror volume consists of legs A, C and D    (leg A is primary)
    vg/new: Linear volume consists of B

Without a PV list in the command line, your patch works well. The new logic
desn't change the order of mirror volumes because
_move_removable_mimages_to_end() reorders all mirror legs and generates
the same order as original.

With a PV list in the command line, on the other hand, this logic shifts mirror
legs more than needed. For example, a user wants to split vg/new (linear)
from vg/org and specifies /dev/sda and /dev/sdb as removable PVs.
In this case, the structure of vg/org is changed as follows.

# lvconvert --splitmirrors 1 --name new vg/org /dev/sda /dev/sdb
    vg/org: Mirror volume consists of legs C, D and A   (leg C is primary)
    vg/new: Linear volume consists of B

Is this change OK? If the answer is yes, I just ask you to change the comments
of _move_removable_mimages_to_end().

/*                                                                                                               
 * _move_removable_mimages_to_end                                                                                
 *                                                                                                               
 * We always detach mimage LVs from the end of the areas array.                                                  
 * This function will push 'count' mimages to the end of the array                                               
 * based on if their PVs are removable.                                                                          
 *                                                                                                               
 * This is an all or nothing function.  Either the user specifies                                                
 * enough removable PVs to satisfy count, or they don't specify                                                  
 * any removable_pvs at all (in which case all PVs in the mirror                                                 
 * are considered removable).                                                                                    
 */


However, if the answer is no, we need to update the patch, for example, as
follows.

static int _move_removable_mimages_to_end(struct logical_volume *lv,
                                          uint32_t count,
                                          struct dm_list *removable_pvs)
{
        struct logical_volume *sub_lv;
        struct lv_segment *mirrored_seg = first_seg(lv);
        int i;

        if (!removable_pvs)
                return 1;

        for (i = mirrored_seg->area_count - 1; i >= 0; i--) {
                sub_lv = seg_lv(mirrored_seg, i);
                if (!is_temporary_mirror_layer(sub_lv) &&
                    is_mirror_image_removable(sub_lv, removable_pvs)) {
                        if (!shift_mirror_images(mirrored_seg, i))
                                return_0;
                        if (!--count)
                                break;
                }
        }

        return !count;
}

Thanks,
Taka


