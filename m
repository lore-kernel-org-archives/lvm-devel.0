From: Milan Broz <mbroz@redhat.com>
Date: Tue, 21 Dec 2010 18:38:55 +0100
Subject: [PATCH 17/23] Add check for dm_snprintf result
In-Reply-To: <a8e673868df6582ac8916843f7f5c77d8dcdb2cf.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<a8e673868df6582ac8916843f7f5c77d8dcdb2cf.1292945707.git.zkabelac@redhat.com>
Message-ID: <4D10E62F.6070201@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

>  		/* If the VG name is empty then lock the unused PVs */
> -		if (is_orphan_vg(resource) || is_global_vg(resource) || (flags & LCK_CACHE))
> -			dm_snprintf(lockname, sizeof(lockname), "P_%s",
> -				    resource);
> -		else
> -			dm_snprintf(lockname, sizeof(lockname), "V_%s",
> -				    resource);
> +		if (dm_snprintf(lockname, sizeof(lockname), "%c_%s",
> +				(is_orphan_vg(resource) ||
> +				 is_global_vg(resource) ||
> +				 (flags & LCK_CACHE)) ?  'P' : 'V',
> +				resource)  < 0) {
> +			log_error("Locking resource %s too long.", resource);
> +			return 0;
> +		}

I cannot imagine how this can happen. First parm is fixed char, second is resource string
with exact length. And char lockname[PATH_MAX];

Should we check for glibc and clompiler bugs also? :)

Well, isn't return_0 here enough?

Milan


