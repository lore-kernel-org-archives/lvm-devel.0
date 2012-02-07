From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Tue, 07 Feb 2012 09:55:10 +0100
Subject: [PATCH] clvmd-corosync: use libquorum callbacks instead of polling
In-Reply-To: <1328539700-909-1-git-send-email-fdinitto@redhat.com>
References: <1328539700-909-1-git-send-email-fdinitto@redhat.com>
Message-ID: <4F30E6EE.5080102@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Please disregard this patch, it?s not correct.

Fabio

On 2/6/2012 3:48 PM, Fabio M. Di Nitto wrote:
> From: "Fabio M. Di Nitto" <fdinitto@redhat.com>
> 
> clvmd polls for quorum status every minute (from the main loop).
> With the new libquorum, this is unnecessary since clvmd can receive
> quorum updates via callbacks.
> 
> Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
> ---
>  daemons/clvmd/clvmd-corosync.c |   42 +++++++++++++++++++++++++++++++++++++++-
>  1 files changed, 41 insertions(+), 1 deletions(-)
> 
> diff --git a/daemons/clvmd/clvmd-corosync.c b/daemons/clvmd/clvmd-corosync.c
> index d85ec1e..eaab023 100644
> --- a/daemons/clvmd/clvmd-corosync.c
> +++ b/daemons/clvmd/clvmd-corosync.c
> @@ -83,9 +83,24 @@ cpg_callbacks_t corosync_cpg_callbacks = {
>  	.cpg_confchg_fn =            corosync_cpg_confchg_callback,
>  };
>  
> +static int quorate = 0;
> +
> +#ifdef QUORUM_SET
> +static void quorum_notification_callback(
> +	quorum_handle_t handle,
> +	uint32_t quorate,
> +	uint64_t ring_id,
> +	uint32_t view_list_entries,
> +	uint32_t *view_list);
> +
> +quorum_callbacks_t quorum_callbacks = {
> +	.quorum_notify_fn = quorum_notification_callback
> +};
> +#else
>  quorum_callbacks_t quorum_callbacks = {
>  	.quorum_notify_fn = NULL,
>  };
> +#endif
>  
>  struct node_info
>  {
> @@ -307,6 +322,14 @@ static int _init_cluster(void)
>  		DEBUGLOG("Corosync quorum service is not configured");
>  		return EINVAL;
>  	}
> +
> +	/* Initiliaze quorate status before callbacks */
> +	if (quorum_getquorate(quorum_handle, &quorate) != CS_OK) {
> +		syslog(LOG_ERR, "Unable to determine quorate status for this node");
> +		DEBUGLOG("Unable to determine quorate status for this node\n");
> +		quorate = 0;
> +	}
> +	DEBUGLOG("Initial quorate status: %u\n", quorate);
>  #else
>  	err = quorum_initialize(&quorum_handle,
>  				&quorum_callbacks);
> @@ -528,14 +551,31 @@ static int _unlock_resource(const char *resource, int lockid)
>  	return 0;
>  }
>  
> +#ifdef QUORUM_SET
> +static void quorum_notification_callback(
> +	quorum_handle_t handle,
> +	uint32_t quorate_status,
> +	uint64_t ring_id,
> +	uint32_t view_list_entries,
> +	uint32_t *view_list)
> +{
> +	DEBUGLOG("quorum_notification_callback. quorate: %u", quorate_status);
> +	quorate = quorate_status;
> +}
> +
> +static int _is_quorate()
> +{
> +	return quorate;
> +}
> +#else
>  static int _is_quorate()
>  {
> -	int quorate;
>  	if (quorum_getquorate(quorum_handle, &quorate) == CS_OK)
>  		return quorate;
>  	else
>  		return 0;
>  }
> +#endif
>  
>  static int _get_main_cluster_fd(void)
>  {


