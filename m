From: David Teigland <teigland@redhat.com>
Date: Thu, 29 Apr 2021 10:31:39 -0500
Subject: [LVM2 RFCv1 1/5] lvmlockd: idm: Introduce new locking scheme
In-Reply-To: <20210429032645.GB199698@leoy-ThinkPad-X240s>
References: <20210425022241.5055-1-leo.yan@linaro.org>
	<20210425022241.5055-2-leo.yan@linaro.org>
	<20210428195445.GF9566@redhat.com>
	<20210429032645.GB199698@leoy-ThinkPad-X240s>
Message-ID: <20210429142122.GA27388@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Apr 29, 2021 at 11:26:45AM +0800, Leo Yan wrote:
> As a side topic, just curious if LVM doesn't use LVB for invalidation
> the cached metadata, then now LVM uses which mechanism for metadata
> invalidation?  

Every command reads metadata from disk, so there is no cache that needs to
be invalidated.  There is the /run/lvm/hints file, but that is not used
for shared VGs (it caches which devices on the system are LVM PVs).

> No sure if I understand your question or not.  But I think you are
> suggesting to check "vg->lock_type" is IDM and then create pv_list for
> IDM type.  Will refine code for this.

Yes that's what I was thinking, thanks.

Dave


