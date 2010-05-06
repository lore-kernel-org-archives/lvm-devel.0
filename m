From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 6 May 2010 02:39:08 +0100
Subject: [PATCH 03/23] API change for args of process_each_lv_in_vg()
In-Reply-To: <a14874903122bdacdcc40bf9dd46d9c62e063ce4.1272457502.git.zkabelac@redhat.com>
References: <cover.1272457502.git.zkabelac@redhat.com>
	<a14874903122bdacdcc40bf9dd46d9c62e063ce4.1272457502.git.zkabelac@redhat.com>
Message-ID: <20100506013908.GL27027@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Apr 28, 2010 at 02:27:22PM +0200, Zdenek Kabelac wrote:
> Patch adds failed_lvnames to the list of parameters for process_each_lv_in_vg().
> If the list is not NULL it will be filled with LV names of failing LVs
> during function execution.

Ack.
 
> +++ b/tools/toollib.c
> @@ -86,6 +86,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
>  			  struct volume_group *vg,
>  			  const struct dm_list *arg_lvnames,
>  			  const struct dm_list *tags,
> +			  struct dm_list *failed_lvnames,
>  			  void *handle,
>  			  process_single_lv_fn_t process_single_lv)
>  {
> @@ -99,6 +100,9 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
>  
>  	struct lv_list *lvl;
>  
> +	if (failed_lvnames)
> +		dm_list_init(failed_lvnames);

I'd prefer the caller to initialise it, which is what we tend to do
elsewhere, so that we don't pass 'undefined' values into functions.

Alasdair


