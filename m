From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 06 Jun 2014 09:03:30 +0200
Subject: [PATCH] clvmd: fix _allocate_memory to avoid segfault on ppc64.
In-Reply-To: <1402037364-7417-1-git-send-email-lwang@suse.com>
References: <1402037364-7417-1-git-send-email-lwang@suse.com>
Message-ID: <539167C2.2060604@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 6.6.2014 08:49, Liuhua Wang napsal(a):
> From: lhwang <lwang@suse.com>
>
> Under some LIBPTHREAD_VERSION, for example 2.11, when allocates 64K
> and thread stacksize is 128K, starting clvmd causes a segfault.
>
> Signed-off-by: Liuhua Wang <lwang@suse.com>

Do you have any stack backtrace for this situation.

It'd be rather serious problem in clvmd code path to allocate even 32K on stack.

Thanks

Zdenek


