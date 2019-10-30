From: David Teigland <teigland@redhat.com>
Date: Wed, 30 Oct 2019 09:07:01 -0500
Subject: Performance regression between V2_02_177 and V2_02_180
In-Reply-To: <1572428091306.94800@citrix.com>
References: <1571324396950.37136@citrix.com> <1572338679419.1072@citrix.com>
	<20191029145802.GA25248@redhat.com>
	<1572428091306.94800@citrix.com>
Message-ID: <20191030140701.GA15378@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Oct 30, 2019 at 09:34:51AM +0000, Ben Sims wrote:
> I have not observed any contention directly but the comment in the commit
> 
>     "ca66d520326493311a3c7132b1bcee0807862301
> 
>     io: use sync io if aio fails
>     
>     io_setup() for aio may fail if a system has reached the
>     aio request limit.  In this case, fall back to using sync io..." 
> 
> implies that aio is a resource with a limit and open for contention. I
> observed heavy background aio traffic with perf probes from our virtual
> disk backends, I don't believe the io_submit calls in LVM are blocking
> as they are submitted with O_DIRECT and strace time to return is low.

OK, I thought you were referring to contention that would cause lvm's
async io to suffer, as opposed to simply being unavailable.  If other
programs are consuming all of the available aio, then you can increase
/proc/sys/fs/aio-max-nr, which would hopefully make some available for
lvm.

> This may off course be academic if lvm moves to io_uring. Have there
> been any experiments in this area?

No, but it does sound interesting.  I should check if the userspace
library for that has matured.

Dave


