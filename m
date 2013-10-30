From: Brassow Jonathan <jbrassow@redhat.com>
Date: Tue, 29 Oct 2013 20:48:02 -0500
Subject: [PATCH 2/2] cmirrord support DM_INTEGRATED_FLUSH
In-Reply-To: <42b711853e0839337b31c87dda42482d2a84e103.1382955203.git.dmzhang@suse.com>
References: <yes> <cover.1382955203.git.dmzhang@suse.com>
	<a69579c2d3e666c37ad71aa93ae8c734b0d8a5e3.1382955203.git.dmzhang@suse.com>
	<42b711853e0839337b31c87dda42482d2a84e103.1382955203.git.dmzhang@suse.com>
Message-ID: <FA4F0719-4C31-4F89-823B-9163EB6A94E7@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dongmao,

See in-line comments.

 brassow


On Oct 28, 2013, at 5:17 AM, dongmao zhang wrote:

> if integrated_flush is set. cmirrord will check the payload
> of FLUSH request.

No.  Who cares if 'integrated_flush' is set.  Just check if the kernel has sent you a flush that is integrated (i.e. has a payload) and do the appropriate thing.

> ---
> daemons/cmirrord/functions.c |   62 +++++++++++++++++++++++++++++++++---------
> daemons/cmirrord/local.c     |    9 +++++-
> lib/mirror/mirrored.c        |    2 +-
> 3 files changed, 58 insertions(+), 15 deletions(-)
> 
> diff --git a/daemons/cmirrord/functions.c b/daemons/cmirrord/functions.c
> index f6e0918..c534136 100644
> --- a/daemons/cmirrord/functions.c
> +++ b/daemons/cmirrord/functions.c
> @@ -75,6 +75,7 @@ struct log_c {
>                 FORCESYNC,      /* Force a sync to happen */
>         } sync;
> 
> +	uint32_t integrated_flush;

No need for 'integrated_flush'?

