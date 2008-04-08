From: Bryn M. Reeves <bmr@redhat.com>
Date: Tue, 08 Apr 2008 11:55:03 +0100
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
In-Reply-To: <20080407221238.30851.qmail@sourceware.org>
References: <20080407221238.30851.qmail@sourceware.org>
Message-ID: <47FB4F07.5070909@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

agk at sourceware.org wrote:
> +	/* create format instance with appropriate metadata area */
> +	if (!(vg->fid = vginfo->fmt->ops->create_instance(vginfo->fmt,
> +							  orphan_vgname, NULL,
> +							  NULL))) {
> +		log_error("Failed to create format instance");
> +		dm_pool_free(cmd->mem, vg);
> +		return NULL;
> +	}
> +

This breaks _vg_read_orphans if there are no orphans of the required
format type on-disk. In that case, vginfo_from_vgname returns NULL - we
cannot rely on getting the format type from the cache since that
requires there to always be at least one orphan for each format type
on-disk (or we need to change the cache to make one up in that case).

This is the reason for determining the format type from the orphan VG
name in the patch I sent.

With this version, the patch to make vgreduce use vg_split_mdas would
fail with:

# vgreduce t0 /dev/loop0
Unable to read orphan PVs

Unless you already have at least one orphan PV of the same format type.

Regards,
Bryn.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFH+08G6YSQoMYUY94RAlwxAKC+yMxjLJay78Z1Rv6vholXBw+AzgCfRBYN
MsKfwV/LPJyHI2mqrMX5BSE=
=aD5d
-----END PGP SIGNATURE-----


