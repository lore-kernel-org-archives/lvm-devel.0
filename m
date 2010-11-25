From: Petr Rockai <prockai@redhat.com>
Date: Thu, 25 Nov 2010 18:26:03 +0100
Subject: [PATCH 03/29] Remove printing of LCK_CACHE
In-Reply-To: <b66c1e177b64ce40a6c63127b70dc9c01b83d14f.1290682013.git.zkabelac@redhat.com>
	(Zdenek Kabelac's message of "Thu, 25 Nov 2010 11:55:07 +0100")
References: <cover.1290682013.git.zkabelac@redhat.com>
	<cover.1290682013.git.zkabelac@redhat.com>
	<b66c1e177b64ce40a6c63127b70dc9c01b83d14f.1290682013.git.zkabelac@redhat.com>
Message-ID: <87r5e9mi1g.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac <zkabelac@redhat.com> writes:

> LCK_CACHE is defined as 0x100 so it cannot be passed through
> unsigned char parameter - remove it from the sprintf code.

> If LCK_CLUSTER would be desirable to be printed here - lot of code
> would neet to be reworked.

Okey. It doesn't make me extremely happy to go this way, but I see how
it could be confusing as it is, and complicated to fix it properly. It
would be however desirable, at least, to add a comment to
decode_locking_cmd explaining the situation.

>
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
> ---
>  daemons/clvmd/lvm-functions.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
>
> diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
> index 20b25a6..51a4cdb 100644
> --- a/daemons/clvmd/lvm-functions.c
> +++ b/daemons/clvmd/lvm-functions.c
> @@ -109,12 +109,11 @@ static const char *decode_locking_cmd(unsigned char cmdl)
>  		break;
>  	}
>  
> -	sprintf(buf, "0x%x %s (%s|%s%s%s%s%s%s)", cmdl, command, type, scope,
> +	sprintf(buf, "0x%x %s (%s|%s%s%s%s%s)", cmdl, command, type, scope,
>  		cmdl & LCK_NONBLOCK   ? "|NONBLOCK" : "",
>  		cmdl & LCK_HOLD       ? "|HOLD" : "",
>  		cmdl & LCK_LOCAL      ? "|LOCAL" : "",
> -		cmdl & LCK_CLUSTER_VG ? "|CLUSTER_VG" : "",
> -		cmdl & LCK_CACHE      ? "|CACHE" : "");
> +		cmdl & LCK_CLUSTER_VG ? "|CLUSTER_VG" : "");
>  
>  	return buf;
>  }


