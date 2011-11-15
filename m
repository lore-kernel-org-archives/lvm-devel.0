From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 15 Nov 2011 09:11:32 -0500
Subject: [PATCH 0/5] Check for resized smaller devices, v1, rhbz753914
In-Reply-To: <20111114215545.GL4396@agk-dp.fab.redhat.com>
References: <1321305181-28158-1-git-send-email-dwysocha@redhat.com>
	<20111114215545.GL4396@agk-dp.fab.redhat.com>
Message-ID: <1321366292.1790.27.camel@f14-work>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2011-11-14 at 21:55 +0000, Alasdair G Kergon wrote:
> There are circumstances where sizes don't match and it's OK.
> There are circumstances where sizes don't match and it's not OK.
> 
> Warn, prompt or abort?
> 
"sizes don't match" is a larger scope than what I was trying to tackle.

I don't think pv_size should ever be larger than dev_size, and today it
causes strange failures with things like lvcreate.

However, it's perfectly fine for pv_size to be be smaller than dev_size
(no LVM problems result).

> vg_validate is really about the internal consistency of the metadata,
> and I hesitate to extend it to check the underlying devices.
> 

Ok, that's reasonable to say vg_validate is restricted to internal
checks.  I was not sure exactly where we should call it.

> It's not a particularly cheap check either.
> It shouldn't be done while any devices are suspended.
> 
Yeah, and in probably 95% of times the check will pass so it's just
overhead.  This would argue for restricting the check to something like
pvck or vgck.

What do you think about calling from pvck / vgck for now?


> A flag in each PV to say to ignore a size mismatch on an individual PV,
> controlled with pvchange and set when --setphysicalvolumesize overrides
> it, or alternatively just a single global lvm.conf setting?
> 

I would hope to not have to implement another flag or option but it may
be necessary.


> Cache the sizes during the standard scanning we already do, perhaps and
> then check on (just the first?) vg read?  Re-check next time VG lock is
> acquired?  (Hook into VG cache this way?)
> 

I'll have to look into the scope of these types of changes.  At a high
level, it seems a reasonable approach, and may even improve performance.


