From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 15 Jan 2008 14:54:40 -0500
Subject: [PATCH 2/11] Add upward link from underlying LV to stacked seg
In-Reply-To: <20080115165624.GO8075@agk.fab.redhat.com>
References: <4787FA27.8050300@ce.jp.nec.com>
	<4787FF72.9000400@ce.jp.nec.com>	<20080114225345.GG8075@agk.fab.redhat.com>	<478CE1B1.4070004@ce.jp.nec.com>
	<20080115165624.GO8075@agk.fab.redhat.com>
Message-ID: <478D0F80.6080207@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon wrote:
> On Tue, Jan 15, 2008 at 11:39:13AM -0500, Jun'ichi Nomura wrote:
>>> +struct lv_segment *seg_using_lv(struct logical_volume *lv)
> 
>> Returning NULL is valid if the list is empty.
> 
> What I mean is: why would the list be empty if that function
> is being called?  If the list was known to be empty, you
> wouldn't be in a code path that called the function, surely?
> IOW it's a coding error if 'return NULL' is hit.

Ah, I understand now.
If it returns NULL, there should be internal error in LVM2 code.

> Or does the function have a secondary use to find out whether
> the LV is at the top of the stack?
> Is it better split into two?  First an is_ function to find out
> if the segment is the type expected with a single segment; then the function to
> give details of the one-and-only segment?

I don't think we need to split it.
If a code calls seg_using_lv(lv), it knows the lv should have
one-and-only user (upper-level) segment.
If the lv doesn't, it's a coding error.

Maybe it's handy to have a wrapper for !list_empty(&lv->segs_using_this_lv)
to check if the LV is top-level or not.
  int is_top_of_the_stack(lv) {
    return list_empty(lv->segs_using_this_lv);
  }

>>> Where is this new list validated?
>> Some validation were included in the tests using find_mirror_seg().
>> I'll add generic ones.
>  
> I mean the validation in the vg_write() path must have independent
> validity checks so we never write out the metadata if there's
> an internal inconsistency in it.  IOW it must be done somewhere under
> vg_validate().  IOW the pointers must be validated in both directions:
> all existing list elements are correct (and not duplicated), and no
> elements are missing from the list.

I'll add that type of validation check.

Duplication is currently allowed since 2 areas in a segment
can be on the same LV.

-- 
Jun'ichi Nomura, NEC Corporation of America


