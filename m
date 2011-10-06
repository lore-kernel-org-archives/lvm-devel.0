From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 06 Oct 2011 11:49:31 +0200
Subject: [PATCH 3/3] Change default prefix.
In-Reply-To: <da81bee4945606f90a6a737f2d693d300b7d8246.1317893838.git.zkabelac@redhat.com>
References: <cover.1317893838.git.zkabelac@redhat.com>
	<da81bee4945606f90a6a737f2d693d300b7d8246.1317893838.git.zkabelac@redhat.com>
Message-ID: <4E8D79AB.9030604@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 6.10.2011 11:43, Zdenek Kabelac napsal(a):
> Use ""  instead of "  ".
> So commands like lvs print from the begining of the line.
> (no need to trim space around).
>
> Signed-off-by: Zdenek Kabelac<zkabelac@redhat.com>
> ---
>   doc/example.conf.in   |    6 +++---
>   lib/config/defaults.h |    6 +++++-
>   2 files changed, 8 insertions(+), 4 deletions(-)
>
> diff --git a/doc/example.conf.in b/doc/example.conf.in
> index d38f90e..58748cc 100644
> --- a/doc/example.conf.in
> +++ b/doc/example.conf.in
> @@ -248,9 +248,9 @@ log {
>       command_names = 0
>
>       # A prefix to use before the message text (but after the command name,
> -    # if selected).  Default is two spaces, so you can see/grep the severity
> -    # of each message.
> -    prefix = "  "
> +    # if selected). Set to "  " to revert to the default behaviour
> +    # prior to version 2.02.89.
> +    prefix = ""
>
>       # To make the messages look similar to the original LVM tools use:
>       #   indent = 0
> diff --git a/lib/config/defaults.h b/lib/config/defaults.h
> index be016f6..df1dcba 100644
> --- a/lib/config/defaults.h
> +++ b/lib/config/defaults.h
> @@ -99,7 +99,11 @@
>   #define DEFAULT_MAXIMISE_CLING 1
>   #define DEFAULT_CLUSTERED 0
>
> -#define DEFAULT_MSG_PREFIX "  "
> +/*
> + * NOTE: _find_config_str() does not allow empty string "",
> + * but when the default msg prefix is also "" it works as expected.
> + */
> +#define DEFAULT_MSG_PREFIX ""

The comment here is not true anymore with patch 2/3 as I've reorderd patch set 
somewhat. So committed version will not have it.

Zdenek


