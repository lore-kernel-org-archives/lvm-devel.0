From: Takahiro Yasui <tyasui@redhat.com>
Date: Mon, 06 Apr 2009 23:04:04 -0400
Subject: [PATCH] Enable use of cached metadata for pvs & pvdisplay
In-Reply-To: <49D9E6F4.90205@redhat.com>
References: <49D9E6F4.90205@redhat.com>
Message-ID: <49DAC2A4.2020904@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Milan,

> @@ -435,5 +435,5 @@ int pvs(struct cmd_context *cmd, int argc, char **argv)
...
> -	return _report(cmd, argc, argv, type);
> +	return  _report(cmd, argc, argv, type);

> @@ -638,8 +639,12 @@ static int _process_all_devs(struct cmd_context *cmd, void *handle,
...
>  	dev_iter_destroy(iter);
> -
> +	

Those two lines are unnecessary change?


By the way, I tested this patch in my environment at the point of
the number of I/Os, and I found that I/Os were reduced as expected.

Tested-by: Takahiro Yasui <tyasui@redhat.com>

Thanks,
Taka


