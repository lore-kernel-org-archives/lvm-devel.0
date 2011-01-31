From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 31 Jan 2011 19:37:01 +0000
Subject: [PATCH 1/1] Fix udev synchronization for no-locking mode
In-Reply-To: <87bp2xnm2x.fsf@twilight.int.mornfall.net.>
References: <cover.1296484980.git.zkabelac@redhat.com>
	<4782409942e1848995a1f1abd3f9eb83ffb43de0.1296484980.git.zkabelac@redhat.com>
	<87bp2xnm2x.fsf@twilight.int.mornfall.net.>
Message-ID: <20110131193701.GB32303@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Jan 31, 2011 at 04:12:54PM +0100, Peter Rockai wrote:
> nevertheless, no two places agree on which function to use for
> that. 

Indeed - can this be fixed without a recursive lock_vol call?

Alasdair


