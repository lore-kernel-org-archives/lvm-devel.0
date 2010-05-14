From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 14 May 2010 12:26:35 +0100
Subject: [PATCH 1/1] Use /bin/bash instead of /bin/sh
In-Reply-To: <4BED30AF.5030706@redhat.com>
References: <cover.1273825538.git.zkabelac@redhat.com>
	<68fd26e48c7d6d792d4d1af9551a0ba070e022d4.1273825538.git.zkabelac@redhat.com>
	<20100514104002.GQ2377@agk-dp.fab.redhat.com>
	<4BED30AF.5030706@redhat.com>
Message-ID: <20100514112635.GS2377@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, May 14, 2010 at 01:14:55PM +0200, Zdenek Kabelac wrote:
> Some of them could be easily fixed - some of them are trickier (i.e.
> ${RANDOM}) - as we already use bash for other scripts anyway - I've considered
> it's fairly easier to use bash for these as well...
 
Well it's fine to use some of those helpful bash extensions - pretty much every
system has it available these days - but we should still clean up the ones here
where the original syntax is equally good.

Alasdair


