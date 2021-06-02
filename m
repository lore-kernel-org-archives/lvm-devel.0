From: David Teigland <teigland@redhat.com>
Date: Wed, 2 Jun 2021 16:45:54 -0500
Subject: [PATCH]pvchange: Fix the deadlock problem
In-Reply-To: <eed37eea-bf93-158e-6366-cc6e338851c8@huawei.com>
References: <eed37eea-bf93-158e-6366-cc6e338851c8@huawei.com>
Message-ID: <20210602214554.GA31884@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Jun 01, 2021 at 04:14:39PM +0800, Wu Guanghao wrote:
> Hi,
> 
> I found a deadlock problem during testing?the reason is that the pvchange command
> did not acquire the global lock first.

> +	if (!lock_global(cmd, "ex"))
> +		return_ECMD_FAILED;
> +
>  	clear_hint_file(cmd);

Thanks, that's correct, but I changed it a bit to avoid invalidating the
hints more than necessary, which also avoids serializing more commands
than necessary.

https://sourceware.org/git/?p=lvm2.git;a=commit;h=2bce6faed017df8da3e659eff3f42f39d25c7f09


