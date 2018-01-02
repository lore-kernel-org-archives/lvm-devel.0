From: Marian Csontos <mcsontos@redhat.com>
Date: Tue, 2 Jan 2018 20:14:25 +0100
Subject: [PATCH] config: Clarify filter documentation
In-Reply-To: <1514919952-22127-1-git-send-email-mcsontos@redhat.com>
References: <1514919952-22127-1-git-send-email-mcsontos@redhat.com>
Message-ID: <f9473f75-7b6d-cc56-f173-a52e8ebf736e@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/02/2018 08:05 PM, Marian Csontos wrote:
> ---
>   conf/example.conf.in         | 4 ++--
>   lib/config/config_settings.h | 4 ++--
>   2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/conf/example.conf.in b/conf/example.conf.in
> index aab274d..cd4ed29 100644
> --- a/conf/example.conf.in
> +++ b/conf/example.conf.in
> @@ -114,8 +114,8 @@ devices {
>   	# device path names. Each regex is delimited by a vertical bar '|'
>   	# (or any character) and is preceded by 'a' to accept the path, or
>   	# by 'r' to reject the path. The first regex in the list to match the

Reordered the lines so inline comments match each line:

> -	# path is used, producing the 'a' or 'r' result for the device > +	# path is used, producing the 'a' or 'r' result for that path.

It is path being rejected, not device!

> -	# When multiple path names exist for a block device, if any path name
> +	# If any of multiple existing path names for a block device

"When multiple path names exist for a block device" is true most of if 
not all the time, and new sentence expresses the intention more clearly.

If anyone is able to come up with better wording I would be happy.

>   	# matches an 'a' pattern before an 'r' pattern, then the device is
>   	# accepted. If all the path names match an 'r' pattern first, then the
>   	# device is rejected. Unmatching path names do not affect the accept
> diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
> index 077fb15..f47985e 100644
> --- a/lib/config/config_settings.h
> +++ b/lib/config/config_settings.h
> @@ -280,8 +280,8 @@ cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENT
>   	"device path names. Each regex is delimited by a vertical bar '|'\n"
>   	"(or any character) and is preceded by 'a' to accept the path, or\n"
>   	"by 'r' to reject the path. The first regex in the list to match the\n"
> -	"path is used, producing the 'a' or 'r' result for the device.\n"
> -	"When multiple path names exist for a block device, if any path name\n"
> +	"path is used, producing the 'a' or 'r' result for that path.\n"
> +	"If any of multiple existing path names for a block device\n"
>   	"matches an 'a' pattern before an 'r' pattern, then the device is\n"
>   	"accepted. If all the path names match an 'r' pattern first, then the\n"
>   	"device is rejected. Unmatching path names do not affect the accept\n"
> 


