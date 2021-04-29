From: Leo Yan <leo.yan@linaro.org>
Date: Thu, 29 Apr 2021 11:36:10 +0800
Subject: [LVM2 RFCv1 4/5] lib: locking: Parse PV list for IDM locking
In-Reply-To: <20210429031209.GA199698@leoy-ThinkPad-X240s>
References: <20210425022241.5055-1-leo.yan@linaro.org>
	<20210425022241.5055-5-leo.yan@linaro.org>
	<20210428193927.GE9566@redhat.com>
	<20210429031209.GA199698@leoy-ThinkPad-X240s>
Message-ID: <20210429033610.GC199698@leoy-ThinkPad-X240s>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Apr 29, 2021 at 11:12:09AM +0800, Leo Yan wrote:

[...]

> > > +	/*
> > > +	 * Create the VG's PV list when start the VG, the PV list
> > > +	 * is passed to lvmlockd, and the the PVs path will be used
> > > +	 * to send SCSI commands for idm locking scheme.
> > > +	 */
> > 
> > if vg->lock_type is IDM before creating pv_list?
> 
> Yes, IIUC, when start the VG, "vg->lock_type" has been assigned to the
> locking scheme which it's using; for IDM locking scheme, "vg->lock_type"
> is "idm" before creating pv_list.

No sure if I understand your question or not.  But I think you are
suggesting to check "vg->lock_type" is IDM and then create pv_list for
IDM type.  Will refine code for this.

Thanks,
Leo


