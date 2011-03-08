From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 8 Mar 2011 17:09:31 +0000
Subject: [PATCH 3/4] Use allog_vg for _free_vg in _pvsegs_sub_single
In-Reply-To: <5900aea795a418903c044cec95c2752e5a40b2a5.1299089601.git.zkabelac@redhat.com>
References: <cover.1299089601.git.zkabelac@redhat.com>
	<5900aea795a418903c044cec95c2752e5a40b2a5.1299089601.git.zkabelac@redhat.com>
Message-ID: <20110308170931.GH10767@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Mar 02, 2011 at 07:20:25PM +0100, Zdenek Kabelac wrote:
> Switch to use alloc_vg function for allocation of VG struct.
 
This code looks wrong.  Maybe it suffered from some previous global change.

> -	struct volume_group _free_vg = {
> -		.cmd = cmd,
> -		.name = "",
> -	};

I think that should stay as it is.

> -        if (!(_free_vg.vgmem = dm_pool_create("_free_vg", 10240)))
> -		return ECMD_FAILED;

Why is vgmem being allocated?  If something really is using it, why?

Alasdair


