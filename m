From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 20 May 2016 22:09:51 +0100
Subject: [PATCH] device: include goto label also for O_NOATIME
In-Reply-To: <20160520165626.GA2268@makrotopia.org>
References: <20160520043805.GA19157@makrotopia.org>
	<20160520110256.GB2110@agk-dp.fab.redhat.com>
	<20160520165626.GA2268@makrotopia.org>
Message-ID: <20160520210951.GC2110@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, May 20, 2016 at 06:56:27PM +0200, Daniel Golle wrote:
> The musl libc [1] apparently doesn't support O_DIRECT.
> Alpine Linux [2], LEDE [3] and OpenWrt [4] are affected.
 
So that's still widespread enough that we need to continue to support this 
and should probably add it to our upstream test matrix.

Alasdair


