From: Lakshmi Narasimhan Sundararajan <lns@portworx.com>
Date: Wed, 31 Jul 2019 17:09:45 +0530
Subject: Reg unusual deployment within containers
In-Reply-To: <dad69ab9-0788-26da-bef7-44afb00e59c3@redhat.com>
References: <5d404562.1c69fb81.4641c.47b2@mx.google.com>
	<dad69ab9-0788-26da-bef7-44afb00e59c3@redhat.com>
Message-ID: <5d417e00.1c69fb81.f3832.9a9d@mx.google.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thank you Zdenek for your response. Your inputs do help us understand this better.

Best regards
LN
Sent from Mail for Windows 10

From: Zdenek Kabelac
Sent: Wednesday, July 31, 2019 4:24 PM
To: LVM2 development; Lakshmi Narasimhan Sundararajan
Subject: Re: Reg unusual deployment within containers

Dne 30. 07. 19 v 15:25 Lakshmi Narasimhan Sundararajan napsal(a):
> Hi Team,
> 
> Thanks for being so prompt last time, I wanted to see whether I could be lucky 
> again ?
> 
> My deployment of lvm2 is in an uncontrolled environment, so the host can be 
> running any version.
> 
> My software stack runs within a container, as an infrastructure. So to be 
> always stable, it has to have very little dependency or moving components outside.

It's worth to note (before you start to ask) that lvm2  does NOT support usage
within containers.

When you do such solution - you need to resolve lots of tricky issues and 
adapt usage to your local limited constrains.

But there is no 'generic' support for running lvm2 command within i.e. docker 
image.

> 
> The first up easy question:
> 1/ can lvm2 be built as a static binary with no external dependency? Any 
> pointers to this ?

Nope - there is no static binary support for a long time.

The key issue is - lot of things these days depends on udev (&systemd behind).

So any static build of lvm2 with built-in udev/systemd libraries is not going 
to works since the last thing systemd cares about is 'future' compatibility.
We try to do that in lvm2 - which is much smaller project and it's very hard.

So you can't expect 'static' builds to appear in this dynamic environment -
it would be big challenging task on it's own....


> 2/? The software stack bundles lvm2 package within the infrastructure 
> container as well.

Well - we do NOT support this. All these builds do their own hacking.
It's all done without any support from lvm2 side.

> So I wish to understand the impact of the above bundling, with possibly two 
> copies of daemons and cache and udev running within/and outside the container.

We wish to understand this as well :)

It simply can't work - and we tell this to any container developer who asks...


> Please do let me know if this bundle approach is a feasible approach to take 
> to production? What possible issues that may come up that cannot be handled 
> correctly, if any. ?I am coming more from design validation, because you are 
> the experts with how its designed internally. Looking forward to hearing your 
> opinions.

Properly configured lvm2 is bound to installed system - which present 
installed kernel version, udev, systemd and other surrounding apps.

We don't understand how anyone is imagining, he can use 'random' i.e. Docker 
image with random instance of lvm2 within image, no udev processing and lots 
of other things missing and expects all will work...

So you need to ask these question authors of those project ;) since we really 
would like to know these answers ourself ;)

So far we can only advice using of lvm2 within VM  (i.e. qemu)...

IMHO lot of developers these days believe that container is just 'faster VM',
and they have no idea how wrong they are...

Regards

Zdenek

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190731/8223229f/attachment.htm>
