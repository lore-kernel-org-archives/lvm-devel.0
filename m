From: Milan Broz <mbroz@redhat.com>
Date: Wed, 26 Oct 2011 13:19:37 +0200
Subject: [PATCH 3/3] Change default prefix.
In-Reply-To: <da81bee4945606f90a6a737f2d693d300b7d8246.1317893838.git.zkabelac@redhat.com>
References: <cover.1317893838.git.zkabelac@redhat.com>
	<da81bee4945606f90a6a737f2d693d300b7d8246.1317893838.git.zkabelac@redhat.com>
Message-ID: <4EA7ECC9.1080006@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/06/2011 11:43 AM, Zdenek Kabelac wrote:
> Use ""  instead of "  ".
> So commands like lvs print from the begining of the line.
> (no need to trim space around).
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
> ---
>  doc/example.conf.in   |    6 +++---
>  lib/config/defaults.h |    6 +++++-
>  2 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/doc/example.conf.in b/doc/example.conf.in
> index d38f90e..58748cc 100644
> --- a/doc/example.conf.in
> +++ b/doc/example.conf.in
> @@ -248,9 +248,9 @@ log {
>      command_names = 0
>  
>      # A prefix to use before the message text (but after the command name,
> -    # if selected).  Default is two spaces, so you can see/grep the severity
> -    # of each message.
> -    prefix = "  "
> +    # if selected). Set to "  " to revert to the default behaviour
> +    # prior to version 2.02.89.
> +    prefix = ""

I am not sure here...

IMHO lvs/pvs etc should not use prefix if there is --noheading, --separator
and such script options.

But do we really want to change default output?

Except this default prefix change, ack.

Milan


