From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 16 Jul 2009 16:53:58 -0400
Subject: Re: [PATCH 1/6] Add --dataalignmentoffset to pvcreate to pad aligned data area
In-Reply-To: <20090716151153.GD32757@agk-dp.fab.redhat.com>
References: <1247515882-13736-1-git-send-email-snitzer@redhat.com>
	<1247515882-13736-2-git-send-email-snitzer@redhat.com>
	<20090716151153.GD32757@agk-dp.fab.redhat.com>
Message-ID: <20090716205357.GB9005@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Jul 16 2009 at 11:11am -0400,
Alasdair G Kergon <agk@redhat.com> wrote:

> On Mon, Jul 13, 2009 at 04:11:17PM -0400, Mike Snitzer wrote:
> > When setting up the first mda, format-text.c:_mda_setup now sets the
> > pe_start to immediately follow the first mda (which ends at a pe_align
> > boundry).  data_alignment_offset will be added to pe_start if
> > --dataalignmentoffset was used.
>  
> The reason this cannot be reviewed easily is this:
> 
> > Index: LVM2/lib/format_text/format-text.c
> > ===================================================================
> > --- LVM2.orig/lib/format_text/format-text.c
> > +++ LVM2/lib/format_text/format-text.c
> > @@ -1175,6 +1175,7 @@ static int _text_scan(const struct forma
> >     Always have an mda between end-of-label and pe_align() boundary */
> >  static int _mda_setup(const struct format_type *fmt,
> >  		      uint64_t pe_start, uint64_t pe_end,
> > +		      unsigned long data_alignment_offset,
> >  		      int pvmetadatacopies,
> >  		      uint64_t pvmetadatasize, struct dm_list *mdas,
> >  		      struct physical_volume *pv,
> > @@ -1251,6 +1252,16 @@ static int _mda_setup(const struct forma
> >  			return 0;
> >  		}
> >  
> > +		if (!pe_start && !pe_end) {
> > +			/*
> > +			 * Set PV's pe_start to immediately follow the
> > +			 * first mda (which ends at a pe_align boundary)
> > +			 */
> > +			pv->pe_start = (start1 + mda_size1) >> SECTOR_SHIFT;
> > +			if (data_alignment_offset)
> > +				pv->pe_start += data_alignment_offset;
> > +		}
> > +
> >  		if (pvmetadatacopies == 1)
> >  			return 1;
> >  	} else
> 
> While the code already has elsewhere (_text_pv_write):
> 
>         /*
>          * If pe_start is still unset, set it to first aligned
>          * sector after any metadata areas that begin before pe_start.
>          */
>         if (!pv->pe_start)
>                 pv->pe_start = pv->pe_align;
> 
> 
> Further explanation is required to understand how both can be correct.

Yes, that code in _text_pv_write really has no place being in there
(that I can see); especially given that _text_pv_setup() also sets
pv->pe_start accordingly with:

                if (pe_start)
                        pv->pe_start = pe_start;
                ...
                if (pv->pe_start < pv->pe_align)
                        pv->pe_start = pv->pe_align;


If anything: that _text_pv_write being where it is makes that code quite
a bit more labored/awkward.. see the dm_list_iterate_items() loop that
follows the pv->pe_start initialization you shared above:

                        ...
                        pv->pe_start = (mdac->area.start + mdac->area.size)
                            >> SECTOR_SHIFT;
                        adjustment = pv->pe_start % pv->pe_align;
                        if (adjustment)
                                pv->pe_start += pv->pe_align -
                        adjustment;
                }

All those nuanced conditional checks (that preceed the _text_pv_write
code I just shared) really amount to "we need to place the pe_start
immediately after the first data area".  The setup path (_mda_setup) is
the more logical place to establish the start of the PV's data area.

But given the care that someone clearly put into all those
(undocumented) checks in _text_pv_write I thought I could still be
missing _why_ the pe_start needed to be established so late (in the
_text_pv_write path).  I'll take one more pass through it when I get
back (tracing all entry into _text_pv_write).  It could be safe to just
remove that code in _text_pv_write.

Mike


