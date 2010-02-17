From: Petr Rockai <prockai@redhat.com>
Date: Wed, 17 Feb 2010 16:51:31 +0100
Subject: [PATCH] Hide merging snapshots from "lvs" command.
In-Reply-To: <1254432375-5880-1-git-send-email-snitzer@redhat.com> (Mike
	Snitzer's message of "Thu, 1 Oct 2009 17:26:15 -0400")
References: <1254432375-5880-1-git-send-email-snitzer@redhat.com>
Message-ID: <87ocjnzwqk.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Mike Snitzer <snitzer@redhat.com> writes:
> Hide merging snapshots from "lvs" command. The prefix "snapshot" is reserved
> and names with this prefix cannot be created by the user, so this change is
> safe.
>
> Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> Reviewed-by: Mike Snitzer <snitzer@redhat.com>
>
> ---
>  tools/toollib.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> Index: lvm2/tools/toollib.c
> ===================================================================
> --- lvm2.orig/tools/toollib.c
> +++ lvm2/tools/toollib.c
> @@ -119,7 +119,8 @@ int process_each_lv_in_vg(struct cmd_con
>  	}
>  
>  	dm_list_iterate_items(lvl, &vg->lvs) {
> -		if (lvl->lv->status & SNAPSHOT)
> +		/* Names starting with "snapshot" are reserved */
> +		if (!strncmp(lvl->lv->name, "snapshot", strlen("snapshot")))
>  			continue;
>  
>  		if (lv_is_virtual_origin(lvl->lv) && !arg_count(cmd, all_ARG))

This seems to have fallen through the cracks. Please check in if still
relevant (the patch is not present in current CVS as far as I can tell).

Yours,
   Petr.


