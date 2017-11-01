From: Eric Ren <zren@suse.com>
Date: Wed, 1 Nov 2017 22:35:43 +0800
Subject: [PATCH v2] clvmd: supress ENOENT error on testing connection
In-Reply-To: <20171030125320.15509-1-zren@suse.com>
References: <20171030125320.15509-1-zren@suse.com>
Message-ID: <85e3d63b-b10e-ca56-514a-eff2e59ef477@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek,

Please take another look at this simple fix. Is this good for merging?

Thanks,
Eric

On 10/30/2017 08:53 PM, Eric Ren wrote:
> In HA cluster, we have "clvm" resource agent to manage clvmd daemon.
> The agent invokes clvmd like: "clvmd -T90 -d0", which  always prints
> a scaring error message:
>
> """
> local socket: connect failed: No such file or directory
> """
>
> When specifed with "-d" option, clvmd tries to check if an instance
> of the clvmd daemon is already running through a testing connection.
> The connect() will fail with this ENOENT error in such case, so supress
> the error message in such case.
>
> Signed-off-by: Eric Ren <zren@suse.com>
> ---
>   daemons/clvmd/clvmd.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
> index 9dbda89..fda8f83 100644
> --- a/daemons/clvmd/clvmd.c
> +++ b/daemons/clvmd/clvmd.c
> @@ -2170,7 +2170,8 @@ static int check_local_clvmd(void)
>   
>   	if (connect(local_socket,(struct sockaddr *) &sockaddr,
>   		    sizeof(sockaddr))) {
> -		log_sys_error("connect", "local socket");
> +		if (errno != ENOENT)
> +			log_sys_error("connect", "local socket");
>   		ret = -1;
>   	}
>   


