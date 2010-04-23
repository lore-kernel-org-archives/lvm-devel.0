From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 23 Apr 2010 01:11:43 +0100
Subject: [PATCH] conditionally avoid preloading the origin in vg_remove_snapshot
In-Reply-To: <20100421175859.GA19594@redhat.com>
References: <20100407200443.26841.qmail@sourceware.org>
	<20100419223820.GA11273@redhat.com>
	<20100419232509.GG4828@agk-dp.fab.redhat.com>
	<20100421063504.GA10083@redhat.com>
	<20100421175859.GA19594@redhat.com>
Message-ID: <20100423001143.GF23791@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Apr 21, 2010 at 01:59:00PM -0400, Mike Snitzer wrote:
> Avoid preloading the origin, when removing a snapshot, if snapshot-merge
> target is not active.
> [This adds a 2nd consumer of lv_has_target_type().  I'm still not seeing
>  an alternative way to test if snapshot-merge was performed.]
 
If it works, exporting that is fine for now.

Alasdair


