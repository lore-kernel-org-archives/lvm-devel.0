From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 15 Jan 2008 16:56:24 +0000
Subject: [PATCH 2/11] Add upward link from underlying LV to stacked seg
In-Reply-To: <478CE1B1.4070004@ce.jp.nec.com>
References: <4787FA27.8050300@ce.jp.nec.com> <4787FF72.9000400@ce.jp.nec.com>
	<20080114225345.GG8075@agk.fab.redhat.com>
	<478CE1B1.4070004@ce.jp.nec.com>
Message-ID: <20080115165624.GO8075@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Jan 15, 2008 at 11:39:13AM -0500, Jun'ichi Nomura wrote:
> How about this?
>   add_seg_to_segs_using_this_lv(lv, seg)
>   remove_seg_from_segs_using_this_lv(lv, seg)
> 
> Or this?
>   add_parent_seg(lv, seg)
>   remove_parent_seg(lv, seg)

Not sure.  Still thinking.
 
> > +struct lv_segment *seg_using_lv(struct logical_volume *lv)

> Returning NULL is valid if the list is empty.

What I mean is: why would the list be empty if that function
is being called?  If the list was known to be empty, you
wouldn't be in a code path that called the function, surely?
IOW it's a coding error if 'return NULL' is hit.
Or does the function have a secondary use to find out whether
the LV is at the top of the stack?
Is it better split into two?  First an is_ function to find out
if the segment is the type expected with a single segment; then the function to
give details of the one-and-only segment?

> > Where is this new list validated?
> Some validation were included in the tests using find_mirror_seg().
> I'll add generic ones.
 
I mean the validation in the vg_write() path must have independent
validity checks so we never write out the metadata if there's
an internal inconsistency in it.  IOW it must be done somewhere under
vg_validate().  IOW the pointers must be validated in both directions:
all existing list elements are correct (and not duplicated), and no
elements are missing from the list.

Alasdair
-- 
agk at redhat.com


