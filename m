From: Milan Broz <mbroz@redhat.com>
Date: Wed, 17 Dec 2008 20:12:06 +0100
Subject: [LVM2 PATCH] libdm: Fail to add tree node when requested major/minor is used.
In-Reply-To: <1229538037.28164.13.camel@localhost.localdomain>
References: <494930F1.1030607@redhat.com>
	<1229538037.28164.13.camel@localhost.localdomain>
Message-ID: <49494F06.5040905@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski wrote:
> Should we be ignoring --major on the lvcreate cmdline, overriding it, or
> is there another bug?

That's another bug - in 2.6 kernel is setting of major number not supported yet.
(It worked in lvm1 & 2.4)

See https://bugzilla.redhat.com/show_bug.cgi?id=204997

But for metadata we need store both...

Milan


