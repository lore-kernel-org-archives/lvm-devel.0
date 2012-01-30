From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 30 Jan 2012 09:30:48 -0500
Subject: [dm-devel] [linux-lvm] ??????: New LVM2 release 2.02.89: Thinly-provisioned logical?volumes
In-Reply-To: <20120130094336.GA4264@ubuntu>
References: <20120127025701.GB16767@agk-dp.fab.redhat.com>
	<A0D9F519724C4648B433C8FA859E3EBB7CD0390C@EX01.sogou-inc.com>
	<20120130094336.GA4264@ubuntu>
Message-ID: <20120130143048.GA11766@infradead.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Jan 30, 2012 at 09:43:37AM +0000, Joe Thornber wrote:
> On Mon, Jan 30, 2012 at 06:29:54AM +0000, Kirby Zhou wrote:
> > Can the thinly-provisioned logical volume automatically return its owned space to the pool?
> > I mean, if I create a huge file on the logical volume, then delete it, will the logical volume actual space size be reduced automatically?
> > If not, how can it be shrinked?
> 
> 
> Discard support is currently in testing.  Should go upstream soon.

Note that you'll also need filesystem support for that, too.  Currently
no filesystem enables online discard by default, and at least directly
on SSDs the impact is rather bad on all Linux filesystems.


