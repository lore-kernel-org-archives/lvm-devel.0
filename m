From: David Teigland <teigland@redhat.com>
Date: Wed, 28 Apr 2021 14:54:45 -0500
Subject: [LVM2 RFCv1 1/5] lvmlockd: idm: Introduce new locking scheme
In-Reply-To: <20210425022241.5055-2-leo.yan@linaro.org>
References: <20210425022241.5055-1-leo.yan@linaro.org>
	<20210425022241.5055-2-leo.yan@linaro.org>
Message-ID: <20210428195445.GF9566@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Apr 25, 2021 at 10:22:37AM +0800, Leo Yan wrote:
> One thing should be mentioned is the IDM's LVB.  IDM supports LVB to max
> 7 bytes when stores into the drive, the most significant byte of 8 bytes
> is reserved for control bits.  For this reason, the patch maps the
> timestamp in macrosecond unit with its cached LVB, essentially, if any
> timestamp was updated by other nodes, that means the local LVB is
> invalidate thus the metadata should be invlidated.  When the timestamp
> is stored into drive's LVB, it's possbile to cause time-going-backwards
> issue, which is introduced by the time precision or missing
> synchronization acrossing over multiple nodes.  So the IDM wrapper fixes
> up the timestamp by increment 1 to the latest value and write back into
> drive.

While lvmlockd, sanlock, dlm are still using the LVB to track VG changes,
it's not actually being used for anything any longer.  When lvm used
lvmetad to cache metadata, we used the LVB to trigger lvmetad cache
invalidation.  It's possible that this LVB functionality could be useful
again in the future.

Dave


