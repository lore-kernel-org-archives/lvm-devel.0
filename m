From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 25 Dec 2008 12:09:57 +0900
Subject: [PATCH] Calculate mirror log size instead of hardcoding 1 extent size.
In-Reply-To: <494B82EE.7020006@redhat.com>
References: <494B82EE.7020006@redhat.com>
Message-ID: <4952F985.5010307@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Milan,

Milan Broz wrote:
> The change in  _for_each_pv() is tricky, we have no region_size information
> there, but log_lv should be already configured - so it can use le_count.
> (I am not sue if this code is correct anyway, but cannot found
> path where it is wrong.)
>  
> Signed-off-by: Milan Broz <mbroz@redhat.com>
<snip>
> @@ -817,7 +844,7 @@ static int _for_each_pv(struct cmd_conte
>  
>  	/* FIXME only_single_area_segments used as workaround to skip log LV - needs new param? */
>  	if (!only_single_area_segments && seg_is_mirrored(seg) && seg->log_lv) {
> -		if (!(r = _for_each_pv(cmd, seg->log_lv, 0, MIRROR_LOG_SIZE,
> +		if (!(r = _for_each_pv(cmd, seg->log_lv, 0, seg->log_lv->le_count?:1,
>  				       NULL, 0, 0, 0, only_single_area_segments,
>  				       fn, data)))
>  			stack;

"seg->log_lv->le_count?:1" could be just "seg->log_lv->le_count",
to avoid possible future confusion.
(I.e. there is no explanation why we pass 1 when le_count is 0.)

And if the seg->log_lv is empty, _for_each_pv() will just fail anyway
by not finding a matching segment, regardless of len = 0 or 1.
If it is possible to pass an empty seg->log_lv here in future,
le_count check should be done in the above "if", I think.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation


--- lib/metadata/lv_manip.c.orig	2008-12-25 11:44:46.000000000 +0900
+++ lib/metadata/lv_manip.c	2008-12-25 11:33:17.000000000 +0900
@@ -844,7 +844,7 @@ static int _for_each_pv(struct cmd_conte
 
 	/* FIXME only_single_area_segments used as workaround to skip log LV - needs new param? */
 	if (!only_single_area_segments && seg_is_mirrored(seg) && seg->log_lv) {
-		if (!(r = _for_each_pv(cmd, seg->log_lv, 0, seg->log_lv->le_count?:1,
+		if (!(r = _for_each_pv(cmd, seg->log_lv, 0, seg->log_lv->le_count,
 				       NULL, 0, 0, 0, only_single_area_segments,
 				       fn, data)))
 			stack;


