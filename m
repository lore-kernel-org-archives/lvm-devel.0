From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Mon, 24 Mar 2008 21:18:17 -0400
Subject: [PATCH vgsplit 1/4] Add is_reserved_name() helper function.
In-Reply-To: <20080324202434.586357085@redhat.com>
References: <20080324202343.627758622@redhat.com>
	<20080324202434.586357085@redhat.com>
Message-ID: <47E852D9.6040007@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

> Very similar to apply_lvname_restrictions but without the error messages.
...
> +int is_reserved_name(const char *name)
> +{
> +	if (!strncmp(name, "snapshot", 8))
> +		return 1;
> +
> +	if (!strncmp(name, "pvmove", 6))
> +		return 1;
> +
> +	if (strstr(name, "_mlog"))
> +		return 1;
> +
> +	if (strstr(name, "_mimage"))
> +		return 1;
> +
> +	return 0;
> +}

Having this function separately from apply_lvname_restrictions() is
error prone.
e.g. in future, adding a restriction to one but not for the other.

If only log_error() matters, how about adding 'verbose' parameter to
apply_lvname_restrictions() (or to this function) to control it?

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


