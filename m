From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 12 Oct 2010 16:57:31 +0200
Subject: [PATCH] Fix liblvm2cmd.so linking order for --as-needed builds
In-Reply-To: <1286893207.20493.20.camel@yamato.local>
References: <1283355456.30896.286.camel@yamato.local>	
	<4CB468E4.4080101@redhat.com>
	<1286893207.20493.20.camel@yamato.local>
Message-ID: <4CB4775B.2000009@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 12.10.2010 16:20, Diego Elio Petten? napsal(a):
> Il giorno mar, 12/10/2010 alle 15.55 +0200, Zdenek Kabelac ha scritto:
>> The last occurrence of  CLDWHOLEARCHIVE in tools/Makefile.in seems to be
>> dropped by this Alasdair's commit:
> 
> Uh?
> 
> liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
>         $(CC) -shared -Wl,-soname,$@.$(LIB_VERSION) \
>         $(CFLAGS) $(CLDFLAGS) -o $@ $(LVMLIBS) $(LIBS) \
>                 @CLDWHOLEARCHIVE@ liblvm2cmd.a @CLDNOWHOLEARCHIVE@
> 
> this is in 
> 
> commit 39429d390515de9a375979274bc61d787ea9a0cb
> Author: Zdenek Kabelac <zkabelac@redhat.com>
> Date:   Fri Oct 8 15:03:21 2010 +0000
> 
> Did I get the wrong GIT repository?

Ooops sorry - my bad - I've been working with non-master git branch looking
for some older bug.


Hmm - ok - I'll need to take a look on this.


Zdenek


