From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 17 Dec 2008 16:05:44 -0500
Subject: [LVM2 PATCH] libdm: Fail to add tree node when requested major/minor is used.
In-Reply-To: <49494F06.5040905@redhat.com>
References: <494930F1.1030607@redhat.com>
	<1229538037.28164.13.camel@localhost.localdomain>
	<49494F06.5040905@redhat.com>
Message-ID: <1229547944.28164.16.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Wed, 2008-12-17 at 20:12 +0100, Milan Broz wrote:
> Dave Wysochanski wrote:
> > Should we be ignoring --major on the lvcreate cmdline, overriding it, or
> > is there another bug?
> 
> That's another bug - in 2.6 kernel is setting of major number not supported yet.
> (It worked in lvm1 & 2.4)
> 
> See https://bugzilla.redhat.com/show_bug.cgi?id=204997
> 
> But for metadata we need store both...

Ok - your patch seems fine for the bz you reported.

Ack.


