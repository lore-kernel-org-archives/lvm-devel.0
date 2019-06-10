From: Nir Soffer <nsoffer@redhat.com>
Date: Mon, 10 Jun 2019 23:16:13 +0300
Subject: [PATCH] tool: Allow suppressing backup warnings
In-Reply-To: <20190529121000.25206-1-nsoffer@redhat.com>
References: <20190529121000.25206-1-nsoffer@redhat.com>
Message-ID: <CAMRbyytdRwTve-9mrmFbY_VyWiXSyDXWwu8fJFssAqehMFNvPQ@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

ping

On Wed, May 29, 2019 at 3:10 PM Nir Soffer <nirsof@gmail.com> wrote:

> We have a mechanism to show only single warning about disabled backup:
>
>     WARNING: This metadata update is NOT backed up
>
> In oVirt we disable local backup since it does not play well with oVirt
> clustered LVM solution, and this warning is not helpful. We can filter
> the message in oVirt logs, but I think the right place to fix this is in
> LVM.
>
> Add LVM_SUPPRESS_BACKUP_WARNINGS environment variable. If set, suppress
> also the first warning about disable backup.
> ---
>  lib/format_text/archiver.c | 3 +++
>  man/lvm.8_main             | 4 ++++
>  2 files changed, 7 insertions(+)
>
> diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
> index 052c2bd2b..0ea8d5e48 100644
> --- a/lib/format_text/archiver.c
> +++ b/lib/format_text/archiver.c
> @@ -196,10 +196,13 @@ int backup_init(struct cmd_context *cmd, const char
> *dir,
>                 log_error("Couldn't copy backup directory name.");
>                 return 0;
>         }
>         backup_enable(cmd, enabled);
>
> +    if (getenv("LVM_SUPPRESS_BACKUP_WARNINGS"))
> +        cmd->backup_params->suppress = 1;
> +
>         return 1;
>  }
>
>  void backup_exit(struct cmd_context *cmd)
>  {
> diff --git a/man/lvm.8_main b/man/lvm.8_main
> index 3e67b1bdf..43ce5150c 100644
> --- a/man/lvm.8_main
> +++ b/man/lvm.8_main
> @@ -470,10 +470,14 @@ together allow automated test scripts to discard
> uninteresting log data.
>  .TP
>  .B LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES
>  Used to suppress warning messages when the configured locking is known
>  to be unavailable.
>  .TP
> +.B LVM_SUPPRESS_BACKUP_WARNINGS
> +Used to suppress warning messages when automatic metadata backup is
> +disabled.
> +.TP
>  .B DM_ABORT_ON_INTERNAL_ERRORS
>  Abort processing if the code detects a non-fatal internal error.
>  .TP
>  .B DM_DISABLE_UDEV
>  Avoid interaction with udev.  LVM will manage the relevant nodes in /dev
> --
> 2.17.2
>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190610/9e01260e/attachment.htm>
