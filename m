From: Marian Csontos <mcsontos@redhat.com>
Date: Mon, 07 Apr 2014 11:33:05 +0200
Subject: master - thin: Support thin_check --clear-needs-check-flag.
In-Reply-To: <20140404012333.25D0B6109F@fedorahosted.org>
References: <20140404012333.25D0B6109F@fedorahosted.org>
Message-ID: <534270D1.2040609@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

IIUC this needs a LVM2 Bugzilla to get included in RHEL7, does not it?

-- Martian

On 04/04/2014 03:23 AM, Alasdair Kergon wrote:
> Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc72f340d757af537f239689944c934bf9b8fd62
> Commit:        cc72f340d757af537f239689944c934bf9b8fd62
> Parent:        b38a3d8c85a5ce96ccbac4e5be859d53a2ec4c35
> Author:        Alasdair G Kergon <agk@redhat.com>
> AuthorDate:    Fri Apr 4 02:22:40 2014 +0100
> Committer:     Alasdair G Kergon <agk@redhat.com>
> CommitterDate: Fri Apr 4 02:22:40 2014 +0100
>
> thin: Support thin_check --clear-needs-check-flag.
>
> Update thin provisioning tools to version 0.3.2 or later!
> ---
>   WHATS_NEW             |    2 ++
>   configure.in          |   12 ++++++++++++
>   lib/config/defaults.h |   11 ++++++++---
>   3 files changed, 22 insertions(+), 3 deletions(-)
>
> diff --git a/WHATS_NEW b/WHATS_NEW
> index b5e96fd..dd3b42f 100644
> --- a/WHATS_NEW
> +++ b/WHATS_NEW
> @@ -1,5 +1,7 @@
>   Version 2.02.106 -
>   ====================================
> +  Add configure --disable-thin_check_needs_check to support old thin_check.
> +  Use thin_check --clear-needs-check-flag by default.
>     Export lvm_even_rand() for controlled provision of random numbers.
>     Add lvmthin man page to section 7.
>     Extend internal validation of lv names size is less then 128 chars.
> diff --git a/configure.in b/configure.in
> index 88edb29..d8cbe5c 100644
> --- a/configure.in
> +++ b/configure.in
> @@ -476,6 +476,18 @@ AC_DEFINE_UNQUOTED([THIN_DUMP_CMD], ["$THIN_DUMP_CMD"],
>   AC_DEFINE_UNQUOTED([THIN_REPAIR_CMD], ["$THIN_REPAIR_CMD"],
>   		   [The path to 'thin_repair', if available.])
>
> +dnl -- thin_check needs-check flag
> +AC_MSG_CHECKING(whether thin_check supports the needs-check flag)
> +AC_ARG_ENABLE(thin_check_needs_check,
> +	      AC_HELP_STRING([--disable-thin_check_needs_check],
> +			     [required if thin_check version is < 0.3.0]),
> +	      THIN_CHECK_NEEDS_CHECK=$enableval, THIN_CHECK_NEEDS_CHECK=yes)
> +AC_MSG_RESULT($THIN_CHECK_NEEDS_CHECK)
> +
> +if test x$THIN_CHECK_NEEDS_CHECK = xyes; then
> +	AC_DEFINE([THIN_CHECK_NEEDS_CHECK], 1, [Define to 1 if the external 'thin_check' tool requires the --clear-needs-check-flag option])
> +fi
> +
>   ################################################################################
>   dnl -- cache inclusion type
>   AC_MSG_CHECKING(whether to include cache)
> diff --git a/lib/config/defaults.h b/lib/config/defaults.h
> index 94b11c0..2268e0b 100644
> --- a/lib/config/defaults.h
> +++ b/lib/config/defaults.h
> @@ -67,12 +67,17 @@
>   #define DEFAULT_BACKGROUND_POLLING 1
>
>   #ifndef DMEVENTD_PATH
> -#define DEFAULT_DMEVENTD_PATH ""
> +#  define DEFAULT_DMEVENTD_PATH ""
>   #else
> -#define DEFAULT_DMEVENTD_PATH DMEVENTD_PATH
> +#  define DEFAULT_DMEVENTD_PATH DMEVENTD_PATH
> +#endif
> +
> +#ifdef THIN_CHECK_NEEDS_CHECK
> +#  define DEFAULT_THIN_CHECK_OPTIONS "-q --clear-needs-check-flag"
> +#else
> +#  define DEFAULT_THIN_CHECK_OPTIONS "-q"
>   #endif
>
> -#define DEFAULT_THIN_CHECK_OPTIONS "-q"
>   #define DEFAULT_THIN_REPAIR_OPTIONS ""
>   #define DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
>   #define DEFAULT_THIN_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>


