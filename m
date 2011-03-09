From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 9 Mar 2011 03:01:51 +0000
Subject: [PATCH 3/4] Use allog_vg for _free_vg in _pvsegs_sub_single
In-Reply-To: <4D76ADF8.1090901@redhat.com>
References: <cover.1299089601.git.zkabelac@redhat.com>
	<5900aea795a418903c044cec95c2752e5a40b2a5.1299089601.git.zkabelac@redhat.com>
	<20110308170931.GH10767@agk-dp.fab.redhat.com>
	<4D76ADF8.1090901@redhat.com>
Message-ID: <20110309030150.GQ10767@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Mar 08, 2011 at 11:30:16PM +0100, Zdenek Kabelac wrote:
> The major purpose if the patch is to keep also reference count setting in one
> place (needed in my vg sharing patch) - also whenever someone adds any new
> member to VG structure - only one place needs to be updated for proper
> initialization.  So I'd still prefer to have this code running through
> standard allocation procedure.
 
But the new function is not (yet?) initialising the whole structure.

The 'reporter' use is only as a read-only dummy structure to allow us
to share some code paths.  It should not need a vgmem (or reference
counting), I'd have thought.

Alasdair


