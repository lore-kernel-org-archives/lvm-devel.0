From: Daniel Golle <daniel@makrotopia.org>
Date: Fri, 20 May 2016 18:56:27 +0200
Subject: [PATCH] device: include goto label also for O_NOATIME
In-Reply-To: <20160520110256.GB2110@agk-dp.fab.redhat.com>
References: <20160520043805.GA19157@makrotopia.org>
	<20160520110256.GB2110@agk-dp.fab.redhat.com>
Message-ID: <20160520165626.GA2268@makrotopia.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Alasdair,

On Fri, May 20, 2016 at 12:02:56PM +0100, Alasdair G Kergon wrote:
> On Fri, May 20, 2016 at 06:38:10AM +0200, Daniel Golle wrote:
> > on standard C libraries without O_DIRECT_SUPPORT. Make sure it is
> 
> Which library or libraries are leading to this problem and what systems
> are still using them and do we know why they still don't support
> O_DIRECT?

The musl libc [1] apparently doesn't support O_DIRECT.

Alpine Linux [2], LEDE [3] and OpenWrt [4] are affected.

Never the less, if you use goto a view lines above in code which is
not augmented by the precompiler and then augment the goto target
this is obviously wrong. Either depend on O_DIRECT support always
being present and thus remove the ifdef'ery and make configure fail
if O_DIRECT isn't supported or make sure that the code is symantically
sound if you do all precompiler magic. Currently it simply allows for
the pre-compiler to generate code in which the goto target isn't
defined though it is being used.

[1]: http://www.musl-libc.org/
[2]: http://alpinelinux.org/
[3]: http://www.lede-project.org/
[4]: http://www.openwrt.org/


Cheers

Daniel


