From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 12 Dec 2008 01:11:09 +0000
Subject: [PATCH] New lib/lvm2.c for base library functions
In-Reply-To: <1229013822-10809-3-git-send-email-twoerner@redhat.com>
References: <1229013822-10809-1-git-send-email-twoerner@redhat.com>
	<1229013822-10809-2-git-send-email-twoerner@redhat.com>
	<1229013822-10809-3-git-send-email-twoerner@redhat.com>
Message-ID: <20081212011109.GU24785@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Dec 11, 2008 at 05:43:41PM +0100, Thomas Woerner wrote:
>  lib/lvm2.c      |   42 ++++++++++++++++++++++++++++++++++++++++++

I'd prefer not to have a 'special' file like that.
Please place the functions elsewhere in the directory
hierachy according to what they are doing.

> +lvm2_handle_t lvm2_create(const char *sys_dir)
> +{
> +  struct cmd_context *cmd;
> +
> +  /* use internal version with system_dir */
> +  cmd = create_librarycontext(sys_dir);

No need for this wrapper at this stage - just use the main function directly!
(And make sure the files in the tools directory use these functions as part of
the same patch.)

> +void lvm2_destroy(lvm2_handle_t libh)
...
> +  return 1;

:-)

Alasdair
-- 
agk at redhat.com


