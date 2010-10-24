From: Mike Snitzer <snitzer@redhat.com>
Date: Sun, 24 Oct 2010 13:28:40 -0400
Subject: [RFC][PATCH] never scan a device which is using the error target
In-Reply-To: <4CC4623D.7080505@redhat.com>
References: <20101024005515.GA31723@redhat.com> <4CC4623D.7080505@redhat.com>
Message-ID: <20101024172840.GA2384@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Oct 24 2010 at 12:43pm -0400,
Milan Broz <mbroz@redhat.com> wrote:

> On 10/24/2010 02:55 AM, Mike Snitzer wrote:
> > A merged snapshot's DM device is made to use the "error" target as part
> > of lvm's transaction to merge a snapshot.  This snapshot merge use-case
> > aside, any device using the error target shouldn't be scanned.
> > 
> > NOTE: I'm not using an ignore_suspended_devices() check like other
> > target checks in device_is_usable() -- its not clear to me what such a
> 
> IIRC scan for mirrors, snapshots etc is OK.
> But during mirror repair or conversion some devices in the middle of stack
> can be suspended, so the ignore_suspended_devices() says when it is safe to
> scan it. (see that it is set during conversions etc)
> IMHO it is quite hack (mainly for clusters where one node runs the conversion
> or repair and other just follows the state).

OK, thanks for the info.

> For error device it makes no sense - it is unusable all the time:-)

Right.

> > +		if (target_type && !strcmp(target_type, "error")) {
> 
> Do we have some #define for the error target name?

I don't think we have a #define for any target names.  Target names are
open coded strings throughout the lvm2 codebase.  Certainly a candidate
for cleanup.

> Anyway, ack.

Thanks,
Mike


