From: Milan Broz <mbroz@redhat.com>
Date: Mon, 01 Nov 2010 14:16:25 +0100
Subject: [PATCH] Use dynamic allocation for buffer when reporting tags
In-Reply-To: <4CCEBBBB.2050705@redhat.com>
References: <4CCEACE2.8060609@redhat.com> <4CCEBBBB.2050705@redhat.com>
Message-ID: <4CCEBDA9.1060107@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 11/01/2010 02:08 PM, Peter Rajnoha wrote:
> OK, here's updated version (based on quick hints from Milan).

ack + tested, works for my test script


> @@ -902,11 +919,13 @@ static int _output_field(struct dm_report *rh, struct dm_report_field *field)
>  
>  		if (!dm_pool_grow_object(rh->mem, rh->output_field_name_prefix, 0)) {
>  			log_error("dm_report: Unable to extend output line");
> +			free(field_id);
>  			return 0;

just mention in changelog that this is additional memleak fix.

Milan


