From: Milan Broz <mbroz@redhat.com>
Date: Mon, 21 Jun 2010 22:11:56 +0200
Subject: [PATCH] Missing error checking in cmirrord
In-Reply-To: <1276895420.26585.1.camel@hydrogen.msp.redhat.com>
References: <1276895420.26585.1.camel@hydrogen.msp.redhat.com>
Message-ID: <4C1FC78C.40702@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 06/18/2010 11:10 PM, Jonathan Brassow wrote:
> There are missing error checks... it's possible for
> sprintf to fail.
> 
>  brassow
> 
> Index: LVM2/daemons/cmirrord/functions.c
> ===================================================================
> --- LVM2.orig/daemons/cmirrord/functions.c
> +++ LVM2/daemons/cmirrord/functions.c
> @@ -1371,15 +1371,21 @@ static int clog_get_sync_count(struct dm
>  
>  static int core_status_info(struct log_c *lc __attribute((unused)), struct dm_ulog_request *rq)
>  {
> +	int r;
>  	char *data = (char *)rq->data;
>  
> -	rq->data_size = sprintf(data, "1 clustered-core");

	rq->data_size = 0;

> +	r = sprintf(data, "1 clustered-core");
> +	if (r < 0)
> +		return r;
> +
> +	rq->data_size = r;

	rq->data_size = r + 1;

sprintf does not count trailing \0 ... (and this is probably part of
the mysterious fails of cmirrord).

 
Milan


