From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 02 Dec 2013 10:45:25 +0100
Subject: [LVM2 PATCH v2] incorrect calculation of snapshot space (fwd)
In-Reply-To: <alpine.LRH.2.02.1311291814060.16583@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1311291814060.16583@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <529C56B5.5010402@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 30.11.2013 00:15, Mikulas Patocka napsal(a):
> Hi
>
> This is the patch for incorrect calculation of snapshot space in lvm2.
> This is the updated that checks target driver version.
>
> We need to get this into RHEL6.5 z-stream as soon as possible because this
> bug is a regression introduced in RHEL6.5.
>
> I created this bug for the issue:
> https://bugzilla.redhat.com/show_bug.cgi?id=1035871
>
> The bug can be tested with this script:
> #!/bin/sh
> VG=vg1
> lvremove -f $VG/origin
> set -e
> lvcreate -L 2143289344b -n origin $VG
> lvcreate -n snap -c 8k -L 2304M -s $VG/origin
> dd if=/dev/zero of=/dev/$VG/snap bs=1M count=2044 oflag=direct
>
>
> The bug happens when these two conditions are met
> * origin size is divisible by (chunk_size/16) - so that the last metadata
>    area is filled completely
> * the miscalculated snapshot metadata size is divisible by extent size -
>    so that there is no padding to extent boundary which would otherwise
>    save us
>
> Mikulas
> ---
>   lib/metadata/snapshot_manip.c |   52 +++++++++++++++++++++++++++++++++---------
>   1 file changed, 41 insertions(+), 11 deletions(-)
>
> Index: LVM2.2.02.104/lib/metadata/snapshot_manip.c
> ===================================================================
> --- LVM2.2.02.104.orig/lib/metadata/snapshot_manip.c	2013-11-28 19:11:00.000000000 +0100
> +++ LVM2.2.02.104/lib/metadata/snapshot_manip.c	2013-11-30 00:08:29.000000000 +0100
> @@ -31,7 +31,35 @@ int lv_is_cow(const struct logical_volum
>   	return (!lv_is_origin(lv) && lv->snapshot) ? 1 : 0;
>   }
>
> -static uint64_t _cow_max_size(uint64_t origin_size, uint32_t chunk_size)
> +/*
> + * Some kernels have a bug that they may leak space in the snapshot on crash.
> + * If the kernel is buggy, we add some extra space.
> + */
> +static uint64_t _cow_extra_chunks(struct cmd_context *cmd, uint64_t n_chunks)
> +{
> +	static int space_leak_bug_fixed = -1;
> +	if (space_leak_bug_fixed < 0) {
> +		uint32_t maj, min, patchlevel;
> +		if (!target_version("snapshot", &maj, &min, &patchlevel) &&
> +		    (!module_present(cmd, "snapshot") ||
> +		     !target_version("snapshot", &maj, &min, &patchlevel))) {
> +			space_leak_bug_fixed = 0;
> +			goto x;
> +		}
> +		space_leak_bug_fixed =
> +			(maj > 1 ||
> +			(maj == 1 && (min >= 12 ||
> +				     (min == 10 && patchlevel >= 2))));


I assume we should not detect any kernel version here - and simply supply the 
largest possible value for any kernel we could get.
(Since the VG could be activated on various machines with various kernels.)

As the difference will be rather small, it's not a big issue some chunks
might wasted on fixed/better kernels  - whoever is using  old-snapshot to 100% 
is doing something wrong anyway....

Zdenek


