From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 2 Apr 2010 02:23:45 +0100
Subject: [PATCH 4/6] Add pv->vg to solidify link between a pv and a vg.
In-Reply-To: <1270159052-1181-5-git-send-email-dwysocha@redhat.com>
References: <1270159052-1181-1-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-2-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-3-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-4-git-send-email-dwysocha@redhat.com>
	<1270159052-1181-5-git-send-email-dwysocha@redhat.com>
Message-ID: <20100402012345.GX11377@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Apr 01, 2010 at 05:57:30PM -0400, Dave Wysochanski wrote:
> lvm2app needs a link back to the vg in order to use the vg handle for
> memory allocations as well as other things.  This patch adds the field
> to struct physical_volume, and sets the field when returning from
> vg_read() internal library call.
 
> +	struct volume_group *vg; /* FIXME: Only valid when used with lvm2app. */

Please make it generally applicable and always internally consistent i.e.
always pointing back to the VG struct which contains the list it is on.

Also update vg_validate whenever extending the core metadata structs.

Alasdair


