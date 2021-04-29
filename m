From: Leo Yan <leo.yan@linaro.org>
Date: Thu, 29 Apr 2021 11:26:45 +0800
Subject: [LVM2 RFCv1 1/5] lvmlockd: idm: Introduce new locking scheme
In-Reply-To: <20210428195445.GF9566@redhat.com>
References: <20210425022241.5055-1-leo.yan@linaro.org>
	<20210425022241.5055-2-leo.yan@linaro.org>
	<20210428195445.GF9566@redhat.com>
Message-ID: <20210429032645.GB199698@leoy-ThinkPad-X240s>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Apr 28, 2021 at 02:54:45PM -0500, David Teigland wrote:
> On Sun, Apr 25, 2021 at 10:22:37AM +0800, Leo Yan wrote:
> > One thing should be mentioned is the IDM's LVB.  IDM supports LVB to max
> > 7 bytes when stores into the drive, the most significant byte of 8 bytes
> > is reserved for control bits.  For this reason, the patch maps the
> > timestamp in macrosecond unit with its cached LVB, essentially, if any
> > timestamp was updated by other nodes, that means the local LVB is
> > invalidate thus the metadata should be invlidated.  When the timestamp
> > is stored into drive's LVB, it's possbile to cause time-going-backwards
> > issue, which is introduced by the time precision or missing
> > synchronization acrossing over multiple nodes.  So the IDM wrapper fixes
> > up the timestamp by increment 1 to the latest value and write back into
> > drive.
> 
> While lvmlockd, sanlock, dlm are still using the LVB to track VG changes,
> it's not actually being used for anything any longer.  When lvm used
> lvmetad to cache metadata, we used the LVB to trigger lvmetad cache
> invalidation.  It's possible that this LVB functionality could be useful
> again in the future.

Thanks for reminding.  So I think it's good to keep LVB functionality
for IDM in lvmlockd, which allows IDM have the consistent supporting
with other locking schemes (sanlock and dlm), and maybe can be used
later as you said;  will update the commit log to reflect this.

As a side topic, just curious if LVM doesn't use LVB for invalidation
the cached metadata, then now LVM uses which mechanism for metadata
invalidation?  Sorry this question shows my lacking knowledge, but just
want to ensure I don't miss anything for the IDM enabling.

Thanks,
Leo


