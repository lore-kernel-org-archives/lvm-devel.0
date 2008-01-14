From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 14 Jan 2008 22:39:20 +0000
Subject: [PATCH 2/11] Add upward link from underlying LV to stacked seg
In-Reply-To: <4787FF72.9000400@ce.jp.nec.com>
References: <4787FA27.8050300@ce.jp.nec.com> <4787FF72.9000400@ce.jp.nec.com>
Message-ID: <20080114223920.GF8075@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jan 11, 2008 at 06:44:50PM -0500, Jun'ichi Nomura wrote:
> Stacking is done like this:
>    +--------------------------+
>    |          LV0             |
>    +--------------------------+
>    |SEG01|SEG02|SEG03| ...    |
>    +--------------------------+
>    |          LV1             |
>    +--------------------------+
>    |SEG11|SEG12|SEG13| ...    |
>    +--------------------------+
> (This figure might be over simplified.
>  The LV-LV relationship is not necessarily 1:1.
>  The point is they are stacked as lv-seg-lv-seg-...)
 
The picture is confusing:
There is no 1:1 mapping from SEG0x to SEG1x as the picture suggests.
One upper LV segment may use an arbitrary number of LV segments below it.
This is not like the lv segment to pv segment mappings.
- Whereas PV segments can be split arbitrarily to maintain the
simple mappings, LV segments *cannot* in general be split on demand.
(This of the complexity involved in splitting a snapshot segment, for example!)

> Downward links:
>   - lv-to-seg (e.g. LV0 -> SEG0x, LV1 -> SEG1x) => lv->segments 
>   - seg-to-lv (e.g. SEG0x -> LV1)               => seg_lv(seg, s)

where s is the index of the area (stripe)

> Upward links:
>   - lv-to-seg (e.g. LV1 -> SEG0x)               => N/A
>   - seg-to-lv (e.g. SEG0x -> LV0, SEG1x -> LV1) => seg->lv
 
> This patch adds lv-to-seg upward link, lv->segs_using_this_lv.
> The patch also replaces seg->mirror_seg with this.

Yes.

> For segment areas, the linking/unlinkg of the LV to the seg is
> automatically done with set_lv_segment_area_lv()/release_lv_segment_area().
> For other relation ships (e.g. log_lv), the linking/unlinking should done
> explicitly using lv_add_user_seg()/lv_remove_user_seg().
 
We need to rename that - 'user_seg' could mean something else.

Alasdair
-- 
agk at redhat.com