> 	uint32_t state;         /* current operational state of the log */
> 
> 	struct dm_list mark_list;
> @@ -362,7 +363,7 @@ static int find_disk_path(char *major_minor_str, char *path_rtn, int *unlink_pat
> 	// return r ? -errno : 0;
> }
> 
> -static int _clog_ctr(char *uuid, uint64_t luid,
> +static int _clog_ctr(char *uuid, uint64_t luid, uint32_t version,
> 		     int argc, char **argv, uint64_t device_size)

No need to change '_clog_ctr' (except to ignore the "integrated_flush" parameter).  As stated in my response to the kernel patch, you will not be sending back the additional string.

> {
> 	int i;
> @@ -373,6 +374,7 @@ static int _clog_ctr(char *uuid, uint64_t luid,
> 	struct log_c *lc = NULL;
> 	enum sync log_sync = DEFAULTSYNC;
> 	uint32_t block_on_error = 0;
> +	uint32_t integrated_flush = 0;
> 
> 	int disk_log;
> 	char disk_path[128];
> @@ -431,6 +433,8 @@ static int _clog_ctr(char *uuid, uint64_t luid,
> 			log_sync = NOSYNC;
> 		else if (!strcmp(argv[i], "block_on_error"))
> 			block_on_error = 1;
> +		else if (!strcmp(argv[i], "integrated_flush") && version > 2)
> +			integrated_flush = 1;

Yes, check for "integrated_flush" here because it is a valid parameter, but you don't actually need to set anything or do anything with it.  It was more for the kernel's benefit.

> 	}
> 
> 	lc = dm_zalloc(sizeof(*lc));
> @@ -451,6 +455,7 @@ static int _clog_ctr(char *uuid, uint64_t luid,
> 	lc->log_dev_failed = 0;
> 	strncpy(lc->uuid, uuid, DM_UUID_LEN);
> 	lc->luid = luid;
> +	lc->integrated_flush = integrated_flush;
> 
> 	if (get_log(lc->uuid, lc->luid) ||
> 	    get_pending_log(lc->uuid, lc->luid)) {
> @@ -552,6 +557,8 @@ static int clog_ctr(struct dm_ulog_request *rq)
> 	char *dev_size_str;
> 	uint64_t device_size;
> 
> +	struct log_c *tmplc = NULL;
> +
> 	/* Sanity checks */
> 	if (!rq->data_size) {
> 		LOG_ERROR("Received constructor request with no data");
> @@ -594,14 +601,17 @@ static int clog_ctr(struct dm_ulog_request *rq)
> 		return -EINVAL;
> 	}
> 
> -	r = _clog_ctr(rq->uuid, rq->luid, argc - 1, argv + 1, device_size);
> +	r = _clog_ctr(rq->uuid, rq->luid, rq->version, argc - 1, argv + 1, device_size);
> 
> 	/* We join the CPG when we resume */
> 
> 	/* No returning data */
> -	if ((rq->version > 1) && !strcmp(argv[0], "clustered-disk"))
> -		rq->data_size = sprintf(rq->data, "%s", argv[1]) + 1;
> -	else
> +	if ((rq->version > 1) && !strcmp(argv[0], "clustered-disk")) {
> +		rq->data_size = sprintf(rq->data, "%s", argv[1]);
> +		tmplc = get_pending_log(rq->uuid, rq->luid);
> +		if (tmplc && tmplc->integrated_flush)
> +			rq->data_size += sprintf(rq->data + rq->data_size, " %s", "integrated_flush") + 1;
> +	} else
> 		rq->data_size = 0;
> 
> 	if (r) {
> @@ -1027,14 +1037,17 @@ static int clog_in_sync(struct dm_ulog_request *rq)
> }
> 
> /*
> - * clog_flush
> - * @rq
> + * _clog_flush
> + * @lc
> + * @server
> + *
> + * real flush
>  *
> + * Returns: 0 on success, -EXXX on error
>  */
> -static int clog_flush(struct dm_ulog_request *rq, int server)
> +static int _clog_flush(struct log_c *lc, int server)
> {
> 	int r = 0;
> -	struct log_c *lc = get_log(rq->uuid, rq->luid);
> 
> 	if (!lc)
> 		return -EINVAL;
> @@ -1047,10 +1060,10 @@ static int clog_flush(struct dm_ulog_request *rq, int server)
> 	 * if we are the server.
> 	 */
> 	if (server && (lc->disk_fd >= 0)) {
> -		r = rq->error = write_log(lc);
> +		r = write_log(lc);
> 		if (r)
> 			LOG_ERROR("[%s] Error writing to disk log",
> -				  SHORT_UUID(lc->uuid));
> +				SHORT_UUID(lc->uuid));
> 		else 
> 			LOG_DBG("[%s] Disk log written", SHORT_UUID(lc->uuid));
> 	}
> @@ -1058,6 +1071,21 @@ static int clog_flush(struct dm_ulog_request *rq, int server)
> 	lc->touched = 0;
> 
> 	return r;
> +}
> +
> +
> +/*
> + * clog_flush
> + * @rq
> + *
> + */
> +static int clog_flush(struct dm_ulog_request *rq, int server)
> +{
> +	int r = 0;
> +	struct log_c *lc = get_log(rq->uuid, rq->luid);
> +
> +	r = rq->error = _clog_flush(lc, server);
> +	return r;
> 
> }
> 
> @@ -1113,7 +1141,7 @@ static int mark_region(struct log_c *lc, uint64_t region, uint32_t who)
>  *
>  * Returns: 0 on success, -EXXX on failure
>  */
> -static int clog_mark_region(struct dm_ulog_request *rq, uint32_t originator)
> +static int clog_mark_region(struct dm_ulog_request *rq, uint32_t originator, int server)
> {
> 	int r;
> 	int count;
> @@ -1139,6 +1167,14 @@ static int clog_mark_region(struct dm_ulog_request *rq, uint32_t originator)
> 
> 	rq->data_size = 0;
> 
> +	/* 
> +	 * if kernel support integrate flush, after marking region, 
> +	 * cmirrord should execute clog_flush automatically.
> +	 */
> +
> +	if(lc->integrated_flush)
> +		return _clog_flush(lc, server);
> +
> 	return 0;
> }
> 
> @@ -1676,7 +1712,7 @@ int do_request(struct clog_request *rq, int server)
> 		r = clog_flush(&rq->u_rq, server);
> 		break;
> 	case DM_ULOG_MARK_REGION:
> -		r = clog_mark_region(&rq->u_rq, rq->originator);
> +		r = clog_mark_region(&rq->u_rq, rq->originator, server);
> 		break;
> 	case DM_ULOG_CLEAR_REGION:
> 		r = clog_clear_region(&rq->u_rq, rq->originator);
> diff --git a/daemons/cmirrord/local.c b/daemons/cmirrord/local.c
> index 500f6dc..8b52556 100644
> --- a/daemons/cmirrord/local.c
> +++ b/daemons/cmirrord/local.c
> @@ -267,8 +267,15 @@ static int do_local_work(void *data __attribute__((unused)))
> 			break;
> 		}
> 		/* ELSE, fall through */
> -	case DM_ULOG_IS_CLEAN:
> 	case DM_ULOG_FLUSH:
> +		/*
> +		 * if it has payload, it must be a integrated flush.
> +		 * change the request_type to MARK_REGION. the clog_mark_region
> +		 * will flush automatically in the futhure
> +		 */
> +		if (rq->u_rq.data_size > 0)
> +			rq->u_rq.request_type = DM_ULOG_MARK_REGION;

Don't change the FLUSH into a MARK and have the MARK perform the FLUSH.  Instead, make the flush function determine if there is a payload and if so pass the payload along to mark.  Always perform the flush in the flush function.  This way, the code will handle old and new kernels automatically without having to check if 'integrated_flush' was set.  Additionally, it will handle failure conditions from the kernel (like, flush_one_by_one()) better.

> +	case DM_ULOG_IS_CLEAN:
> 	case DM_ULOG_MARK_REGION:
> 	case DM_ULOG_GET_RESYNC_WORK:
> 	case DM_ULOG_SET_REGION_SYNC:
> diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
> index 572f87e..4015116 100644
> --- a/lib/mirror/mirrored.c
> +++ b/lib/mirror/mirrored.c
> @@ -378,7 +378,7 @@ static int _add_log(struct dm_pool *mem, struct lv_segment *seg,
> 	if (_block_on_error_available && !(seg->status & PVMOVE))
> 		log_flags |= DM_BLOCK_ON_ERROR;
> 
> -	/*clustered log support delay flush*/
> +	/*clustered log support integrated flush*/
> 	if(clustered)
> 		log_flags |= DM_INTEGRATED_FLUSH;
> 



