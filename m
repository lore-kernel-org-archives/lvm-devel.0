From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 4 Dec 2014 10:43:24 -0500
Subject: dm thin: optimize away writing all zeroes to unprovisioned blocks
In-Reply-To: <20141204153358.GA19315@redhat.com>
References: <alpine.DEB.2.00.1409301121470.26721@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032237010.12556@ware.dreamhost.com>
	<alpine.DEB.2.02.1412032318290.29609@ware.dreamhost.com>
	<20141204153358.GA19315@redhat.com>
Message-ID: <20141204154324.GB19315@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Dec 04 2014 at 10:33am -0500,
Mike Snitzer <snitzer@redhat.com> wrote:
 
> > diff --git a/drivers/md/dm-thin.c b/drivers/md/dm-thin.c
> > index fc9c848..71dd545 100644
> > --- a/drivers/md/dm-thin.c
> > +++ b/drivers/md/dm-thin.c
> > @@ -1230,6 +1230,42 @@ static void process_shared_bio(struct thin_c *tc, struct bio *bio,
> >  	}
> >  }
> 
> A helper like this really belongs in block/bio.c:
> 
> > +/* return true if bio data contains all 0x00's */
> > +bool bio_all_zeros(struct bio *bio) +{
> > +	unsigned long flags;
> > +	struct bio_vec bv;
> > +	struct bvec_iter iter;
> > +
> > +	char *data;
> > +	uint64_t *p;
> > +	int i, count;
> > + +	bool allzeros = true;
> > +
> > +	bio_for_each_segment(bv, bio, iter) {
> > +		data = bvec_kmap_irq(&bv, &flags);
> > +
> > +		p = (uint64_t*)data;
> > +		count = bv.bv_len / sizeof(uint64_t);
> 
> Addressing a bio's contents in terms of uint64_t has the potential to
> access beyond bv.bv_len (byte addressing vs 64bit addressing).  I can
> see you were just looking to be more efficient about checking the bios'
> contents but I'm not convinced it would always be safe.

Actually, given your: count = bv.bv_len / sizeof(uint64_t);

My immediate concern was it would've truncated any partial contents of
the bio_vec beyond the last uint64_t boundary.  Leading to possible
false positive return from the function (because some contents weren't
checked).


