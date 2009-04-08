From: Takahiro Yasui <tyasui@redhat.com>
Date: Wed, 08 Apr 2009 02:09:00 -0400
Subject: [PATCH v2] Enable use of cached metadata for pvs & pvdisplay
In-Reply-To: <49DB3352.1060909@redhat.com>
References: <49D9E6F4.90205@redhat.com> <49DB3352.1060909@redhat.com>
Message-ID: <49DC3F7C.1030006@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Milan,

> @@ -778,12 +785,19 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
>  				if (ret > ret_max)
>  					ret_max = ret;
>  				if (sigint_caught())
> -					return ret_max;
> +					goto bad;

In the above line, "goto bad" is typo of "goto out"?

Thanks,
Taka


