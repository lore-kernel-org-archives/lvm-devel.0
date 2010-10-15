From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 15 Oct 2010 11:50:33 +0200
Subject: [PATCH] Fix liblvm2cmd.so linking order for --as-needed builds
In-Reply-To: <20101012151524.GA6280@pld-linux.org>
References: <1283355456.30896.286.camel@yamato.local>	<4CB468E4.4080101@redhat.com>	<1286893207.20493.20.camel@yamato.local>	<4CB4775B.2000009@redhat.com>
	<20101012151524.GA6280@pld-linux.org>
Message-ID: <4CB823E9.7070808@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 12.10.2010 17:15, Przemyslaw Iskra napsal(a):
> On Tue, Oct 12, 2010 at 04:57:31PM +0200, Zdenek Kabelac wrote:
> 
>> Hmm - ok - I'll need to take a look on this.
> 
> The Makefile should be fixed, but...
> 
> Why not just drop floor() usage (which is misused anyways) ?
> Without it the whole -lm won't be needed.
> I've sent a patch for this some time ago, resending it here.
> [May be a bit outdated if configure.in changed]
> 

Ok, both patches (Makefile.in, metadata.c) are now upstream.

Zdenek


