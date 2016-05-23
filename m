From: Daniel Golle <daniel@makrotopia.org>
Date: Mon, 23 May 2016 21:45:06 +0200
Subject: [PATCH] device: include goto label also for O_NOATIME
In-Reply-To: <20160520210951.GC2110@agk-dp.fab.redhat.com>
References: <20160520043805.GA19157@makrotopia.org>
	<20160520110256.GB2110@agk-dp.fab.redhat.com>
	<20160520165626.GA2268@makrotopia.org>
	<20160520210951.GC2110@agk-dp.fab.redhat.com>
Message-ID: <20160523194505.GA4648@makrotopia.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi again!

On Fri, May 20, 2016 at 10:09:51PM +0100, Alasdair G Kergon wrote:
> On Fri, May 20, 2016 at 06:56:27PM +0200, Daniel Golle wrote:
> > The musl libc [1] apparently doesn't support O_DIRECT.
> > Alpine Linux [2], LEDE [3] and OpenWrt [4] are affected.
>  
> So that's still widespread enough that we need to continue to support this 
> and should probably add it to our upstream test matrix.

Neither you nor anyone else made any comments on the patch itself.
I'd be happy to see it being reviewed and, if possible, merged as it
fixes an obvious semantical error in the existing code.

Some more work is needed to be fully compatible with musl, see
https://github.com/openwrt/packages/tree/master/utils/lvm2/patches
or patches in
http://git.alpinelinux.org/cgit/aports/tree/main/lvm2?h=master


Cheers


Daniel


