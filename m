From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 11 May 2009 12:48:17 +0100
Subject: [PATCH 3/7] Remove snapshot_count from VG and use function instead.
In-Reply-To: <87iqk8u7fn.fsf@eriador.mornfall.net>
References: <cover.1241620083.git.mbroz@redhat.com>
	<cover.1241620083.git.mbroz@redhat.com>
	<a015c94d4f5d34699e100b182f539812543b883e.1241620083.git.mbroz@redhat.com>
	<87iqk8u7fn.fsf@eriador.mornfall.net>
Message-ID: <20090511114817.GG7680@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, May 10, 2009 at 08:41:32PM +0200, Peter Rockai wrote:
> Patch looks good. Good to get rid of redundant counter, which is prone to
> getting out of sync. I would, however, propose to rename "snapshot_lvs_in_vg"
> to "vg_snapshot_lv_count" -- we already have "vg_missing_pv_count" as a
> precedent for that naming scheme.

Ack.

> PS: I would welcome a similar approach to removing lv_count as well (and other
> redundant counters), since the counting function's implementation clearly
> defines what gets counted in the given counter (vg_lv_count, say), *and* it
> never gets out of sync. In other words, I believe this approach is much more
> transparent, albeit a little less efficient -- however, I don't believe such
> counting function is going to show up on any profile of any LVM2 command
> whatsoever.

If it ever did, we could just optimise things by putting it back in:-)
It's only needed for display tools (and there are caching tricks we could use
there but don't) and the tiny subset of people these days who found a use for
max_lv (or don't need it but are running systems that inherited it from LVM1).
 
Alasdair


