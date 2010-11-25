From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 17:24:42 +0100
Subject: [PATCH 27/29] Add standard check for result of lv_info call
In-Reply-To: <ca96fa093553cbe0e0c0e15d5e70d7e49334669f.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<ca96fa093553cbe0e0c0e15d5e70d7e49334669f.1290682013.git.zkabelac@redhat.com>
Message-ID: <4CEE8DCA.4080407@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 25.11.2010 11:55, Zdenek Kabelac napsal(a):
> Also add log_error message in case info would not be found.
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
> ---
>  lib/mirror/mirrored.c |   12 ++++++++++--
>  1 files changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
> index da9bdba..98aaa0d 100644
> --- a/lib/mirror/mirrored.c
> +++ b/lib/mirror/mirrored.c
> @@ -296,7 +296,11 @@ static int _mirrored_transient_status(struct lv_segment *seg, char *params)
>  	if (!strcmp(log_args[0], "disk")) {
>  		char buf[32];
>  		log = first_seg(lv)->log_lv;
> -		lv_info(lv->vg->cmd, log, 0, &info, 0, 0);
> +		if (!lv_info(lv->vg->cmd, log, 0, &info, 0, 0)) {
> +			log_error("Check for existence of mirror log '%s' failed.",
> +				  log->name);
> +			return 0;
> +		}
>  		log_debug("Found mirror log at %d:%d", info.major, info.minor);
>  		sprintf(buf, "%d:%d", info.major, info.minor);
>  		if (strcmp(buf, log_args[1])) {
> @@ -316,7 +320,11 @@ static int _mirrored_transient_status(struct lv_segment *seg, char *params)
>  
>  	for (i = 0; i < seg->area_count; ++i) {
>  		char buf[32];
> -		lv_info(lv->vg->cmd, seg_lv(seg, i), 0, &info, 0, 0);
> +		if (!lv_info(lv->vg->cmd, seg_lv(seg, i), 0, &info, 0, 0)) {
> +			log_error("Check for existence of mirror leg '%s' failed.",
> +				  log->name);

Ooops - forget one merge commit in my local branch to fix this copy&paste.

Here instead of 'log->name'     'seg_lv(seg, i)->name'  has to be used.

Zdenek


