From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 22 Nov 2019 11:32:23 +0100
Subject: [PATCH] lib/metadata: Print VG name in log message for raid segment errors
In-Reply-To: <CAMNNMLH-K-fZ2h+xR-hBP6QOiRpOHVyA=6SWq9_iH7GoanmiFw@mail.gmail.com>
References: <CAMNNMLH-K-fZ2h+xR-hBP6QOiRpOHVyA=6SWq9_iH7GoanmiFw@mail.gmail.com>
Message-ID: <c94c8361-f20b-d68b-ae78-b2eac4828300@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 22. 11. 19 v 5:07 Nikhil Kshirsagar napsal(a):
> Signed-off-by: Nikhil Kshirsagar <nkshirsa@redhat.com>
> ---
> diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
> index 08f8fbe..d2711f3 100644
> --- a/lib/metadata/merge.c
> +++ b/lib/metadata/merge.c
> @@ -85,8 +85,8 @@ int lv_merge_segments(struct logical_volume *lv)
>    * bogus segment structure setup.
>    */
>   #define raid_seg_error(msg) do { \
> -       log_error("LV %s invalid: %s for %s segment", \
> -                 seg->lv->name, (msg), lvseg_name(seg)); \
> +       log_error("LV %s in VG %s invalid: %s for %s segment", \
> +                 seg->lv->name, seg->lv->vg ? seg->lv->vg->name :
> "UNKNOWN", (msg), lvseg_name(seg)); \
>          if ((*error_count)++ > ERROR_MAX) \
>                  return; \
>   } while (0)


Hi


For display of LV names - we use  'display_lvname()' function call
(which automatically forms string as  vg/lv)

Regards


Zdenek


