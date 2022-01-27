From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Thu, 27 Jan 2022 16:02:35 +0530
Subject: Reg a deadlock specific to our environment
In-Reply-To: <20220126164023.GA29106@redhat.com>
References: <CAFe+wq18h3W3DwmR-n6v=0cPm4XgiwRsjkq4260uRYyNhAx9Aw@mail.gmail.com>
	<20220113145226.GA436@redhat.com>
	<CAFe+wq1yJG-QymJg_uT6+yEU3f0Ua5MEXaKpSEZRmDcPTMXt5w@mail.gmail.com>
	<20220126164023.GA29106@redhat.com>
Message-ID: <CAFe+wq3z_oAiEujS=Gcx8GRCSBWHiei26ArGNF0HeH1+4jUB2Q@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jan 26, 2022 at 10:10 PM David Teigland <teigland@redhat.com> wrote:

> On Wed, Jan 26, 2022 at 06:41:07PM +0530, Lakshmi Narasimhan Sundararajan
> wrote:
> > From the code, all commands that internally does vg_open() gets stuck.
>
> vg_open() sounds like the old liblvm2app, is there a program you've
> written using that library?  That lib was seriously flawed, so you're
> unlikely to get it to work well.  It was dropped some years ago now.
> We can take a brief look at the debug output to see if there's any
> obvious workaround for whatever is blocking it.
>
>
Yes, i highlighted vg_open() by reading the code. I understand that the
code path is deprecated now and should not side line from the obvious
problem.
The logs I posted was directly using lvm cli, it had nothing to do with the
liblvm2app.
So the problem still exists and the workaround I posted wherein a pxd
filter, takes out all pxd devices during vg handlings helps recover from
this.

Secondly, it looks like any vg processing, first builts a lvm disk device
cache by reading from a list of block devices. Those block devices include
all dm devices,
which includes dm-crypt whose parent is a virtual pxd device in this
particular case. That read gets blocked forever without the application
being alive.
So a global pxd filter seemed like a good approach and it worked for us.

I definitely would like to hear from you all, as to any better way to
recover from this situation. Please also see if the pxd filter that I
posted earlier makes sense now, given that there is additional information
that I posted that should have clarified the scenario further.

Looking forward to your response.

Thanks

Dave
>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20220127/1964ac9b/attachment.htm>
