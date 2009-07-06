From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 6 Jul 2009 13:14:49 -0400
Subject: Re: [PATCHi v2 1/5] Update 'md_chunk_alignment' to use stripe-width to align PV data
In-Reply-To: <20090706104737.GB11082@agk-dp.fab.redhat.com>
References: <1246847990-13370-1-git-send-email-snitzer@redhat.com>
	<1246847990-13370-2-git-send-email-snitzer@redhat.com>
	<20090706104737.GB11082@agk-dp.fab.redhat.com>
Message-ID: <20090706171448.GA17118@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Jul 06 2009 at  6:47am -0400,
Alasdair G Kergon <agk@redhat.com> wrote:

> On Sun, Jul 05, 2009 at 10:39:46PM -0400, Mike Snitzer wrote:
> > +static unsigned long dev_md_chunk_size(const char *sysfs_dir,
> > +				       struct device *dev)
> 
> > +	if (!(fp = md_sysfs_fopen(sysfs_dir, dev, attribute)))
> > +		return 0;
> 
> > -		log_sys_error("fgets", path);
> > +		log_sys_error("fgets", attribute);
> 
> Please reinstate the variable contextual information in these messages.
> (sysfs_dir, dev, md are all now missing - return 'path' to the caller
> of the customised fopen, or create the path in a separate fn first
> and pass it in?)

Done.

> > +static int dev_md_level(const char *sysfs_dir, struct device *dev)
> > +static int dev_md_raid_disks(const char *sysfs_dir, struct device *dev)
> > +unsigned long dev_md_stripe_width(const char *sysfs_dir, struct device *dev)
> 
> Is there more code that could be shared between these functions?

Yes, I ended up sharing a bit more.

> > +	data_disks = raid_disks - (level == 0 ? 0 : (level <= 5 ? 1 : 2));
> Add a comment before that line explaining it.

Turns out the above logic completely mishandled raid1.  I reworked the
above into a proper switch statement with comments.

> Ack

Thanks for the review,
Mike


