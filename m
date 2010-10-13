From: Milan Broz <mbroz@redhat.com>
Date: Wed, 13 Oct 2010 21:06:53 +0200
Subject: [PATCH] lvconvert: provide useful error when snapshot-merge target missing
In-Reply-To: <20101013185302.GA2944@redhat.com>
References: <20101013185302.GA2944@redhat.com>
Message-ID: <4CB6034D.5080603@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/13/2010 08:53 PM, Mike Snitzer wrote:
> Convey need for snapshot-merge target in lvconvert error message and man
> page.

> --- a/lib/metadata/segtype.h
> +++ b/lib/metadata/segtype.h
> @@ -66,6 +66,7 @@ struct segment_type {
>  
>  struct segtype_handler {
>  	const char *(*name) (const struct lv_segment * seg);
> +	const char *(*target_name) (const struct lv_segment * seg);
>  	void (*display) (const struct lv_segment * seg);
>  	int (*text_export) (const struct lv_segment * seg,
>  			    struct formatter * f);

I think this will break shared (external) segment module ABI.
Nobody uses that but worth to mention it.
(See e.g. lib/mirror and --with-mirrors=shared)

Otherwise ack.

Milan


