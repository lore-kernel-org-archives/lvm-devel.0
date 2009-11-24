From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 24 Nov 2009 08:21:25 -0500
Subject: Re: data alignment of structures with 'status'
In-Reply-To: <20091123234425.GE26546@agk-dp.fab.redhat.com>
References: <20091123232344.GA16119@redhat.com>
	<20091123234425.GE26546@agk-dp.fab.redhat.com>
Message-ID: <20091124132123.GA30655@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Nov 23 2009 at  6:44pm -0500,
Alasdair G Kergon <agk@redhat.com> wrote:

> On Mon, Nov 23, 2009 at 06:23:45PM -0500, Mike Snitzer wrote:
> > /* Moving 'extents_copied' from after 'region_size' to after 'area_len' */
> > struct lv_segment {
> >         struct dm_list             list;                 /*     0    16 */
> >         struct logical_volume *    lv;                   /*    16     8 */
> >         const struct segment_type  * segtype;            /*    24     8 */
> >         uint32_t                   le;                   /*    32     4 */
> >         uint32_t                   len;                  /*    36     4 */
> >         uint64_t                   status;               /*    40     8 */
> >         uint32_t                   stripe_size;          /*    48     4 */
> >         uint32_t                   area_count;           /*    52     4 */
> >         uint32_t                   area_len;             /*    56     4 */
> 
> >         uint32_t                   extents_copied;       /*    60     4 */
> 
> But it doesn't logically fit there - it's a mirror field not an all-areas one
> or a snapshot one.  I'm only arguing for packing things efficiently
> if it can be done while keeping groups of related fields together (and
> normally it can be).
> 
> How about moving chunk_size from the end of the group of snapshot fields
> to the front instead?  I.e. rotating 3 uint32_t fields in what you've posted
> here.

Your chunk_size suggestion works perfectly.  I'll run with that.

Mike


