From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 14 Mar 2013 15:17:19 +0100
Subject: [PATCH 4/5] lvm2app: Move core lv re-size code (v2)
In-Reply-To: <1363212806-16025-4-git-send-email-tasleson@redhat.com>
References: <1363212806-16025-1-git-send-email-tasleson@redhat.com>
	<1363212806-16025-4-git-send-email-tasleson@redhat.com>
Message-ID: <5141DBEF.8040309@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 13.3.2013 23:13, Tony Asleson napsal(a):
> Moved to allow use from command line and for library use.
>
> Signed-off-by: Tony Asleson <tasleson@redhat.com>
> ---
>   lib/metadata/lv_manip.c          | 734 +++++++++++++++++++++++++++++++++++++
>   lib/metadata/metadata-exported.h |  46 +++
>   tools/lvresize.c                 | 771 ---------------------------------------
>   3 files changed, 780 insertions(+), 771 deletions(-)
>

> diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
> index c2728d5..a792fd2 100644
> --- a/lib/metadata/metadata-exported.h
> +++ b/lib/metadata/metadata-exported.h
> @@ -419,6 +419,49 @@ struct pvcreate_params {
>   	struct pvcreate_restorable_params rp;
>   };
>
> +struct lvresize_params {
> +	const char *vg_name;
> +	const char *lv_name;
> +
> +	uint32_t stripes;
> +	uint32_t stripe_size;
> +	uint32_t mirrors;
> +


Here we should think about - whether there should be one
generic  '_params'  object with subsection (?unions?)
for various operations - since there is a lot of common
options between  lvcreate/lvconvert/lvresize....

lvm2api then might create access(set/get) methods to prepare this object
and pass this handle into more generic function.

Zdenek


