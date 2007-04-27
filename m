From: Jim Meyering <jim@meyering.net>
Date: Fri, 27 Apr 2007 19:40:31 +0200
Subject: Avoid more warnings; general const-correctness improvements
In-Reply-To: <87irbhyciu.fsf@rho.meyering.net> (Jim Meyering's message of
	"Fri\, 27 Apr 2007 19\:04\:25 +0200")
References: <87irbhyciu.fsf@rho.meyering.net>
Message-ID: <87d51pyauo.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jim Meyering <jim@meyering.net> wrote:
> Building with this
>
>     ./configure --disable-nls --with-clvmd=cman && make
>
> and the patch below (along with the others I've sent today),
> there are no more warnings.
>
> [At first, I was configuring --with-clvmd=all and made
>  a few changes for gulm-related code, but then noticed
>  it's "old", so quit looking at that part. ]
>
> Parts of the patch below may be a tiny bit controversial, since they
> work around the fact that tcp_remove_client and alloc_client both
> modify their "char *csid" parameter, while logically they needn't
> (and shouldn't) do that.  I.e., the sole alloc_client caller certainly
> doesn't expect its addr.sin6_addr argument to be modified.  Before this
> change, tcp_remove_client would modify its csid parameter, but restore
> the original value right afterwards.  The only objection I can imagine
> is that this change adds the overhead of the added memcpy calls.  IMHO,
> they're worth the price to make the interfaces cleaner and avoid warnings.
...
> 	* daemons/clvmd/tcp-comms.c (tcp_remove_client): Make parameter "const".
> 	But since it was being modified, use a temporary copy and modify that
> 	instead.  Use a loop rather than two identical blocks of code.
> 	(alloc_client): Similarly, make the "csid" parameter "const",
> 	and modify a copy.

FYI, I've just noticed that tcp-comms.c (and hence the potentially
objectionable hunks) is used only --with-clvmd=gulm (or =all),
so I suppose it can be omitted, if it's an issue.


