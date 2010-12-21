From: Milan Broz <mbroz@redhat.com>
Date: Tue, 21 Dec 2010 17:20:03 +0100
Subject: [PATCH 04/23] Remove dead assignment of lock_flags
In-Reply-To: <0662c43178e50334f41961cbb83743e9eb7e5e53.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<0662c43178e50334f41961cbb83743e9eb7e5e53.1292945707.git.zkabelac@redhat.com>
Message-ID: <4D10D3B3.1070003@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/21/2010 04:41 PM, Zdenek Kabelac wrote:
> @@ -204,7 +203,6 @@ static int lock_vg(struct local_client *client)
>  
>      lock_cmd = args[0] & (LCK_NONBLOCK | LCK_HOLD | LCK_SCOPE_MASK | LCK_TYPE_MASK);
>      lock_mode = ((int)lock_cmd & LCK_TYPE_MASK);
> -    lock_flags = args[1];
>      lockname = &args[2];

I intentionally kept unused args[1] here because it is clear how the request look like
without searching code, IOW

- 0 byte is command
- 1 byte flags
- 2 lockname

So any possible changes is easy on place.
Yes, it should be struct and should use some friendly names. But now there is byte array...

Complier is clever enough to remove that code.

I do not care what some stupid static analysis says, the code is more readable with
"dead" variable for me.

Milan


