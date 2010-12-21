From: Milan Broz <mbroz@redhat.com>
Date: Tue, 21 Dec 2010 17:50:09 +0100
Subject: [PATCH 07/23] Move lastfd handling into for()
In-Reply-To: <403be35b0f1d1d1da149e3d9a948a6416475287e.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<403be35b0f1d1d1da149e3d9a948a6416475287e.1292945707.git.zkabelac@redhat.com>
Message-ID: <4D10DAC1.9050708@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/21/2010 04:41 PM, Zdenek Kabelac wrote:

> @@ -826,7 +826,8 @@ static void main_loop(int local_sock, int cmd_timeout)
>  
>  				if (thisfd->removeme) {
>  					struct local_client *free_fd;
> -					lastfd->next = thisfd->next;
> +					if (lastfd)
> +						lastfd->next = thisfd->next;

Isn't that replacing one bug with another?

If lastfd is NULL, it will crash.
After your change it will quietly do something, apparently with wrong pointers.

If lastfd cannot be NULL, the check is not needed and is redundant.

I *think* that the first fd in select is local one, removing itself is nonsense,
so lastfd should be always set. (lastfd is set in the for cycle)

Anyway I prefer to keep the code intact instead of hiding possible bug.

(Or rewrite it to something more readable. e.g. removeme flag
seems to be used only in gulm code, which is dead and unsupported etc)

Milan


