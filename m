From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 30 Nov 2010 11:31:33 +0100
Subject: [PATCH] Fix liblvm2cmd.so linking order for --as-needed builds
In-Reply-To: <1286893207.20493.20.camel@yamato.local>
References: <1283355456.30896.286.camel@yamato.local>	<4CB468E4.4080101@redhat.com>
	<1286893207.20493.20.camel@yamato.local>
Message-ID: <4CF4D285.7070005@redhat.com>
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
> 


f5c395ad (Alasdair Kergon   2008-11-14 20:59:56 +0000 151)
liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
16d70487 (Zdenek Kabelac    2010-05-11 08:34:38 +0000 152)      $(CC) -shared
-Wl,-soname,$@.$(LIB_VERSION) \
d54db501 (Zdenek Kabelac    2010-10-15 09:41:21 +0000 153)
$(CFLAGS) $(CLDFLAGS) -o $@ \
d54db501 (Zdenek Kabelac    2010-10-15 09:41:21 +0000 154)
@CLDWHOLEARCHIVE@ liblvm2cmd.a @CLDNOWHOLEARCHIVE@ \
d54db501 (Zdenek Kabelac    2010-10-15 09:41:21 +0000 155)
$(LVMLIBS) $(LIBS)

---

liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
	$(CC) -shared -Wl,-soname,$@.$(LIB_VERSION) \
		$(CFLAGS) $(CLDFLAGS) -o $@ \
		@CLDWHOLEARCHIVE@ liblvm2cmd.a @CLDNOWHOLEARCHIVE@ \
		$(LVMLIBS) $(LIBS)

---

commit d54db5013b9ff5ebdf7cc3747b78e0cc39f72b39
Author: Zdenek Kabelac <zkabelac@redhat.com>
Date:   Fri Oct 15 09:41:21 2010 +0000

    Fix linking order for liblvm2cmd

    Reorder linked libraries so we better support --as-needed linker flag used
    by some distributions (i.e. Gentoo).

    Patch suggested by Diego Elio Petten? <flameeyes <at> gmail.com>

---


I suppose this should be fixing reported problem ?

Zdenek


