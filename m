From: Milan Broz <mbroz@redhat.com>
Date: Mon, 14 Dec 2009 16:18:58 +0100
Subject: [PATCH 1/3] Fix reporting dmsetup info -c -o all
In-Reply-To: <e5b04bbd53a48c1323977411eef561b191670bb2.1260547761.git.zkabelac@redhat.com>
References: <cover.1260547761.git.zkabelac@redhat.com>
	<e5b04bbd53a48c1323977411eef561b191670bb2.1260547761.git.zkabelac@redhat.com>
Message-ID: <4B265762.9020202@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/11/2009 05:13 PM, Zdenek Kabelac wrote:
> Use whole bitmask of all options.

IOW fixes
dmsetup info -c -o all
to work and print all possible values.

ACK.

> @@ -379,7 +379,9 @@ static uint32_t _all_match(struct dm_report *rh, const char *field, size_t flen)
>  			       _all_match(rh, prefixed_all,
>  					  strlen(prefixed_all));
>  		} else
> -			return rh->report_types;
> +			/* all without type use full bitmask */
> +			return (!rh->report_types)
> +				? UINT_MAX : rh->report_types;

IMHO better

#define DM_REPORT_TYPE_ALL_FIELDS ~0
(or something like that instead of UINT_MAX)

>  	}
>  
>  	for (t = rh->types; t->data_fn; t++) {

Milan


