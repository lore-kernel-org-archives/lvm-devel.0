From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 16 Jul 2009 17:00:42 -0400
Subject: Re: [PATCH 2/6] Add devices/data_alignment_offset_detection to lvm.conf.
In-Reply-To: <4A5F75CC.8060203@redhat.com>
References: <1247515882-13736-1-git-send-email-snitzer@redhat.com>
	<1247515882-13736-3-git-send-email-snitzer@redhat.com>
	<4A5F75CC.8060203@redhat.com>
Message-ID: <20090716210041.GC9005@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Jul 16 2009 at  2:47pm -0400,
Milan Broz <mbroz@redhat.com> wrote:

> Mike Snitzer wrote:
> > +	if (dm_snprintf(path, PATH_MAX, "%s/dev/block/%d:%d/%s",
> > +			sysfs_dir, MAJOR(dev->dev), MINOR(dev->dev),
> > +			attribute) < 0) {
> > +		log_error("dm_snprintf %s failed", attribute);
> > +		return 0;
> > +	}
> >
> >   
> this segfaults here on 32bit...

Odd.. I mean is it obvious to you _why_ that would be the case?

Thanks for your fix.

Mike


